# Project Upgrades

- This reference implementation is designed to allow the relevant files to be upgraded when the maintainer of the project chooses.
- The Makefiles are held in a separate directory.
- The Makefiles are designed to be clearly scoped and replaceable.
- This enables a project to be upgraded as new versions of the components are released.
- Since the components are specific files in the project, the upgrade process can be implemented as a script or Make target in the project itself.
