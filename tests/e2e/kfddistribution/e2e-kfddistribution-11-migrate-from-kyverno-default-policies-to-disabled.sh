#!/usr/bin/env bats
# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

# shellcheck disable=SC2154

load ./helper

@test "Verify that kyverno policies have been deleted" {
    info
    test() {
        kubectl get clusterpolicy > check.txt
        if ! grep -q "disallow" check.txt; then
            exit 0
        else
            exit 1
        fi
    }
    loop_it test 60 10
    status=${loop_it_result}
    [ "$status" -eq 0 ]
}
