#!/usr/bin/env bats
# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

load ./helper

expect_ok() {
    [ "${1}" -eq 0 ]
}

expect_no() {
    [ "${1}" -eq 1 ]
}

test_schema() {
    local KIND=${1}
    local APIVER=${2}
    local EXAMPLE=${3}
    local verify_expectation=${4}
    local validate_status=""
    local validate_output=""
    local verify_expectation_status=""

    TMPDIR=$(mktemp -d -t "fury-distribution-test-XXXXXXXXXX")

    mkdir -p "${TMPDIR}/tests/schemas/${KIND}/${APIVER}"

    yq "tests/schemas/${KIND}/${APIVER}/${EXAMPLE}.yaml" -o json  > "${TMPDIR}/tests/schemas/${KIND}/${APIVER}/${EXAMPLE}.json"

    validate() {
        jv "schemas/${KIND}/${APIVER}.json" "${TMPDIR}/tests/schemas/${KIND}/${APIVER}/${EXAMPLE}.json" 2>&1
    }

    run validate
    validate_status="${status}"
    validate_output="${output}"

    run "${verify_expectation}" "${validate_status}"
    verify_expectation_status="${status}"

    rm -rf "${TMPDIR}"

    if [ "${verify_expectation_status}" -ne 0 ]; then
        echo "${validate_output}" >&3

        return 1
    fi

    return 0
}

@test "001 - ok" {
    info

    test_schema "private" "ekscluster-kfd-v1alpha2" "001-ok" expect_ok
    test_schema "public" "ekscluster-kfd-v1alpha2" "001-ok" expect_ok
}

@test "001 - no" {
    info

    expect() {
        expect_no "${1}"

        local EXPECTED_ERROR_1="at '/spec/kubernetes/vpcId': got string, want null"
        local EXPECTED_ERROR_2="at '/spec/kubernetes/subnetIds': got array, want null"

        if [[ "${output}" != *"${EXPECTED_ERROR_1}"* ]]; then
            return 2
        fi

        if [[ "${output}" != *"${EXPECTED_ERROR_2}"* ]]; then
            return 3
        fi
    }

    test_schema "private" "ekscluster-kfd-v1alpha2" "001-no" expect
    test_schema "public" "ekscluster-kfd-v1alpha2" "001-no" expect
}

@test "002 - ok" {
    info

    test_schema "private" "ekscluster-kfd-v1alpha2" "002-ok" expect_ok
    test_schema "public" "ekscluster-kfd-v1alpha2" "002-ok" expect_ok
}

@test "002 - no" {
    info

    expect() {
        expect_no

        local EXPECTED_ERROR_1="at '/spec/kubernetes': missing properties 'vpcId', 'subnetIds'"

        if [[ "${output}" != *"${EXPECTED_ERROR_1}"* ]]; then
            return 2
        fi
    }

    test_schema "private" "ekscluster-kfd-v1alpha2" "002-no" expect
    test_schema "public" "ekscluster-kfd-v1alpha2" "002-no" expect
}

@test "003 - ok" {
    info

    test_schema "private" "ekscluster-kfd-v1alpha2" "003-ok" expect_ok
    test_schema "public" "ekscluster-kfd-v1alpha2" "003-ok" expect_ok
}

@test "003 - no" {
    info

    expect() {
        expect_no

        local EXPECTED_ERROR_1="at '/spec/distribution/modules/auth/dex': got object, want null"
        local EXPECTED_ERROR_2="at '/spec/distribution/modules/auth/pomerium': got object, want null"

        if [[ "${output}" != *"${EXPECTED_ERROR_1}"* ]]; then
            return 2
        fi

        if [[ "${output}" != *"${EXPECTED_ERROR_2}"* ]]; then
            return 3
        fi
    }

    test_schema "private" "ekscluster-kfd-v1alpha2" "003-no" expect
    test_schema "public" "ekscluster-kfd-v1alpha2" "003-no" expect
}

@test "004 - ok" {
    info

    test_schema "private" "ekscluster-kfd-v1alpha2" "004-ok" expect_ok
    test_schema "public" "ekscluster-kfd-v1alpha2" "004-ok" expect_ok
}

@test "004 - no" {
    info

    expect() {
        expect_no

        local EXPECTED_ERROR_1="at '/spec/distribution/modules/auth/provider': missing property 'basicAuth'"

        if [[ "${output}" != *"${EXPECTED_ERROR_1}"* ]]; then
            return 2
        fi
    }

    test_schema "private" "ekscluster-kfd-v1alpha2" "004-no" expect
    test_schema "public" "ekscluster-kfd-v1alpha2" "004-no" expect
}

@test "005 - ok" {
    info

    test_schema "private" "ekscluster-kfd-v1alpha2" "005-ok" expect_ok
    test_schema "public" "ekscluster-kfd-v1alpha2" "005-ok" expect_ok
}

