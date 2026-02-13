---
name: multi-repo-review
description: Cross-repository code review for multi-repo web applications. Use when reviewing changes across multiple repositories to detect inconsistencies in API contracts, type definitions, dependencies, or integration points that single-repo reviews might miss. Triggers on phrases like 'review across repositories', 'check multi-repo changes', 'cross-repo code review', or when working with VSCode workspaces containing multiple project folders.
---

# Multi-Repository Code Review

This skill performs comprehensive code review across multiple repositories to detect cross-repository inconsistencies that single-repo reviews miss.

## Overview

When developing web applications spanning multiple repositories (frontend, backend, shared libraries), each repository's code review in isolation can miss:

- API contract mismatches (endpoint paths, request/response types)
- Type definition inconsistencies across repos
- Dependency version conflicts
- Authentication/authorization flow breaks
- Environment variable naming discrepancies

This skill extracts git diffs from all repositories in a VSCode workspace and performs AI-powered review with configurable guidelines.

## Prerequisites

- VSCode workspace file (`.code-workspace`) or manual repository configuration
- Git repositories with base branches to compare against
- Review guidelines file (default provided)

## Usage

### Step 1: Configure

Edit `config.yaml` in this skill directory:

```yaml
# Workspace file path (null = auto-detect *.code-workspace in current dir)
workspace: null

# Repository list with base branches
repositories:
  - path: ./repo-frontend
    base_branch: main
  - path: ./repo-backend
    base_branch: release/v2.0
  - path: ./repo-shared
    base_branch: develop

# Review guidelines file
review_guidelines: ./.opencode/skills/multi-repo-review/review-guidelines.md

# Output report path
output: ./multi-repo-review-report.md
```

### Step 2: Extract Diffs

Run the extraction script:

```bash
.opencode/skills/multi-repo-review/scripts/extract-diffs.sh
```

This outputs JSON containing:
- Repository paths
- Base branch names
- Full git diffs
- List of changed files

### Step 3: Review

1. Read the JSON output from Step 2
2. Read the review guidelines from `review_guidelines` path
3. Analyze all diffs together, focusing on:
   - Cross-repository consistency issues
   - API contract alignment
   - Type definition mismatches
   - Dependency conflicts
4. Generate markdown report at `output` path

### Step 4: Report Structure

The output report should follow this structure:

```markdown
# Multi-Repository Code Review Report

**Date**: YYYY-MM-DD HH:MM:SS
**Repositories Reviewed**: N

## Summary

Brief overview of findings.

## Critical Issues

Issues requiring immediate attention.

## Warnings

Potential problems that should be reviewed.

## Informational

Minor observations and suggestions.

## Repository Details

### [Repository Name]

- **Base Branch**: branch_name
- **Changed Files**: N files
- **Key Changes**: Summary
```

## Configuration Details

### Auto-Detection of Workspace

If `workspace: null`, the script searches for `*.code-workspace` files in the current directory. If multiple found, uses the first one alphabetically.

### Repository Path Resolution

Paths in `repositories` are resolved relative to the workspace file's directory.

### Base Branch Strategy

Each repository can have a different base branch. Common patterns:
- Production releases: `release`, `release/v*`
- Main development: `main`, `master`, `develop`

### Error Handling

| Error | Behavior |
|-------|----------|
| Repository path not found | Skip with warning in report |
| Base branch doesn't exist | Error and exit |
| Git diff returns empty | Include as "No changes" |
| Review guidelines not found | Error and exit |

## Review Guidelines

See `review-guidelines.md` for the default review checklist. Customize this file to match your project's needs.

Key categories:
- Cross-Repository Consistency
- API Contract Alignment
- Code Quality Standards
- Security Checks
- Dependency Management

## Advanced Usage

### Multiple Guideline Files

For different project types (e.g., frontend-focused vs backend-focused), maintain multiple guideline files and specify in config:

```yaml
review_guidelines: ./guidelines/fullstack-review.md
```

### CI/CD Integration

Run this skill in CI pipelines before merging PRs across multiple repos:

```bash
# In CI script
.opencode/skills/multi-repo-review/scripts/extract-diffs.sh > /tmp/diffs.json
# Then trigger AI review with diffs.json
```

## Implementation Notes

- The extraction script uses `git diff <base_branch>..HEAD` to capture all changes being merged
- JSON output format ensures structured data for AI processing
- Review is performed holistically across all repositories simultaneously
- Output report is human-readable markdown suitable for PR comments or documentation
