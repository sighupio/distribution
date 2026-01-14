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

# Helper function to check if error output contains both path and message
# This makes tests resilient to jv version format changes
assert_error_contains() {
    local path="$1"
    local message="$2"

    # Check for path (flexible to different formats: "at '/path'" or "[I#/path]")
    if [[ "${output}" != *"${path}"* ]]; then
        echo "Expected path '${path}' not found in output" >&3
        return 2
    fi

    # Check for error message
    if [[ "${output}" != *"${message}"* ]]; then
        echo "Expected message '${message}' not found in output" >&3
        return 3
    fi
}

# Preflight check: verify jv version and error format
preflight_check() {
    echo "Running preflight checks..." >&3

    # Check if jv is available
    if ! command -v jv >/dev/null 2>&1; then
        echo "ERROR: jv command not found" >&3
        echo "Make sure mise tools are installed and activated" >&3
        return 1
    fi

    # Show which jv is being used
    local JV_PATH
    JV_PATH=$(command -v jv)
    echo "Using jv from: ${JV_PATH}" >&3

    # Create a test to verify error format
    local TMPDIR_TEST
    TMPDIR_TEST=$(mktemp -d -t "fury-jv-preflight-XXXXXXXXXX")

    # Create minimal invalid JSON to test error format
    echo '{"type": "string"}' > "${TMPDIR_TEST}/test-schema.json"
    echo '123' > "${TMPDIR_TEST}/test-instance.json"

    local TEST_OUTPUT
    TEST_OUTPUT=$(jv "${TMPDIR_TEST}/test-schema.json" "${TMPDIR_TEST}/test-instance.json" 2>&1 || true)

    rm -rf "${TMPDIR_TEST}"

    # Check if error format matches v0.7.0 expectations
    if [[ "${TEST_OUTPUT}" == *"got"*"want"* ]]; then
        echo "✓ jv error format verified (v0.7.0)" >&3
        return 0
    elif [[ "${TEST_OUTPUT}" == *"expected"*"but got"* ]]; then
        echo "ERROR: jv is using different error format (older v0.4.0)" >&3
        echo "Expected: 'got X, want Y' (v0.7.0 format)" >&3
        echo "Got: 'expected X, but got Y' (v0.4.0 format)" >&3
        echo "Remove old jv binary and use mise-installed version" >&3
        return 1
    else
        echo "WARNING: Could not verify jv error format" >&3
        echo "Test output: ${TEST_OUTPUT}" >&3
        return 0  # Don't fail, let tests proceed
    fi
}

# Setup function called by bats before all tests
setup_file() {
    # Run preflight check once before all tests
    if ! preflight_check; then
        exit 1
    fi
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

        assert_error_contains "/spec/kubernetes/vpcId" "got string, want null" || return $?
        assert_error_contains "/spec/kubernetes/subnetIds" "got array, want null" || return $?
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
        expect_no "${1}"

        assert_error_contains "/spec/kubernetes" "missing properties" || return $?
        assert_error_contains "/spec/kubernetes" "'vpcId'" || return $?
        assert_error_contains "/spec/kubernetes" "'subnetIds'" || return $?
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
        expect_no "${1}"

        assert_error_contains "/spec/distribution/modules/auth/dex" "got object, want null" || return $?
        assert_error_contains "/spec/distribution/modules/auth/pomerium" "got object, want null" || return $?
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
        expect_no "${1}"

        assert_error_contains "/spec/distribution/modules/auth/provider" "missing property" || return $?
        assert_error_contains "/spec/distribution/modules/auth/provider" "'basicAuth'" || return $?
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
        expect_no "${1}"

        assert_error_contains "/spec/distribution/modules/aws" "got object, want null" || return $?
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
        expect_no "${1}"

        assert_error_contains "/spec/distribution/modules/ingress/nginx/tls" "missing property" || return $?
        assert_error_contains "/spec/distribution/modules/ingress/nginx/tls" "'secret'" || return $?
        assert_error_contains "/spec/distribution/modules" "missing property" || return $?
        assert_error_contains "/spec/distribution/modules" "'aws'" || return $?
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
        expect_no "${1}"

        assert_error_contains "/spec/distribution/modules" "missing property" || return $?
        assert_error_contains "/spec/distribution/modules" "'aws'" || return $?
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
        expect_no "${1}"

        assert_error_contains "/spec/distribution/customPatches/patches/0" "oneOf" || return $?
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
        expect_no "${1}"

        assert_error_contains "/spec/distribution/customPatches/configMapGenerator/0" "additional properties" || return $?
        assert_error_contains "/spec/distribution/customPatches/configMapGenerator/0" "'type'" || return $?
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
        expect_no "${1}"

        assert_error_contains "/spec/infrastructure/vpn/vpcId" "got string, want null" || return $?
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
        expect_no "${1}"

        assert_error_contains "/spec/infrastructure/vpn" "missing property" || return $?
        assert_error_contains "/spec/infrastructure/vpn" "'vpcId'" || return $?
    }

    test_schema "private" "ekscluster-kfd-v1alpha2" "011-no" expect
    test_schema "public" "ekscluster-kfd-v1alpha2" "011-no" expect
}

