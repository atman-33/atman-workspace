---
name: tasks-md-validation-testing
description: Setup and run comprehensive tests for OpenSpec tasks.md validation. Use when needing to verify validation behavior, create test environments, debug validation issues, or ensure validation works correctly.
metadata:
  short-description: Test tasks.md validation
---

# tasks.md Validation Testing

This skill provides a complete testing infrastructure for OpenSpec's tasks.md validation feature. It includes test file templates, automated setup scripts, and comprehensive test scenarios.

## Quick Start

```bash
# 1. Setup test files
bash .claude/skills/tasks-md-validation-testing/scripts/setup-tests.sh

# 2. Build OpenSpec
pnpm run build

# 3. Run all tests
bash .claude/skills/tasks-md-validation-testing/scripts/run-tests.sh

# 4. Cleanup (optional)
bash .claude/skills/tasks-md-validation-testing/scripts/cleanup-tests.sh
```

## Overview

The tasks.md validation feature ensures that OpenSpec changes include properly formatted implementation checklists. This skill provides a self-contained test environment with:

- **5 test scenarios** covering all validation cases
- **Automated setup** from bundled templates
- **Comprehensive test runner** with colored output
- **Easy cleanup** to restore clean state

## Bundled Resources

### Scripts

- **`setup-tests.sh`**: Creates test changes from templates in `assets/test-files/`
- **`run-tests.sh`**: Executes all test scenarios and reports results
- **`cleanup-tests.sh`**: Removes test changes from workspace

### Assets

- **`test-files/`**: Complete test change templates for 5 scenarios
  - Each includes `proposal.md`, `specs/`, and `tasks.md` (except test-missing-tasks)
  - Ready to copy into `openspec/changes/`

## Workflow

### 1. Setup

The setup script copies bundled test templates to your workspace:

```bash
bash .claude/skills/tasks-md-validation-testing/scripts/setup-tests.sh
```

This creates 5 test changes in `openspec/changes/`:
- `test-tasks-validation` - Valid reference
- `test-missing-tasks` - Missing file test
- `test-no-checkboxes` - Format error test
- `test-empty-tasks` - Content error test
- `test-both-errors` - Multiple errors test

The script will:
- Check for existing test files and prompt to overwrite
- Copy all templates from `assets/test-files/`
- Display summary of created changes

### 2. Build

Ensure OpenSpec is built before testing:

```bash
pnpm run build
```

### 3. Run Tests

Execute all test scenarios with automated verification:

```bash
bash .claude/skills/tasks-md-validation-testing/scripts/run-tests.sh
```

The test runner will:
- Verify CLI is built
- Check test files exist
- Run 5 individual test cases
- Test JSON output format
- Test bulk validation
- Display summary with pass/fail counts

Output includes:
- ✓/✗ status for each scenario
- Color-coded results (green=pass, red=fail)
- Expected vs actual results
- Total pass/fail counts

### 4. Cleanup

Remove test files when done:

```bash
bash .claude/skills/tasks-md-validation-testing/scripts/cleanup-tests.sh
```

The cleanup script will:
- List found test directories
- Prompt for confirmation before deletion
- Remove all test changes

## Test Scenarios

### 1. Valid Tasks.md (Success)
**Location**: `openspec/changes/test-tasks-validation/`

**File Content**:
```markdown
- [ ] Implement validation logic
- [x] Add test cases
- [ ] Update documentation
```

**Expected Output**:
```
✓ Change test-tasks-validation is valid
```

### 2. Missing Tasks.md (ERROR)
**Location**: `openspec/changes/test-missing-tasks/`

**Setup**: No `tasks.md` file exists

**Expected Output**:
```
✗ ERROR: Missing required file: tasks.md
```

### 3. No Checkboxes (ERROR)
**Location**: `openspec/changes/test-no-checkboxes/`

**File Content**:
```markdown
- Implement validation logic
- Add test cases
```

**Expected Output**:
```
✗ ERROR: No checkboxed tasks found. Add tasks with [ ] or [x] checkboxes.
```

### 4. Empty Task Descriptions (ERROR)
**Location**: `openspec/changes/test-empty-tasks/`

**File Content**:
```markdown
- [x]
- [ ]
- [ ] Valid task
```

**Expected Output**:
```
✗ ERROR: Empty task description at line 1
✗ ERROR: Empty task description at line 2
```

### 5. Multiple Errors (Both Delta and Tasks)
**Location**: `openspec/changes/test-both-errors/`

**Setup**: Both files exist but have format errors
- `tasks.md`: No checkboxes (only plain list items)
- `specs/test-capability/spec.md`: Requirement without Scenario block

**Expected Output**:
```
✗ ERROR: test-capability/spec.md: ADDED "Test requirement without scenario" must include at least one scenario
✗ ERROR: tasks.md: tasks.md must contain at least one checkboxed task
```

## Manual Testing (Advanced)

If you need to test specific scenarios not covered by the bundled templates:

```bash
# Create custom test change
mkdir -p openspec/changes/my-test/specs/test-capability

# Create files
echo "# Proposal" > openspec/changes/my-test/proposal.md
echo "# Spec" > openspec/changes/my-test/specs/test-capability/spec.md
echo "- [ ] Task" > openspec/changes/my-test/tasks.md

# Validate
./bin/openspec.js validate my-test
```

## Validation Rules

### File Existence (ERROR)
- `tasks.md` must exist in the change directory
- Validation fails immediately if file is missing

