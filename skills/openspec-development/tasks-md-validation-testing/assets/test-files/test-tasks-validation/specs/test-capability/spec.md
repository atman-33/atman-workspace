# test-capability Spec Delta

## ADDED Requirements

### Requirement: Test feature SHALL validate tasks

The system SHALL validate tasks.md format and content.

#### Scenario: Valid tasks file

- **WHEN** validating a change with properly formatted tasks.md
- **THEN** validation succeeds
- **AND** no errors are reported

### Requirement: System SHALL report clear error messages

The system SHALL provide clear error messages when validation fails.

#### Scenario: Missing tasks file

- **WHEN** tasks.md does not exist
- **THEN** an error is reported with message "tasks.md is required for OpenSpec changes"