@test "005 - no" {
    info

    expect() {
        expect_no

        local EXPECTED_ERROR_1="at '/spec/distribution/modules/aws': got object, want null"

        if [[ "${output}" != *"${EXPECTED_ERROR_1}"* ]]; then
            return 2
        fi
    }

    test_schema "private" "ekscluster-kfd-v1alpha2" "005-no" expect
    test_schema "public" "ekscluster-kfd-v1alpha2" "005-no" expect
}

@test "006 - ok" {
    info

    test_schema "private" "ekscluster-kfd-v1alpha2" "006-ok" expect_ok
    test_schema "public" "ekscluster-kfd-v1alpha2" "006-ok" expect_ok
}

@test "006 - no" {
    info

    expect() {
        expect_no

        local EXPECTED_ERROR_1="at '/spec/distribution/modules/ingress/nginx/tls': missing property 'secret'"
        local EXPECTED_ERROR_2="at '/spec/distribution/modules': missing property 'aws'"

        if [[ "${output}" != *"${EXPECTED_ERROR_1}"* ]]; then
            return 2
        fi

        if [[ "${output}" != *"${EXPECTED_ERROR_2}"* ]]; then
            return 2
        fi
    }

    test_schema "private" "ekscluster-kfd-v1alpha2" "006-no" expect
    test_schema "public" "ekscluster-kfd-v1alpha2" "006-no" expect
}

@test "007 - ok" {
    info

    test_schema "private" "ekscluster-kfd-v1alpha2" "007-ok" expect_ok
    test_schema "public" "ekscluster-kfd-v1alpha2" "007-ok" expect_ok
}

@test "007 - no" {
    info

    expect() {
        expect_no

        local EXPECTED_ERROR_1="at '/spec/distribution/modules': missing property 'aws'"

        if [[ "${output}" != *"${EXPECTED_ERROR_1}"* ]]; then
            return 2
        fi
    }

    test_schema "private" "ekscluster-kfd-v1alpha2" "007-no" expect
    test_schema "public" "ekscluster-kfd-v1alpha2" "007-no" expect
}

@test "008 - ok" {
    info

    test_schema "private" "ekscluster-kfd-v1alpha2" "008-ok" expect_ok
    test_schema "public" "ekscluster-kfd-v1alpha2" "008-ok" expect_ok
}

@test "008 - no" {
    info

    expect() {
        expect_no

        local EXPECTED_ERROR_1="at '/spec/distribution/customPatches/patches/0': oneOf failed, subschemas 0, 1 matched"

        if [[ "${output}" != *"${EXPECTED_ERROR_1}"* ]]; then
            return 2
        fi
    }

    test_schema "private" "ekscluster-kfd-v1alpha2" "008-no" expect
    test_schema "public" "ekscluster-kfd-v1alpha2" "008-no" expect
}

@test "009 - ok" {
    info

    test_schema "private" "ekscluster-kfd-v1alpha2" "009-ok" expect_ok
    test_schema "public" "ekscluster-kfd-v1alpha2" "009-ok" expect_ok
}

@test "009 - no" {
    info

    expect() {
        expect_no

        local EXPECTED_ERROR_1="at '/spec/distribution/customPatches/configMapGenerator/0': additional properties 'type' not allowed"

        if [[ "${output}" != *"${EXPECTED_ERROR_1}"* ]]; then
            return 2
        fi
    }

    test_schema "private" "ekscluster-kfd-v1alpha2" "009-no" expect
    test_schema "public" "ekscluster-kfd-v1alpha2" "009-no" expect
}

@test "010 - ok" {
    info

    test_schema "private" "ekscluster-kfd-v1alpha2" "010-ok" expect_ok
    test_schema "public" "ekscluster-kfd-v1alpha2" "010-ok" expect_ok
}

@test "010 - no" {
    info

    expect() {
        expect_no

        local EXPECTED_ERROR_1="at '/spec/infrastructure/vpn/vpcId': got string, want null"

        if [[ "${output}" != *"${EXPECTED_ERROR_1}"* ]]; then
            return 2
        fi
    }

    test_schema "private" "ekscluster-kfd-v1alpha2" "010-no" expect
    test_schema "public" "ekscluster-kfd-v1alpha2" "010-no" expect
}

@test "011 - ok" {
    info

    test_schema "private" "ekscluster-kfd-v1alpha2" "011-ok" expect_ok
    test_schema "public" "ekscluster-kfd-v1alpha2" "011-ok" expect_ok
}

@test "011 - no" {
    info

    expect() {
        expect_no

        local EXPECTED_ERROR_1=" at '/spec/infrastructure/vpn': missing property 'vpcId'"

        if [[ "${output}" != *"${EXPECTED_ERROR_1}"* ]]; then
            return 2
        fi
    }

    test_schema "private" "ekscluster-kfd-v1alpha2" "011-no" expect
    test_schema "public" "ekscluster-kfd-v1alpha2" "011-no" expect
}
