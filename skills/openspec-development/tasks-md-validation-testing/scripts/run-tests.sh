#!/bin/bash
# Run all tasks.md validation tests

set -e

OPENSPEC_CLI="./bin/openspec.js"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "=========================================="
echo "Running tasks.md Validation Tests"
echo "=========================================="
echo ""

# Check if built
if [ ! -f "$OPENSPEC_CLI" ]; then
    echo -e "${RED}Error: CLI not found. Run 'pnpm run build' first${NC}"
    exit 1
fi

# Check if test files exist
if [ ! -d "openspec/changes/test-tasks-validation" ]; then
    echo -e "${RED}Error: Test files not found. Run setup-tests.sh first${NC}"
    exit 1
fi

PASSED=0
FAILED=0

# Helper function to run test
run_test() {
    local test_name="$1"
    local change_id="$2"
    local expected_result="$3"  # "pass" or "fail"
    local description="$4"
    
    echo -e "${BLUE}Test: $test_name${NC}"
    echo "  $description"
    
    if $OPENSPEC_CLI validate "$change_id" 2>&1 | grep -q "is valid"; then
        actual="pass"
    else
        actual="fail"
    fi
    
    if [ "$actual" = "$expected_result" ]; then
        echo -e "  ${GREEN}✓ PASSED${NC} (expected: $expected_result, got: $actual)"
        ((PASSED++))
    else
        echo -e "  ${RED}✗ FAILED${NC} (expected: $expected_result, got: $actual)"
        ((FAILED++))
    fi
    echo ""
}

echo "----------------------------------------"
echo "Individual Test Cases"
echo "----------------------------------------"
echo ""

run_test "1. Valid tasks.md" \
         "test-tasks-validation" \
         "pass" \
         "Should succeed with properly formatted tasks.md"

run_test "2. Missing tasks.md" \
         "test-missing-tasks" \
         "fail" \
         "Should fail when tasks.md is missing"

run_test "3. No checkboxes" \
         "test-no-checkboxes" \
         "fail" \
         "Should fail when tasks.md has no checkboxes"

run_test "4. Empty task descriptions" \
         "test-empty-tasks" \
         "fail" \
         "Should fail when task descriptions are empty"

run_test "5. Both delta and tasks errors" \
         "test-both-errors" \
         "fail" \
         "Should report both delta and tasks errors"

echo "=========================================="
echo "JSON Output Verification"
echo "=========================================="
echo ""

echo -e "${BLUE}Testing JSON output format...${NC}"
if $OPENSPEC_CLI validate test-both-errors --json 2>&1 | jq -e '.items[0].issues | length > 0' > /dev/null 2>&1; then
    echo -e "${GREEN}✓ JSON output contains issues${NC}"
    ((PASSED++))
else
    echo -e "${RED}✗ JSON output verification failed${NC}"
    ((FAILED++))
fi
echo ""

echo "=========================================="
echo "Bulk Validation Test"
echo "=========================================="
echo ""

echo -e "${BLUE}Testing bulk validation...${NC}"
if $OPENSPEC_CLI validate --changes 2>&1 | grep -q "test-"; then
    echo -e "${GREEN}✓ Bulk validation includes test changes${NC}"
    ((PASSED++))
else
    echo -e "${RED}✗ Bulk validation failed${NC}"
    ((FAILED++))
fi
echo ""

echo "=========================================="
echo "Test Summary"
echo "=========================================="
echo ""
echo "Total tests run: $((PASSED + FAILED))"
echo -e "Passed: ${GREEN}$PASSED${NC}"
echo -e "Failed: ${RED}$FAILED${NC}"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}🎉 All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}❌ Some tests failed${NC}"
    exit 1
fi