# ========================================
# Immutable Tests
# ========================================

@test "001 - ok (immutable)" {
    info

    test_schema "public" "immutable-kfd-v1alpha2" "001-ok" expect_ok
}

@test "001 - no (immutable)" {
    info

    expect() {
        expect_no "${1}"

        assert_error_contains "at '':" "missing property 'metadata'" || return $?
    }

    test_schema "public" "immutable-kfd-v1alpha2" "001-no" expect
}

@test "002 - ok (immutable)" {
    info

    test_schema "public" "immutable-kfd-v1alpha2" "002-ok" expect_ok
}

@test "003 - no (immutable)" {
    info

    expect() {
        expect_no "${1}"

        assert_error_contains "/spec/infrastructure/nodes/0" "missing property" || return $?
        assert_error_contains "/spec/infrastructure/nodes/0" "'network'" || return $?
    }

    test_schema "public" "immutable-kfd-v1alpha2" "003-no" expect
}

@test "004 - no (immutable)" {
    info

    expect() {
        expect_no "${1}"

        assert_error_contains "/spec/infrastructure/nodes/0/macAddress" "does not match pattern" || return $?
    }

    test_schema "public" "immutable-kfd-v1alpha2" "004-no" expect
}

@test "005 - no (immutable)" {
    info

    expect() {
        expect_no "${1}"

        # When dhcp4 is false (or not set), addresses field is required
        assert_error_contains "/spec/infrastructure/nodes/0/network/ethernets/eth0" "missing property" || return $?
        assert_error_contains "/spec/infrastructure/nodes/0/network/ethernets/eth0" "'addresses'" || return $?
    }

    test_schema "public" "immutable-kfd-v1alpha2" "005-no" expect
}

# Root and Metadata Tests (006-010)

@test "006 - ok (immutable)" {
    info

    test_schema "public" "immutable-kfd-v1alpha2" "006-ok" expect_ok
}

@test "006 - no (immutable)" {
    info

    expect() {
        expect_no "${1}"

        assert_error_contains "/apiVersion" "does not match pattern" || return $?
    }

    test_schema "public" "immutable-kfd-v1alpha2" "006-no" expect
}

@test "007 - no (immutable)" {
    info

    expect() {
        expect_no "${1}"

        assert_error_contains "/kind" "value must be 'Immutable'" || return $?
    }

    test_schema "public" "immutable-kfd-v1alpha2" "007-no" expect
}

@test "008 - no (immutable)" {
    info

    expect() {
        expect_no "${1}"

        assert_error_contains "/metadata/name" "minLength" || return $?
        assert_error_contains "/metadata/name" "got 0, want 1" || return $?
    }

    test_schema "public" "immutable-kfd-v1alpha2" "008-no" expect
}

@test "009 - no (immutable)" {
    info

    expect() {
        expect_no "${1}"

        assert_error_contains "/metadata/name" "maxLength" || return $?
        assert_error_contains "/metadata/name" "got 57, want 56" || return $?
    }

    test_schema "public" "immutable-kfd-v1alpha2" "009-no" expect
}

