#!/usr/bin/env bats
# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

# shellcheck disable=SC2154

load ./helper

@test "Verify that alertmanagerconfigs deadmanswitch have been deleted" {
    info
    test() {
        kubectl get alertmanagerconfigs -n monitoring > check.txt
        if ! grep -q "deadmanswitch" check.txt; then
            exit 0
        else
            exit 1
        fi
    }
    loop_it test 60 10
    status=${loop_it_result}
    [ "$status" -eq 0 ]
}

@test "Verify that alertmanagerconfigs infra have been deleted" {
    info
    test() {
        kubectl get alertmanagerconfigs -n monitoring > check.txt
        if ! grep -q "infra" check.txt; then
            exit 0
        else
            exit 1
        fi
    }
    loop_it test 60 10
    status=${loop_it_result}
    [ "$status" -eq 0 ]
}

@test "Verify that alertmanagerconfigs k8s have been deleted" {
    info
    test() {
        kubectl get alertmanagerconfigs -n monitoring > check.txt
        if ! grep -q "k8s" check.txt; then
            exit 0
        else
            exit 1
        fi
    }
    loop_it test 60 10
    status=${loop_it_result}
    [ "$status" -eq 0 ]
}