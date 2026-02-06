# test-capability Spec Delta

## ADDED Requirements

### Requirement: System SHALL detect missing checkboxes

The system SHALL report an error when tasks.md has no checkboxed tasks.

#### Scenario: No checkboxes

- **WHEN** tasks.md contains only regular list items
- **THEN** validation fails with ERROR level
