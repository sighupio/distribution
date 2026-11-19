#!/usr/bin/env sh

set -e

kappbin="{{ .paths.kapp }}"
kubectlbin="{{ .paths.kubectl }}"
helmbin="{{ .paths.helm }}"
helmfilebin="{{ .paths.helmfile }}"
yqbin="{{ .paths.yq }}"

# With --storage-class-providers only the plugins that own a StorageClass are deleted, without it only the others:
# the StorageClass providers go after the distribution, whose PVCs they serve.
storageClassProviders=false
if [ "${1:-}" = "--storage-class-providers" ]; then
  storageClassProviders=true
fi

{{- $kustomize := list }}
{{- $releases := list }}
{{- if index .spec "plugins" }}
{{- if index .spec.plugins "kustomize" }}
{{- $kustomize = .spec.plugins.kustomize }}
{{- end }}
{{- if and (index .spec.plugins "helm") (index .spec.plugins.helm "releases") }}
{{- $releases = .spec.plugins.helm.releases }}
{{- end }}
{{- end }}
{{- if or $kustomize $releases }}

# The objects of a kapp app as one JSON array: kapp inspect --raw prints a header, then "---" before each object, then "Succeeded".
# shellcheck disable=SC2016 # $o is a yq variable.
# An app that does not exist has no objects; any other error of kapp fails, never an empty answer.
appObjects() {
  app="$1"
  shift
  if ! raw="$("$kappbin" inspect -a "$app" -n kube-system --raw "$@" 2> "kapp-inspect-$app.err")"; then
    if grep -q "App '$app' (namespace: kube-system) does not exist" "kapp-inspect-$app.err"; then
      rm -f "kapp-inspect-$app.err"
      echo '[]'
      return 0
    fi
    cat "kapp-inspect-$app.err" >&2
    rm -f "kapp-inspect-$app.err"
    return 1
  fi
  rm -f "kapp-inspect-$app.err"
  printf '%s\n' "$raw" | awk 'f || /^---$/ { f = 1; print }' | grep -v '^Succeeded$' | "$yqbin" ea -o json -I0 '. as $o ireduce ([]; . + [$o])'
}

stuckReport() {
  printf '%s\n' "$1" | "$yqbin" '.[] | select(.metadata.deletionTimestamp != null) | "stuck: " + .kind + " " + ((.metadata.namespace // "") + "/" | sub("^/$", "")) + .metadata.name + " finalizers=" + ((.metadata.finalizers // []) | join(","))'
}

