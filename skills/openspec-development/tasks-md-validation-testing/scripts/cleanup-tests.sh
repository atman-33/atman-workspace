#!/bin/bash
# Cleanup script for tasks.md validation tests
# Removes test changes from openspec/changes/ directory

set -e

CHANGES_DIR="openspec/changes"

echo "=========================================="
echo "Cleaning up tasks.md validation tests"
echo "=========================================="
echo ""

# Check if we're in OpenSpec root
if [ ! -d "openspec" ]; then
    echo "Error: Must run from OpenSpec root directory"
    exit 1
fi

# List of test directories
TEST_DIRS=(
    "test-tasks-validation"
    "test-missing-tasks"
    "test-no-checkboxes"
    "test-empty-tasks"
    "test-both-errors"
)

# Check what exists
EXISTING=()
for test_dir in "${TEST_DIRS[@]}"; do
    if [ -d "$CHANGES_DIR/$test_dir" ]; then
        EXISTING+=("$test_dir")
    fi
done

if [ ${#EXISTING[@]} -eq 0 ]; then
    echo "✓ No test files found. Already clean."
    exit 0
fi

echo "Found test directories:"
for test in "${EXISTING[@]}"; do
    echo "  - $CHANGES_DIR/$test"
done
echo ""

read -p "Delete these test directories? (y/N): " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 0
fi

echo ""
echo "🗑️  Removing test directories..."
for test_dir in "${EXISTING[@]}"; do
    rm -rf "$CHANGES_DIR/$test_dir"
    echo "  ✓ Removed $test_dir"
done

echo ""
echo "✅ Cleanup complete!"
echo ""
