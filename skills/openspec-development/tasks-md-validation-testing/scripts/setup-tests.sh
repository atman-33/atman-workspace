#!/bin/bash
# Setup script for tasks.md validation tests
# Creates test changes in openspec/changes/ directory

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"
TEST_FILES_DIR="$SKILL_DIR/assets/test-files"
CHANGES_DIR="openspec/changes"

echo "=========================================="
echo "Setting up tasks.md validation tests"
echo "=========================================="
echo ""

# Check if we're in OpenSpec root
if [ ! -d "openspec" ]; then
    echo "Error: Must run from OpenSpec root directory"
    exit 1
fi

# Create changes directory if it doesn't exist
mkdir -p "$CHANGES_DIR"

# Check for existing test files and warn
EXISTING_TESTS=()
for test_dir in test-tasks-validation test-missing-tasks test-no-checkboxes test-empty-tasks test-both-errors; do
    if [ -d "$CHANGES_DIR/$test_dir" ]; then
        EXISTING_TESTS+=("$test_dir")
    fi
done

if [ ${#EXISTING_TESTS[@]} -gt 0 ]; then
    echo "⚠️  Warning: Found existing test directories:"
    for test in "${EXISTING_TESTS[@]}"; do
        echo "  - $CHANGES_DIR/$test"
    done
    echo ""
    read -p "Overwrite existing tests? (y/N): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 0
    fi
    echo ""
fi

# Copy test files
echo "📁 Copying test files..."
cp -r "$TEST_FILES_DIR"/* "$CHANGES_DIR/"

echo ""
echo "✅ Test setup complete!"
echo ""
echo "Test changes created:"
echo "  - test-tasks-validation  (✓ valid tasks.md)"
echo "  - test-missing-tasks     (✗ missing tasks.md)"
echo "  - test-no-checkboxes     (✗ no checkboxes)"
echo "  - test-empty-tasks       (✗ empty descriptions)"
echo "  - test-both-errors       (✗ delta + tasks errors)"
echo ""
echo "Next steps:"
echo "  1. Build: pnpm run build"
echo "  2. Run tests: bash $SCRIPT_DIR/run-tests.sh"
echo "  3. Cleanup: bash $SCRIPT_DIR/cleanup-tests.sh"
echo ""
