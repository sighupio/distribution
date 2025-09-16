#!/usr/bin/env bats
# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

# shellcheck disable=SC2154

load ./helper

export KUBECONFIG=./kubeconfig

@test "Calico Kube Controller is Running" {
    info
    test() {
        kubectl get pods -l app.kubernetes.io/name=calico-kube-controllers -o json -n calico-system |jq '.items[].status.containerStatuses[].ready' | uniq | grep -q true
    }
    loop_it test 60 10
    status=${loop_it_result}
    [ "$status" -eq 0 ]
}

@test "Calico Node is Running" {
    info
    test() {
        kubectl get pods -l app.kubernetes.io/name=calico-node -o json -n calico-system |jq '.items[].status.containerStatuses[].ready' | uniq | grep -q true
    }
    loop_it test 60 10
    status=${loop_it_result}
    [ "$status" -eq 0 ]
}

@test "Velero is Running" {
    info
    test() {
        kubectl get pods -l k8s-app=velero -o json -n kube-system |jq '.items[].status.containerStatuses[].ready' | uniq | grep -q true
    }
    loop_it test 60 10
    status=${loop_it_result}
    [ "$status" -eq 0 ]
}

# @test "Velero Node Agent is Running" {
#     info
#     test() {
#         kubectl get pods -l k8s-app=velero-node-agent -o json -n kube-system |jq '.items[].status.containerStatuses[].ready' | uniq | grep -q true
#     }
#     loop_it test 60 10
#     status=${loop_it_result}
#     [ "$status" -eq 0 ]
# }

@test "Cert-manager Controller is Running" {
    info
    test() {
        kubectl get pods -l app=cert-manager -o json -n cert-manager |jq '.items[].status.containerStatuses[].ready' | uniq | grep -q true
    }
    loop_it test 60 10
    status=${loop_it_result}
    [ "$status" -eq 0 ]
}

@test "Nginx Ingress Controller is Running" {
    info
    test() {
        kubectl get pods -l app=ingress -o json -n ingress-nginx |jq '.items[].status.containerStatuses[].ready' | uniq | grep -q true
    }
    loop_it test 60 10
    status=${loop_it_result}
    [ "$status" -eq 0 ]
}

@test "Forecastle is Running" {
    info
    test() {
        kubectl get pods -l app=forecastle -o json -n ingress-nginx |jq '.items[].status.containerStatuses[].ready' | uniq | grep -q true
    }
    loop_it test 60 10
    status=${loop_it_result}
    [ "$status" -eq 0 ]
}

@test "Fluentd is Running" {
    info
    test() {
        kubectl get pods -l app.kubernetes.io/name=fluentd -o json -n logging |jq '.items[].status.containerStatuses[].ready' | uniq | grep -q true
    }
    loop_it test 60 10
    status=${loop_it_result}
    [ "$status" -eq 0 ]
}


@test "Grafana is Running" {
    info
    test() {
        kubectl get pods -l app.kubernetes.io/name=grafana -o json -n monitoring |jq '.items[].status.containerStatuses[].ready' | uniq | grep -q true
    }
    loop_it test 60 10
    status=${loop_it_result}
    [ "$status" -eq 0 ]
}

@test "Prometheus Operator is Running" {
    info
    test() {
        kubectl get pods -l app.kubernetes.io/name=prometheus-operator -o json -n monitoring |jq '.items[].status.containerStatuses[].ready' | uniq | grep -q true
    }
    loop_it test 60 10
    status=${loop_it_result}
    [ "$status" -eq 0 ]
}

@test "Kube State Metrics is Running" {
    info
    test() {
        kubectl get pods -l app.kubernetes.io/name=kube-state-metrics -o json -n monitoring |jq '.items[].status.containerStatuses[].ready' | uniq | grep -q true
    }
    loop_it test 60 10
    status=${loop_it_result}
    [ "$status" -eq 0 ]
}

@test "Node Exporter is Running" {
    info
    test() {
        kubectl get pods -l app.kubernetes.io/name=node-exporter -o json -n monitoring |jq '.items[].status.containerStatuses[].ready' | uniq | grep -q true
    }
    loop_it test 60 10
    status=${loop_it_result}
    [ "$status" -eq 0 ]
}

@test "Prometheus is Running" {
    info
    test() {
        kubectl get pods -l app.kubernetes.io/name=prometheus -o json -n monitoring | jq '.items[].status.containerStatuses[].ready' | uniq | grep -q true

    }
    loop_it test 160 10
    status=${loop_it_result}
    [ "$status" -eq 0 ]
}

@test "kube-proxy-metrics is Running" {
    info
    test() {
        kubectl get pods -l k8s-app=kube-proxy-metrics -o json -n monitoring | jq '.items[].status.containerStatuses[].ready' | uniq | grep -q true
    }
    loop_it test 60 10
    status=${loop_it_result}
    [ "$status" -eq 0 ]
}

@test "tempo is Running" {
    info
    test(){
        data=$(kubectl get sts -n tracing -l app.kubernetes.io/component=ingester -o json | jq '.items[] | select(.metadata.name == "tempo-distributed-ingester" and .status.replicas == .status.readyReplicas)')
        if [ "${data}" == "" ]; then return 1; fi
    }
    loop_it test 60 10
    status=${loop_it_result}
    [[ "$status" -eq 0 ]]
}

@test "Kyverno Admission controller is Running" {
    info
    test(){
        readyReplicas=$(kubectl get deploy kyverno-admission-controller -n kyverno -o jsonpath="{.status.readyReplicas}")
        if [ "${readyReplicas}" != "3" ]; then return 1; fi
    }
    loop_it test 60 10
    status=${loop_it_result}
    [[ "$status" -eq 0 ]]
}