#!/bin/bash
# Test runner for Immutable provider schema validation

set -e

SCHEMA="schemas/public/immutable-kfd-v1alpha2.json"
TEST_DIR="tests/schemas/public/immutable-kfd-v1alpha2"

echo "=========================================="
echo "Testing Immutable Provider Schema"
echo "=========================================="
echo ""

# Test OK cases
echo "=== Testing OK cases (should pass) ==="
ok_count=0
ok_failed=0
for file in ${TEST_DIR}/*-ok.yaml; do
    filename=$(basename "$file")
    echo -n "Testing: $filename ... "
    if jv "$SCHEMA" "$file" > /dev/null 2>&1; then
        echo "✓ PASS"
        ((ok_count++))
    else
        echo "✗ FAIL"
        ((ok_failed++))
        jv "$SCHEMA" "$file" 2>&1 | tail -5
    fi
done

echo ""
echo "=== Testing NO cases (should fail) ==="
no_count=0
no_failed=0
for file in ${TEST_DIR}/*-no.yaml; do
    filename=$(basename "$file")
    echo -n "Testing: $filename ... "
    if jv "$SCHEMA" "$file" > /dev/null 2>&1; then
        echo "✗ FAIL (should have failed validation)"
        ((no_failed++))
    else
        echo "✓ PASS (correctly failed)"
        ((no_count++))
    fi
done

echo ""
echo "=========================================="
echo "Results:"
echo "  OK cases:  $ok_count passed, $ok_failed failed"
echo "  NO cases:  $no_count passed, $no_failed failed"
echo "=========================================="

if [ $ok_failed -gt 0 ] || [ $no_failed -gt 0 ]; then
    exit 1
fi