### Checkbox Presence (ERROR)
- At least one line must have a checkbox format
- Valid formats: `- [ ]`, `- [x]`, `- [X]`
- Invalid formats: `- []`, `* [ ]`, plain text

### Task Descriptions (ERROR)
- Checkboxed lines must have non-empty descriptions
- Reports line numbers for each empty task
- Example: `- [ ]` (empty) vs `- [ ] Task` (valid)

### Format Patterns
```javascript
// Checkbox detection (any checkbox)
/^[-*]\s+\[[xX\s]\]/

// Empty task detection (checkbox with no description)
/^[-*]\s+\[[xX\s]\]\s*$/
```

## Testing Commands Reference

### Individual Tests
```bash
# Test each scenario individually
./bin/openspec.js validate test-tasks-validation
./bin/openspec.js validate test-missing-tasks
./bin/openspec.js validate test-no-checkboxes
./bin/openspec.js validate test-empty-tasks
./bin/openspec.js validate test-both-errors
```

### JSON Output
```bash
# Get machine-readable JSON
./bin/openspec.js validate test-both-errors --json

# Pretty print with jq
./bin/openspec.js validate test-both-errors --json | jq .

# Extract validation issues
./bin/openspec.js validate test-both-errors --json | jq '.items[0].issues'

# Count errors
./bin/openspec.js validate test-both-errors --json | jq '.items[0].issues | length'
```

### Bulk Validation
```bash
# Validate all changes
./bin/openspec.js validate --changes

# Validate with strict mode
./bin/openspec.js validate --changes --strict

# JSON output for all changes
./bin/openspec.js validate --changes --json
```

## Expected Results

| Test Case | Exit Code | Error Count | Key Validation |
|-----------|-----------|-------------|----------------|
| test-tasks-validation | 0 | 0 | Valid format |
| test-missing-tasks | 1 | 1 | File existence |
| test-no-checkboxes | 1 | 1 | Checkbox presence |
| test-empty-tasks | 1 | 2+ | Task descriptions |
| test-both-errors | 1 | 2+ | Multiple files |

## Debugging Tips

### 1. Verify Test Files Exist
```bash
ls -la openspec/changes/test-*/
```

### 2. Check File Content
```bash
cat openspec/changes/test-empty-tasks/tasks.md
```

### 3. Test Regex Patterns
```bash
node -e "
const pattern = /^[-*]\s+\[[xX\s]\]/;
console.log(pattern.test('- [ ] Task')); // true
console.log(pattern.test('- [x] Task')); // true
console.log(pattern.test('- [] Task'));  // false
"
```

### 4. Verify Line Numbers
For empty task errors, check reported line numbers match actual file:
```bash
grep -n "^\- \[[xX ]\]\s*$" openspec/changes/test-empty-tasks/tasks.md
```

### 5. Compare with Known Good
Use `test-tasks-validation` as reference for correct format:
```bash
diff openspec/changes/test-tasks-validation/tasks.md openspec/changes/my-test/tasks.md
```

## Common Issues

### Tests Fail: "CLI not found"
**Cause**: OpenSpec not built
**Solution**: Run `pnpm run build`

### Tests Fail: "Test files not found"
**Cause**: Setup script not run
**Solution**: Run `bash .claude/skills/tasks-md-validation-testing/scripts/setup-tests.sh`

### Test Shows Wrong Result
**Cause**: Stale build after code changes
**Solution**: Run `pnpm run build` before testing

### Cleanup Doesn't Remove Files
**Cause**: Permission issues or wrong directory
**Solution**: Run from OpenSpec root, check file permissions

### JSON Output Invalid
**Cause**: Validation errors sent to stderr
**Solution**: Use `2>&1` to merge streams: `./bin/openspec.js validate test --json 2>&1 | jq`

## Integration with CI

### GitHub Actions Example
```yaml
- name: Setup validation tests
  run: bash .claude/skills/tasks-md-validation-testing/scripts/setup-tests.sh

- name: Build OpenSpec
  run: pnpm run build

- name: Run validation tests
  run: bash .claude/skills/tasks-md-validation-testing/scripts/run-tests.sh

- name: Cleanup
  if: always()
  run: bash .claude/skills/tasks-md-validation-testing/scripts/cleanup-tests.sh
```

## File Structure

```
.claude/skills/tasks-md-validation-testing/
├── SKILL.md                                    # This file
├── scripts/
│   ├── setup-tests.sh                          # Setup test environment
│   ├── run-tests.sh                            # Execute all tests
│   └── cleanup-tests.sh                        # Remove test files
└── assets/
    └── test-files/                             # Test templates
        ├── test-tasks-validation/
        │   ├── proposal.md
        │   ├── tasks.md
        │   └── specs/test-capability/spec.md
        ├── test-missing-tasks/
        │   ├── proposal.md
        │   └── specs/test-capability/spec.md
        ├── test-no-checkboxes/
        │   ├── proposal.md
        │   ├── tasks.md
        │   └── specs/test-capability/spec.md
        ├── test-empty-tasks/
        │   ├── proposal.md
        │   ├── tasks.md
        │   └── specs/test-capability/spec.md
        └── test-both-errors/
            └── proposal.md
```

## Related Documentation

- [OpenSpec Validation Guide](../../../docs/policies/testing-policy.md)
- [tasks.md Format Specification](../../../openspec/specs/cli-validate/spec.md)
- [Implementation Details](../../../src/core/validation/validator.ts)
