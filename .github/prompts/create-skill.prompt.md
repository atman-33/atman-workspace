---
name: create-skill
description: Generate a new skill using the skill-creator
---
Use the `skill-creator` to generate a new skill following the established guidelines.

# Instructions

1.  **Understand the Guidelines**:
    - Read `.system/skill-creator/SKILL.md` to understand the core principles of skill creation (Conciseness, Degrees of Freedom, Structure).
    - Ensure the new skill adheres to these principles.

2.  **Understand the Goal**:
    - Identify the purpose and functionality of the skill the user wants to create.
    - Determine the appropriate structure (Workflow, Task, Reference, or Capabilities) based on the guidelines.

3.  **Invoke skill-creator**:
    - Locate the `skill-creator` scripts (usually in `.system/skill-creator/scripts/`).
    - Use the `init_skill.py` script to scaffold the new skill.
    - If arguments are needed (like name, path), infer them or ask.

4.  **Refine Content**:
    - Update the generated `SKILL.md` with specific instructions.
    - Ensure the `description` in frontmatter is clear and comprehensive (as this is what triggers the skill).
    - Remove unused sections or TODOs.

5.  **Verify**:
    - Ensure the skill is created in the correct location.
    - Verify the directory structure matches the guidelines.