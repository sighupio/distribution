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

@test "001 - ok (pomerium override accepted)" {
    info

    test_schema "public" "onpremises-kfd-v1alpha2" "001-ok" expect_ok
}

@test "002 - ok (dex + gangplank + pomerium overrides)" {
    info

    test_schema "public" "onpremises-kfd-v1alpha2" "002-ok" expect_ok
}

@test "003 - no (pomerium override missing ingressClass)" {
    info

    expect() {
        expect_no "${1}"

        assert_error_contains "/spec/distribution/modules/auth/overrides/ingresses/pomerium" "missing property" || return $?
        assert_error_contains "/spec/distribution/modules/auth/overrides/ingresses/pomerium" "'ingressClass'" || return $?
    }

    test_schema "public" "onpremises-kfd-v1alpha2" "003-no" expect
}
