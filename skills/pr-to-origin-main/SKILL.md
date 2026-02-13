---
name: pr-to-origin-main
description: Create a pull request from current development branch to origin/main (not upstream/main). Use when you need to merge a feature branch into the main branch of your fork and want to ensure the PR targets origin/main with English descriptions. Always confirms remote target with user before creation to prevent accidentally creating PRs to upstream repositories.
---

# PR to Origin/Main

## Overview

This skill automates the creation of pull requests from development branches (feature/xxx, bugfix/xxx, etc.) to origin/main. It includes safeguards to prevent accidentally creating PRs to upstream/main.

## When to Use

- You're on a development branch and want to create a PR to merge into main
- You need to ensure the PR targets origin/main, not upstream/main
- You want the PR title and description in English

## Quick Start

Create a PR from current branch to origin/main:

```bash
python3 .claude/skills/pr-to-origin-main/scripts/create_pr.py
```

The script will:
1. Check that you're not on the main branch
2. Detect the current branch name
3. Fetch latest changes from origin
4. Show you the target remote and ask for confirmation
5. Generate an English PR title and description based on recent commits
6. Create the PR using GitHub CLI (`gh pr create`)

## Prerequisites

- **GitHub CLI**: Must be installed and authenticated
  ```bash
  # Check if gh is installed
  gh --version
  
  # Authenticate if needed
  gh auth login
  ```

- **Git remotes**: Repository must have origin configured
  ```bash
  # Check remotes
  git remote -v
  ```

## Workflow

### Step 1: Verify Current Branch

The script ensures you're not on main:

```bash
# Get current branch
current_branch=$(git branch --show-current)

if [ "$current_branch" = "main" ]; then
  echo "Error: Already on main branch"
  exit 1
fi
```

### Step 2: Confirm Target Remote

The script shows the detected configuration and asks for confirmation:

```
Current branch: feature/new-thing
Target remote: origin
Target branch: main

Is this correct? (y/n):
```

This prevents accidentally creating PRs to upstream/main.

### Step 3: Generate PR Content

The script analyzes recent commits to generate:
- PR title (from branch name and first commit)
- PR description (from commit messages)

All content is generated in English.

### Step 4: Create PR

Using GitHub CLI:

```bash
gh pr create \
  --base main \
  --head feature/new-thing \
  --repo owner/repo \
  --title "Add new feature" \
  --body "Description of changes..."
```

## Options

Edit the script to customize:

```python
# In .claude/skills/pr-to-origin-main/scripts/create_pr.py

# Change default remote if needed
DEFAULT_REMOTE = "origin"

# Change default base branch if needed
DEFAULT_BASE_BRANCH = "main"
```

## Troubleshooting

**Issue**: GitHub CLI not found
- **Solution**: Install gh: `sudo apt install gh` (WSL/Linux) or download from https://cli.github.com/

**Issue**: Not authenticated
- **Solution**: Run `gh auth login` and follow prompts

**Issue**: Remote not found
- **Solution**: Check your git remotes with `git remote -v`

**Issue**: PR already exists
- **Solution**: Check existing PRs with `gh pr list` and close or update as needed
