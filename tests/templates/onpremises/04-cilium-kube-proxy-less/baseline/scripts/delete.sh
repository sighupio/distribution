#!/usr/bin/env sh

set -e

kappbin=""
yqbin=""

# The objects of app kfd as one JSON array: kapp inspect --raw prints a header, then "---" before each object, then "Succeeded".
# shellcheck disable=SC2016 # $o is a yq variable.
appObjects() {
  "$kappbin" inspect -a kfd -n kube-system --raw "$@" | awk 'f || /^---$/ { f = 1; print }' | grep -v '^Succeeded$' | "$yqbin" ea -o json -I0 '. as $o ireduce ([]; . + [$o])'
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

  objects="$(appObjects)"
  stuck="$(stuckReport "$objects")"
  if [ -z "$stuck" ]; then
    return 1
  fi
  echo "$stuck"

  filter="$(aroundStuck "$objects")"
  # The last --filter wins in kapp, so the filter of the pass is kept inside the new one.
  prev=""
  for arg in "$@"; do
    if [ "$prev" = "--filter" ]; then
      filter="{\"and\":[$arg,$filter]}"
    fi
    prev="$arg"
  done

  if "$@" --filter "$filter"; then
    return 0
  fi

  objects="$(appObjects --filter "$filter")"
  if [ -n "$(printf '%s\n' "$objects" | "$yqbin" '.[] | select(.metadata.deletionTimestamp == null) | .kind')" ]; then
    return 1
  fi
  stuckReport "$objects"
}

# --apply-ignored deletes the objects kapp ignores by default, such as the PVCs of the StatefulSets.
deleteWithGrace "$kappbin" delete -a kfd -n kube-system -y --apply-ignored --apply-concurrency 20 --apply-timeout 15m --wait-timeout 15m