# A kapp filter that excludes the stuck objects and the CRDs that serve them: a CRD waits for its objects.
# shellcheck disable=SC2016 # $objs and $s are yq variables.
aroundStuck() {
  printf '%s\n' "$1" | "$yqbin" -o json -I0 '
    . as $objs
    | [.[] | select(.metadata.deletionTimestamp != null) | . as $s
      | ($s, ($objs[] | select(.kind == "CustomResourceDefinition" and .spec.names.kind == $s.kind and .spec.group == ($s.apiVersion | sub("/.*", "")))))]
    | map({"resource": {"kinds": [.kind], "namespaces": [.metadata.namespace // ""], "names": [.metadata.name]}} | del(.resource.namespaces | select(.[0] == "")))
    | {"not": {"or": .}}'
}

# kapp deletes in waves and a timeout stops the later ones: after a failure, objects stuck on a finalizer are
# reported and one more pass deletes the rest around them.
deleteWithGrace() {
  if "$@"; then
    return 0
  fi

  app=""
  prev=""
  for arg in "$@"; do
    if [ "$prev" = "-a" ]; then
      app="$arg"
    fi
    prev="$arg"
  done

  objects="$(appObjects "$app")"
  stuck="$(stuckReport "$objects")"
  if [ -z "$stuck" ]; then
    return 1
  fi
  echo "$stuck"

  filter="$(aroundStuck "$objects")"
  if "$@" --filter "$filter"; then
    return 0
  fi

  objects="$(appObjects "$app" --filter "$filter")"
  if [ -n "$(printf '%s\n' "$objects" | "$yqbin" '.[] | select(.metadata.deletionTimestamp == null) | .kind')" ]; then
    return 1
  fi
  stuckReport "$objects"
}

selected=""
providers=""

# choosePlugin <id> <plugin> <StorageClasses> <namespaces>: keeps the plugin when it is on the side of the flag; a
# StorageClass provider is also recorded, tab separated, for the PVC guard.
choosePlugin() {
  owns=false
  if [ -n "$3" ]; then
    owns=true
  fi
  if [ "$owns" != "$storageClassProviders" ]; then
    return 0
  fi
  selected="$selected $1 "
  if [ "$owns" = true ]; then
    providers="$providers$(printf '%s\t%s\t%s' "$2" "$(echo "$3" | paste -s -d, -)" "$(echo "$4" | paste -s -d, -)")
"
  fi
}

isSelected() {
  case "$selected" in
    *" $1 "*) return 0 ;;
  esac
  return 1
}

scanKustomize() {
  objects="$(appObjects "kfd-plugin-$1")"
  choosePlugin "kustomize/$1" "$1" \
    "$(printf '%s\n' "$objects" | "$yqbin" '.[] | select(.kind == "StorageClass") | .metadata.name')" \
    "$(printf '%s\n' "$objects" | "$yqbin" '[.[].metadata.namespace | select(. != null)] | unique | .[]')"
}

# A release that is not installed has nothing to delete; any other error of helm fails, never an empty manifest.
releaseManifest() {
  if ! manifest="$("$helmbin" get manifest "$1" -n "$2" 2> "helm-get-$1.err")"; then
    if grep -q 'release: not found' "helm-get-$1.err"; then
      rm -f "helm-get-$1.err"
      return 0
    fi
    cat "helm-get-$1.err" >&2
    rm -f "helm-get-$1.err"
    return 1
  fi
  rm -f "helm-get-$1.err"
  printf '%s\n' "$manifest"
}

scanRelease() {
  manifest="$(releaseManifest "$1" "$2")"
  choosePlugin "helm/$1" "$1" "$(printf '%s\n' "$manifest" | "$yqbin" ea 'select(.kind == "StorageClass") | .metadata.name')" "$2"
}

# deleteObjects <YAML documents>: deletes them and waits until they are gone; no documents, no call.
deleteObjects() {
  if [ -n "$1" ]; then
    printf '%s\n' "$1" | "$kubectlbin" delete --ignore-not-found --wait --timeout=15m -f -
  fi
}

# The objects of a release whose kind a CRD serves go first, then the CRDs (from the manifest and from the chart's crds/,
# which helm does not uninstall): helm uninstall would remove the operators that clear their finalizers.
# shellcheck disable=SC2016 # $p is a yq variable.
deleteRelease() {
  releaseManifest "$1" "$2" > "release-$1-manifest.yaml"
  "$helmfilebin" -f helmfile.yaml -l "name=$1" template --include-crds > "release-$1-template.yaml"
  served="$("$yqbin" ea 'select(.kind == "CustomResourceDefinition") | .spec.group + " " + .spec.names.kind' "release-$1-manifest.yaml" "release-$1-template.yaml")"
  deleteObjects "$(SERVED="$served" "$yqbin" ea 'select(((.apiVersion // "" | sub("/.*", "")) + " " + .kind) as $p | strenv(SERVED) | split("\n") | any_c(. == $p))' "release-$1-manifest.yaml")"
  deleteObjects "$("$yqbin" ea 'select(.kind == "CustomResourceDefinition")' "release-$1-manifest.yaml" "release-$1-template.yaml")"
  rm -f "release-$1-manifest.yaml" "release-$1-template.yaml"

  if ! "$helmfilebin" -f helmfile.yaml -l "name=$1" destroy --deleteWait --deleteTimeout 900 --cascade foreground; then
    echo "helmfile destroy of release $1 failed, retrying without hooks..."
    "$helmfilebin" -f helmfile.yaml -l "name=$1" destroy --deleteWait --deleteTimeout 900 --cascade foreground --args --no-hooks
  fi
}
{{- range $kustomize }}
scanKustomize {{ .name }}
{{- end }}
{{- range $releases }}
scanRelease {{ .name }} {{ .namespace }}
{{- end }}

# storageInUse prints, for each StorageClass provider, the bound PVCs outside its own namespaces that use its StorageClasses.
# It runs in a command substitution, where errexit may not hold: a failed read returns non-zero, never an empty answer.
# shellcheck disable=SC2016 # $scs, $nss, $sc and $ns are yq variables.
storageInUse() {
  pvcs="$("$kubectlbin" get persistentvolumeclaims -A -o json)" || return
  while IFS="$(printf '\t')" read -r plugin storageClasses namespaces; do
    [ -n "$plugin" ] || continue
    used="$(printf '%s\n' "$pvcs" | SCS="$storageClasses" NSS="$namespaces" "$yqbin" -p json -o yaml '
      (strenv(SCS) | split(",")) as $scs | (strenv(NSS) | split(",")) as $nss
      | .items[] | select(.status.phase == "Bound")
      | select(.spec.storageClassName as $sc | $scs | any_c(. == $sc))
      | select(.metadata.namespace as $ns | $nss | any_c(. == $ns) | not)
      | "PersistentVolumeClaim " + .metadata.namespace + "/" + .metadata.name')" || return
    if [ -n "$used" ]; then
      printf 'plugin %s: its StorageClass is used by\n%s\n' "$plugin" "$used"
    fi
  done <<EOF
$providers
EOF
}

# A StorageClass provider goes only when no bound PVC outside its own namespaces still uses its StorageClasses.
if [ -n "$providers" ]; then
  inUse="$(storageInUse)"
  if [ -n "$inUse" ]; then
    echo "Cannot delete the StorageClass providers, delete these PersistentVolumeClaims first:"
    printf '%s\n' "$inUse"
    exit 1
  fi
fi
{{- range reverse $kustomize }}

if isSelected kustomize/{{ .name }}; then
  echo "Deleting plugin {{ .name }}..."
  # --apply-ignored deletes the objects kapp ignores by default, such as the PVCs of the StatefulSets.
  deleteWithGrace "$kappbin" delete -a kfd-plugin-{{ .name }} -n kube-system -y --apply-ignored --apply-timeout 15m --wait-timeout 15m
fi
{{- end }}
{{- range reverse $releases }}

if isSelected helm/{{ .name }}; then
  echo "Deleting helm release {{ .name }}..."
  deleteRelease {{ .name }} {{ .namespace }}
fi
{{- end }}
{{- end }}
