# test-capability Spec Delta

## ADDED Requirements

### Requirement: System SHALL detect empty task descriptions

The system SHALL report an error when tasks.md contains empty task descriptions.

#### Scenario: Empty task

- **WHEN** a task checkbox has no description
- **THEN** validation fails with ERROR level
- **AND** error includes line number
