#!/usr/bin/env bats
# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

# shellcheck disable=SC2154

load ./helper

@test "Ingress Nginx NS has been deleted" {
    info
    test() {
        kubectl get namespace > check.txt
        if ! grep -q "ingress-nginx" check.txt; then
            exit 0
        else
            exit 1
        fi
    }
    loop_it test 60 10
    status=${loop_it_result}
    [ "$status" -eq 0 ]
}

@test "Pomerium NS is NOT present" {
    info
    test() {
        kubectl get namespace > check.txt
        if ! grep -q "pomerium" check.txt; then
            exit 0
        else
            exit 1
        fi
    }
    loop_it test 60 10
    status=${loop_it_result}
    [ "$status" -eq 0 ]
}

@test "Monitoring NS has been deleted" {
    info
    test() {
        kubectl get namespace > check.txt
        if ! grep -q "monitoring" check.txt; then
            exit 0
        else
            exit 1
        fi
    }
    loop_it test 60 10
    status=${loop_it_result}
    [ "$status" -eq 0 ]
}

@test "Logging NS has been deleted" {
    info
    test() {
        kubectl get namespace > check.txt
        if ! grep -q "logging" check.txt; then
            exit 0
        else
            exit 1
        fi
    }
    loop_it test 60 10
    status=${loop_it_result}
    [ "$status" -eq 0 ]
}

@test "Velero has been deleted" {
    info
    test() {
        kubectl get pods -n kube-system --show-labels > check.txt
        if ! grep -q "velero" check.txt; then
            exit 0
        else
            exit 1
        fi
    }
    loop_it test 60 10
    status=${loop_it_result}
    [ "$status" -eq 0 ]
}
