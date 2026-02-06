---
name: create-pr-with-pr-assistant
description: 'Analyzes git changes and creates comprehensive pull requests using the pr-assistant skill. Use when you need to create a well-structured PR with detailed descriptions.'
model: Claude Haiku 4.5 (copilot)
tools: ['vscode', 'execute', 'read', 'edit', 'search', 'terminal-runner/*', 'todo']
---

# Create Pull Request

Use the **pr-assistant** skill to analyze current branch changes and create a comprehensive pull request.

## Instructions

1. Load and follow the `pr-assistant` skill from `.claude/skills/pr-assistant/SKILL.md`
2. Execute the complete workflow defined in the skill
3. **IMPORTANT**: Present the generated PR draft to the user for review and approval before creating the PR

## Success Criteria

- Changes are accurately analyzed and categorized
- PR description is clear, comprehensive, and follows best practices
- User has reviewed and approved the PR content
- PR is successfully created with appropriate reviewers and labels

## Notes

- Never auto-create PRs without explicit user confirmation
- Allow user to edit and refine the PR description before submission
