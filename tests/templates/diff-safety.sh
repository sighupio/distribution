#!/usr/bin/env sh
# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

# Fails when a rendered baseline scripts/diff.sh, or the plugins diff.sh template, could write to the cluster.

set -e

root="$(cd "$(dirname "$0")" && pwd)"
failed=0
count=0

for script in "$root"/*/*/baseline/scripts/diff.sh "$root/../../templates/plugins/scripts/diff.sh.tpl"; do
  [ -f "$script" ] || continue
  count=$((count + 1))
  if grep -n '[$]kubectlbin' "$script" | grep -v ' get '; then
    echo "FAIL $script: kubectl call other than get"
    failed=1
  fi
  if grep -n '[$]kappbin' "$script" | grep -v -e '--diff-run'; then
    echo "FAIL $script: kapp call without --diff-run"
    failed=1
  fi
  if grep -n '[$]kappbin' "$script" | grep -e ' -y\( \|$\)' -e '--yes'; then
    echo "FAIL $script: kapp call with -y or --yes"
    failed=1
  fi
  if grep -n -v '^[[:space:]]*#' "$script" | grep -E '(^|[^$[:alnum:]_/.-])(kubectl|kapp|helm|helmfile)([[:space:]]|$)'; then
    echo "FAIL $script: tool called by name instead of through its bin variable"
    failed=1
  fi
  if grep -n -v '^[[:space:]]*#' "$script" | grep -E "/(kubectl|kapp|helm|helmfile)[\"']?([[:space:];|&)]|$)"; then
    echo "FAIL $script: tool called by path instead of through its bin variable"
    failed=1
  fi
  if grep -n -v '^[[:space:]]*#' "$script" | grep -E '[$][{](kubectlbin|kappbin)'; then
    echo "FAIL $script: bin variable written as \${...}, which the checks above do not inspect"
    failed=1
  fi
done

if [ "$count" -eq 0 ]; then
  echo "FAIL no baseline scripts/diff.sh found"
  exit 1
fi

[ "$failed" -eq 0 ] && echo "OK $count diff.sh scripts are read-only"
exit "$failed"
