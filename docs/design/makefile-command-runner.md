# Makefiles Terraform Command Runner

- The Makefiles use POSIX shell syntax. This ensures that they can run on any macOS or Linux system.
- The syntax of the Makefiles is compatible with GNU Make 3. Apple only provide Make 3 for macOS, and not any later version. This is probably because newer versions of Make use a GPL 3.0 license.
- The Makefiles are designed to be used as *includes*, so that developers can manage the top-level Makefile and any other Makefiles in the project without conflicts.
- Every target has a prefix, to avoid conflicts with targets that are provided by other Makefiles.
- Every variable has a prefix, to avoid conflicts with other Makefiles.
- The Makefile for running Terraform commands uses the prefix *stack-* for targets and the prefix *ST_* for variables.
- The Makefile for building a Docker container for tools uses the prefix *stackrunner-* for targets and the prefix *ST_RUNNER_* for variables.

## Dependencies

- The Makefiles require *jq*, because standard UNIX shells do not include support for JSON.
- The use of Docker is optional.
- There is no direct dependency on the AWS CLI.
