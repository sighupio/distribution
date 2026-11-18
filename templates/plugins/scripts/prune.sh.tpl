#!/usr/bin/env sh

# Deletes the resources of plugins removed from spec.plugins. furyctl renders it from the previous
# configuration, so it knows every plugin that configuration installed.
# Usage: prune.sh plan|delete kustomize:<name>|helm:<namespace>/<name>...
#   plan   prints what delete would remove and changes nothing.
#   delete removes the named plugins.
# Both modes stop, deleting nothing, when a PVC outside the named plugins uses a StorageClass they provide.

set -e

kappbin="{{ .paths.kapp }}"
kubectlbin="{{ .paths.kubectl }}"
helmbin="{{ .paths.helm }}"
helmfilebin="{{ .paths.helmfile }}"
yqbin="{{ .paths.yq }}"

helmfile_yaml="$(dirname "$0")/../helmfile.yaml"

known="{{ if (index .spec "plugins") }}{{ if (index .spec.plugins "kustomize") }}{{ range .spec.plugins.kustomize }} kustomize:{{ .name }}{{ end }}{{ end }}{{ if (index .spec.plugins "helm") }}{{ if (index .spec.plugins.helm "releases") }}{{ range .spec.plugins.helm.releases }} helm:{{ .namespace }}/{{ .name }}{{ end }}{{ end }}{{ end }}{{ end }}"

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

usage() {
  echo "usage: $0 plan|delete kustomize:<name>|helm:<namespace>/<name>..." >&2
  exit 2
}

# words joins the lines of a list with single spaces.
words() {
  printf '%s\n' "$1" | tr -s '\n ' '  ' | sed 's/^ //; s/ $//'
}

[ $# -ge 2 ] || usage

mode="$1"
shift

case "$mode" in
plan | delete) ;;
*) usage ;;
esac

for target in "$@"; do
  case " $known " in
  *" $target "*) ;;
  *)
    echo "Unknown plugin $target: it is not in spec.plugins of the configuration this script was rendered from" >&2
    exit 1
    ;;
  esac
done

# describe <target> reads the cluster and sets: name, ns, label, installed (yes|no), scs (StorageClasses the
# plugin provides), pvcs (its PVCs as namespace/name) and, for Helm, crds (the chart's CRDs that exist).
# Lists are space separated. The delete mode describes every target twice, once for the guard and once to
# delete it: the first description is kept in a file so the cluster is read once per target.
describe() {
  memo="$work/$(printf '%s' "$1" | tr ':/' '__').desc"

  if [ -f "$memo" ]; then
    # shellcheck source=/dev/null
    . "$memo"
    return
  fi

  ns=""
  scs=""
  pvcs=""
  crds=""

  case "$1" in
  kustomize:*)
    name="${1#kustomize:}"
    label="$name (kustomize)"

    # kapp lists the PVCs of the app's StatefulSets with the app, so its record holds every PVC to delete.
    if "$kappbin" inspect -a "kfd-plugin-$name" -n kube-system --json >"$work/inspect.json" 2>"$work/err"; then
      installed=yes
      scs="$("$yqbin" -p json '.Tables[0].Rows[] | select(.kind == "StorageClass") | .name' "$work/inspect.json")"
      pvcs="$("$yqbin" -p json '.Tables[0].Rows[] | select(.kind == "PersistentVolumeClaim") | .namespace + "/" + .name' "$work/inspect.json")"
    elif grep -q "does not exist" "$work/err"; then
      installed=no
    else
      cat "$work/err" >&2
      exit 1
    fi
    ;;
  helm:*)
    ref="${1#helm:}"
    ns="${ref%%/*}"
    name="${ref#*/}"
    label="$name (helm release, namespace $ns)"

    # The CRDs of the chart's crds/ folder: helm uninstall leaves them behind.
    "$helmfilebin" -f "$helmfile_yaml" -l "name=$name,namespace=$ns" template --include-crds >"$work/template.yaml"
    chart_crds="$("$yqbin" 'select(.kind == "CustomResourceDefinition") | .metadata.name' "$work/template.yaml")"
    for crd in $chart_crds; do
      if "$kubectlbin" get crd "$crd" >/dev/null 2>&1; then
        crds="$crds $crd"
      fi
    done

    if "$helmbin" status "$name" -n "$ns" >/dev/null 2>"$work/err"; then
      installed=yes
      "$helmbin" get manifest "$name" -n "$ns" >"$work/manifest.yaml"
      scs="$("$yqbin" 'select(.kind == "StorageClass") | .metadata.name' "$work/manifest.yaml")"

      # A StatefulSet names its PVCs <volumeClaimTemplate>-<statefulset>-<ordinal>.
      NS="$ns" "$yqbin" 'select(.kind == "StatefulSet") | (.metadata.namespace // strenv(NS)) + " " + .metadata.name + " " + .spec.volumeClaimTemplates[].metadata.name' \
        "$work/manifest.yaml" >"$work/claims"
      while read -r claim_ns sts claim; do
        "$kubectlbin" get pvc -n "$claim_ns" -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' >"$work/ns-pvcs"
        while read -r pvc; do
          case "$pvc" in
          "$claim-$sts-"[0-9]*) pvcs="$pvcs $claim_ns/$pvc" ;;
          esac
        done <"$work/ns-pvcs"
      done <"$work/claims"
    elif grep -q "not found" "$work/err"; then
      installed=no
    else
      cat "$work/err" >&2
      exit 1
    fi
    ;;
  esac

  scs="$(words "$scs")"
  pvcs="$(words "$pvcs")"
  crds="$(words "$crds")"

  printf "installed='%s'\nname='%s'\nns='%s'\nlabel='%s'\nscs='%s'\npvcs='%s'\ncrds='%s'\n" \
    "$installed" "$name" "$ns" "$label" "$scs" "$pvcs" "$crds" >"$memo"
}

