#!/usr/bin/env python3
"""
Create a pull request from current branch to origin/main.
Includes safety checks to prevent accidentally targeting upstream/main.
"""

import subprocess
import sys
import json
from pathlib import Path


def run_command(cmd, check=True, capture=True):
    """Run a shell command and return output."""
    try:
        if capture:
            result = subprocess.run(
                cmd,
                shell=True,
                check=check,
                capture_output=True,
                text=True
            )
            return result.stdout.strip()
        else:
            subprocess.run(cmd, shell=True, check=check)
            return None
    except subprocess.CalledProcessError as e:
        print(f"Error running command: {cmd}")
        print(f"Error: {e.stderr}")
        sys.exit(1)


def get_current_branch():
    """Get the current git branch name."""
    return run_command("git branch --show-current")


def get_remote_url(remote="origin"):
    """Get the URL for a git remote."""
    return run_command(f"git remote get-url {remote}", check=False)


def get_repo_info():
    """Get repository owner and name from origin remote."""
    url = get_remote_url("origin")
    if not url:
        print("Error: origin remote not found")
        sys.exit(1)
    
    # Parse URL (both SSH and HTTPS formats)
    # SSH: git@github.com:owner/repo.git
    # HTTPS: https://github.com/owner/repo.git
    if url.startswith("git@"):
        parts = url.split(":")[-1].replace(".git", "").split("/")
    else:
        parts = url.replace(".git", "").split("/")[-2:]
    
    return f"{parts[0]}/{parts[1]}"


def get_commit_messages(base_branch="main"):
    """Get commit messages that will be in the PR."""
    # Fetch latest main
    run_command(f"git fetch origin {base_branch}", capture=False)
    
    # Get commits not in origin/main
    commits = run_command(
        f"git log origin/{base_branch}..HEAD --pretty=format:'%s' --reverse"
    )
    return commits.split("\n") if commits else []


def generate_pr_title(branch_name, commits):
    """Generate PR title from branch name and commits."""
    # Clean up branch name
    if branch_name.startswith("feature/"):
        prefix = "Add"
        name = branch_name.replace("feature/", "")
    elif branch_name.startswith("fix/") or branch_name.startswith("bugfix/"):
        prefix = "Fix"
        name = branch_name.replace("fix/", "").replace("bugfix/", "")
    else:
        prefix = "Update"
        name = branch_name
    
    # Convert dashes/underscores to spaces and title case
    name = name.replace("-", " ").replace("_", " ").title()
    
    # If commits available, use first commit as hint
    if commits and commits[0]:
        return commits[0]  # Use first commit message as title
    
    return f"{prefix} {name}"


def generate_pr_body(commits):
    """Generate PR description from commit messages."""
    if not commits or not commits[0]:
        return "No description provided."
    
    # If single commit, use it as description
    if len(commits) == 1:
        return commits[0]
    
    # Multiple commits: create list
    body = "This PR includes the following changes:\n\n"
    for commit in commits:
        if commit:  # Skip empty lines
            body += f"- {commit}\n"
    
    return body


def push_branch_if_needed(branch_name, remote="origin"):
    """Push branch to remote if it doesn't exist there."""
    # Check if branch exists on remote
    try:
        run_command(f"git rev-parse refs/remotes/{remote}/{branch_name}", check=True)
        print(f"✓ Branch already exists on {remote}")
        return True
    except:
        # Branch doesn't exist on remote, push it
        print(f"\nPushing {branch_name} to {remote}...")
        run_command(f"git push -u {remote} {branch_name}", capture=False)
        print(f"✓ Branch pushed to {remote}")
        return True


def confirm_target(current_branch, remote, base_branch, repo):
    """Ask user to confirm the PR target."""
    print("\n" + "="*60)
    print("PR Configuration:")
    print("="*60)
    print(f"Current branch:  {current_branch}")
    print(f"Target remote:   {remote}")
    print(f"Target branch:   {base_branch}")
    print(f"Repository:      {repo}")
    print("="*60)
    
    response = input("\nIs this correct? (y/n): ").lower().strip()
    return response in ["y", "yes"]


def create_pr(base_branch, head_branch, repo, title, body):
    """Create a pull request using GitHub CLI."""
    # Check if gh is installed
    try:
        run_command("gh --version", capture=False)
    except:
        print("\nError: GitHub CLI (gh) is not installed")
        print("Install it with: sudo apt install gh")
        print("Or visit: https://cli.github.com/")
        sys.exit(1)
    
    # Create PR using subprocess directly for proper argument handling
    print("\nCreating pull request...")
    try:
        cmd = [
            "gh", "pr", "create",
            "--base", base_branch,
            "--head", head_branch,
            "--repo", repo,
            "--title", title,
            "--body", body
        ]
        result = subprocess.run(
            cmd,
            check=True,
            capture_output=True,
            text=True
        )
        print(result.stdout)
        print("✓ Pull request created successfully!")
    except subprocess.CalledProcessError as e:
        print(f"Error creating PR: {e.stderr}")
        sys.exit(1)


def main():
    """Main script execution."""
    # Configuration
    DEFAULT_REMOTE = "origin"
    DEFAULT_BASE_BRANCH = "main"
    
    print("PR to Origin/Main - Pull Request Creator")
    print("=" * 60)
    
    # Step 1: Check current branch
    current_branch = get_current_branch()
    if current_branch == DEFAULT_BASE_BRANCH:
        print(f"Error: You are already on the {DEFAULT_BASE_BRANCH} branch")
        print("Please switch to your feature branch first")
        sys.exit(1)
    
    # Step 2: Get repository info
    repo = get_repo_info()
    
    # Step 3: Get commits for PR content
    print("\nFetching commits...")
    commits = get_commit_messages(DEFAULT_BASE_BRANCH)
    
    # Step 4: Generate PR content
    title = generate_pr_title(current_branch, commits)
    body = generate_pr_body(commits)
    
    print(f"\nGenerated PR Title: {title}")
    print(f"Generated PR Body:\n{body}")
    
    # Step 5: Confirm with user
    if not confirm_target(current_branch, DEFAULT_REMOTE, DEFAULT_BASE_BRANCH, repo):
        print("\nAborted by user")
        sys.exit(0)
    
    # Step 6: Push branch if needed
    push_branch_if_needed(current_branch, DEFAULT_REMOTE)
    
    # Step 7: Create PR
    create_pr(DEFAULT_BASE_BRANCH, current_branch, repo, title, body)


if __name__ == "__main__":
    main()
