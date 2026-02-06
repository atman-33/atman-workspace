# test-capability Spec Delta

## ADDED Requirements

### Requirement: System SHALL detect missing tasks.md

The system SHALL report an error when tasks.md is missing.

#### Scenario: Missing tasks file

- **WHEN** tasks.md does not exist
- **THEN** validation fails with ERROR level
