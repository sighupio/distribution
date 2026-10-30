#!/usr/bin/env sh
# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

# Fails when templates/plugins/scripts/diff.sh.tpl drifts from apply.sh.tpl: the plugins templates are rendered
# by furyctl only, so no baseline covers them. diff.sh must stop at the first failure (set -e before the first
# plugin), build each plugin as apply.sh does and run kapp with the apply.sh arguments except -y and -c, plus
# --diff-run --json, writing kapp-diff-<name>.json, with the same shell escaping of the plugin name and folder.

set -e

root="$(cd "$(dirname "$0")/../.." && pwd)"
apply="$root/templates/plugins/scripts/apply.sh.tpl"
diff="$root/templates/plugins/scripts/diff.sh.tpl"
failed=0

# only_line prints the single line of $2 that calls the binary variable $1, or fails.
only_line() {
  lines="$(grep -e "^[$]$1 " "$2" || true)"
  if [ -z "$lines" ] || [ "$(printf '%s\n' "$lines" | wc -l)" -ne 1 ]; then
    echo "FAIL $2: expected exactly one line calling \$$1" >&2
    return 1
  fi
  printf '%s\n' "$lines"
}

apply_build="$(only_line kustomizebin "$apply")"
diff_build="$(only_line kustomizebin "$diff")"
if [ "$diff_build" != "$apply_build" ]; then
  echo "FAIL $diff: kustomize build differs from apply.sh.tpl"
  echo "  apply: $apply_build"
  echo "  diff:  $diff_build"
  failed=1
fi

apply_kapp="$(only_line kappbin "$apply")"
diff_kapp="$(only_line kappbin "$diff")"
want_kapp="$(printf '%s\n' "$apply_kapp" | sed -e 's/ -y / /' -e 's/ -c$//') --diff-run --json > \"kapp-diff-{{ \$name }}.json\""
if [ "$diff_kapp" != "$want_kapp" ]; then
  echo "FAIL $diff: kapp call is not the apply.sh.tpl one without -y and -c, plus --diff-run --json"
  echo "  want: $want_kapp"
  echo "  got:  $diff_kapp"
  failed=1
fi

# The template variables that escape the plugin name and folder for the shell must be the same in both files.
apply_vars="$(grep -e '^{{- [$][a-z]* := ' "$apply" || true)"
diff_vars="$(grep -e '^{{- [$][a-z]* := ' "$diff" || true)"
if [ -z "$apply_vars" ] || [ "$diff_vars" != "$apply_vars" ]; then
  echo "FAIL $diff: the name/folder escaping differs from apply.sh.tpl"
  failed=1
fi

set_e="$(grep -n -x 'set -e' "$diff" | head -n 1 | cut -d: -f1)"
first_plugin="$(grep -n -e '{{ range ' "$diff" | head -n 1 | cut -d: -f1)"
if [ -z "$set_e" ] || [ -z "$first_plugin" ] || [ "$set_e" -gt "$first_plugin" ]; then
  echo "FAIL $diff: set -e must come before the first plugin so a failing plugin stops the script"
  failed=1
fi

[ "$failed" -eq 0 ] && echo "OK plugins diff.sh.tpl is in sync with apply.sh.tpl"
exit "$failed"
