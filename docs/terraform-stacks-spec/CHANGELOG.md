# Changelog

All notable changes to the specification will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this specification adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Add specification for Terraform backend.
- Add examples and diagrams.
- Add private Terraform modules.
- Use Terraform workspaces.
- Add template/ directory for definitions
- Add reserved words.

### Changed

- Consolidate specification into one *README.md* file.
- Change root directory for Terraform code from *terraform/* to *terraform1/* to avoid conflicts.

## [0.3.0] - 2022-11-15

### Added

- Add specification for environments.

### Changed

- Split conventions into requirements and guidelines.

## [0.2.0] - 2022-11-14

### Added

- Define terraform/stacks directory as a *set* of stacks, to abstract the group of stacks from the host project
- Specify a terraform/stacks/definitions/ as the parent directory for stacks, to support side-by-side.

### Changed

- Specify terraform/stacks/ as the root directory, to support side-by-side.

## [0.1.0] - 2022-11-05

### Added

- Initial version

### Changed

- N/A