all_scs=""
all_pvcs=""

for target in "$@"; do
  describe "$target"

  if [ "$installed" = yes ]; then
    echo "Plugin $label: installed"
  else
    echo "Plugin $label: not installed"
  fi

  echo "  StorageClasses: $scs"
  echo "  PVCs: $pvcs"

  if [ -n "$crds" ]; then
    echo "  CRDs: $crds"
  fi

  all_scs="$all_scs $scs"
  all_pvcs="$all_pvcs $pvcs"
done

# StorageClass guard: deleting a StorageClass that a PVC outside the targets uses breaks that PVC.
blocked=""

if [ -n "$(words "$all_scs")" ]; then
  "$kubectlbin" get pvc -A -o jsonpath='{range .items[*]}{.metadata.namespace}/{.metadata.name} {.spec.storageClassName}{"\n"}{end}' >"$work/pvcs"

  while read -r pvc sc; do
    [ -n "$sc" ] || continue

    case "$all_scs " in
    *" $sc "*)
      case "$all_pvcs " in
      *" $pvc "*) ;;
      *) blocked="$blocked
  - $pvc (StorageClass $sc)" ;;
      esac
      ;;
    esac
  done <"$work/pvcs"
fi

if [ -n "$blocked" ]; then
  echo "The prune stops before deleting anything: these PVCs outside the plugins use a StorageClass the plugins provide:$blocked" >&2
  exit 1
fi

if [ "$mode" = plan ]; then
  exit 0
fi

for target in "$@"; do
  describe "$target"

  case "$target" in
  kustomize:*)
    if [ "$installed" = no ]; then
      echo "Nothing to delete for $name: the kapp app kfd-plugin-$name does not exist"
      continue
    fi

    echo "Deleting plugin $label..."

    # --apply-ignored: without it kapp waits until its timeout on the PVCs of the app's StatefulSets.
    "$kappbin" delete -a "kfd-plugin-$name" -n kube-system --apply-ignored -y
    ;;
  helm:*)
    if [ "$installed" = no ] && [ -z "$crds" ]; then
      echo "Nothing to delete for $name: the release is not installed in namespace $ns"
      continue
    fi

    echo "Deleting plugin $label..."

    # Custom resources first, while the chart's controller still runs their finalizers.
    for crd in $crds; do
      "$kubectlbin" delete "$crd" --all -A --ignore-not-found
    done

    if [ "$installed" = yes ]; then
      "$helmfilebin" -f "$helmfile_yaml" -l "name=$name,namespace=$ns" destroy
    fi

    for pvc in $pvcs; do
      "$kubectlbin" delete pvc -n "${pvc%%/*}" "${pvc#*/}" --ignore-not-found
    done

    # The release namespace stays: other releases may share it.
    for crd in $crds; do
      "$kubectlbin" delete crd "$crd" --ignore-not-found
    done
    ;;
  esac
done