@test "010 - no (immutable)" {
    info

    expect() {
        expect_no "${1}"

        assert_error_contains "/spec/distributionVersion" "minLength" || return $?
        assert_error_contains "/spec/distributionVersion" "got 0, want 1" || return $?
    }

    test_schema "public" "immutable-kfd-v1alpha2" "010-no" expect
}

# Infrastructure Core Tests (011-012)

@test "011 - ok (immutable)" {
    info

    test_schema "public" "immutable-kfd-v1alpha2" "011-ok" expect_ok
}

@test "011 - no (immutable)" {
    info

    expect() {
        expect_no "${1}"

        assert_error_contains "/spec/infrastructure" "missing property 'ssh'" || return $?
    }

    test_schema "public" "immutable-kfd-v1alpha2" "011-no" expect
}

@test "012 - no (immutable)" {
    info

    expect() {
        expect_no "${1}"

        assert_error_contains "/spec/infrastructure/nodes" "minItems" || return $?
        assert_error_contains "/spec/infrastructure/nodes" "got 0, want 1" || return $?
    }

    test_schema "public" "immutable-kfd-v1alpha2" "012-no" expect
}

# Networking Tests (026-027)

@test "026 - ok (immutable)" {
    info

    test_schema "public" "immutable-kfd-v1alpha2" "026-ok" expect_ok
}

@test "026 - no (immutable)" {
    info

    expect() {
        expect_no "${1}"

        assert_error_contains "/spec/infrastructure/nodes/0/network" "validation failed" || return $?
    }

    test_schema "public" "immutable-kfd-v1alpha2" "026-no" expect
}

@test "027 - no (immutable)" {
    info

    expect() {
        expect_no "${1}"

        assert_error_contains "/spec/infrastructure/nodes/0/network/ethernets/eth0/addresses/0" "does not match pattern" || return $?
    }

    test_schema "public" "immutable-kfd-v1alpha2" "027-no" expect
}

# Kubernetes Tests (042-043)

@test "042 - ok (immutable)" {
    info

    test_schema "public" "immutable-kfd-v1alpha2" "042-ok" expect_ok
}

@test "042 - no (immutable)" {
    info

    expect() {
        expect_no "${1}"

        assert_error_contains "/spec/kubernetes/controlPlane/address" "does not match pattern" || return $?
    }

    test_schema "public" "immutable-kfd-v1alpha2" "042-no" expect
}

@test "043 - no (immutable)" {
    info

    expect() {
        expect_no "${1}"

        assert_error_contains "/spec/kubernetes/networking/podCIDR" "does not match pattern" || return $?
    }

    test_schema "public" "immutable-kfd-v1alpha2" "043-no" expect
}

# Distribution Modules Tests (063-064)

@test "063 - ok (immutable)" {
    info

    test_schema "public" "immutable-kfd-v1alpha2" "063-ok" expect_ok
}

@test "063 - no (immutable)" {
    info

    expect() {
        expect_no "${1}"

        assert_error_contains "/spec/distribution/modules/networking/type" "value must be one of" || return $?
    }

    test_schema "public" "immutable-kfd-v1alpha2" "063-no" expect
}

@test "064 - no (immutable)" {
    info

    expect() {
        expect_no "${1}"

        assert_error_contains "/spec/distribution/modules/ingress/baseDomain" "does not match pattern" || return $?
    }

    test_schema "public" "immutable-kfd-v1alpha2" "064-no" expect
}

# Edge Cases Tests (093-095)

@test "093 - ok (immutable)" {
    info

    test_schema "public" "immutable-kfd-v1alpha2" "093-ok" expect_ok
}

@test "094 - ok (immutable)" {
    info

    test_schema "public" "immutable-kfd-v1alpha2" "094-ok" expect_ok
}

@test "095 - no (immutable)" {
    info

    expect() {
        expect_no "${1}"

        assert_error_contains "/metadata" "additional properties" || return $?
        assert_error_contains "/metadata" "'extraField'" || return $?
    }

    test_schema "public" "immutable-kfd-v1alpha2" "095-no" expect
}
