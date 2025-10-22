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
    if [[ "${TEST_OUTPUT}" == *"expected"*"but got"* ]]; then
        echo "✓ jv error format verified (v0.7.0+)" >&3
        return 0
    elif [[ "${TEST_OUTPUT}" == *"got"*"want"* ]]; then
        echo "ERROR: jv is using old error format (v6.0.1)" >&3
        echo "Expected: 'expected X, but got Y'" >&3
        echo "Got: 'got X, want Y'" >&3
        echo "This indicates jv v0.7.0 from mise.toml is not being used" >&3
        echo "Try: mise exec -- jv --version" >&3
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

        assert_error_contains "/spec/kubernetes/vpcId" "expected null, but got string" || return $?
        assert_error_contains "/spec/kubernetes/subnetIds" "expected null, but got array" || return $?
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

        # Check for missing properties error (jv v0.7.0 format with colon)
        assert_error_contains "/spec/kubernetes" "missing properties:" || return $?
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

        assert_error_contains "/spec/distribution/modules/auth/dex" "expected null, but got object" || return $?
        assert_error_contains "/spec/distribution/modules/auth/pomerium" "expected null, but got object" || return $?
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

        # Check for missing properties error (jv v0.7.0 uses plural even for single property)
        assert_error_contains "/spec/distribution/modules/auth/provider" "missing properties:" || return $?
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

        assert_error_contains "/spec/distribution/modules/aws" "expected null, but got object" || return $?
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

        # Check for missing properties errors (jv v0.7.0 uses plural even for single property)
        assert_error_contains "/spec/distribution/modules/ingress/nginx/tls" "missing properties:" || return $?
        assert_error_contains "/spec/distribution/modules/ingress/nginx/tls" "'secret'" || return $?
        assert_error_contains "/spec/distribution/modules" "missing properties:" || return $?
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

        # Check for missing properties error (jv v0.7.0 uses plural even for single property)
        assert_error_contains "/spec/distribution/modules" "missing properties:" || return $?
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

        assert_error_contains "/spec/distribution/customPatches/configMapGenerator/0" "additionalProperties" || return $?
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

        assert_error_contains "/spec/infrastructure/vpn/vpcId" "expected null, but got string" || return $?
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

        # Check for missing properties error (jv v0.7.0 uses plural even for single property)
        assert_error_contains "/spec/infrastructure/vpn" "missing properties:" || return $?
        assert_error_contains "/spec/infrastructure/vpn" "'vpcId'" || return $?
    }

    test_schema "private" "ekscluster-kfd-v1alpha2" "011-no" expect
    test_schema "public" "ekscluster-kfd-v1alpha2" "011-no" expect
}
