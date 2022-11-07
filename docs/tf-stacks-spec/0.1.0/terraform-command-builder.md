## Terraform Command Builder 0.1.0

- Each run of the command builder returns the string for a single Terraform command, based on the project files and the input parameters.
- The builder does not read environment variables.
- The builder does not execute any Terraform commands. 
- The builder does not create or change any files or state.
- The builder only outputs to standard output and standard error.

## Implementation

- The command builder is currently implemented as a Python 3 script, but this may change.
- The implementation is currently a single file to avoid dependency and deployment issues
- The license is embedded in the file
- The implementation only uses the Python standard library. It requires no additional packages.
- The initial implementation is designed for clarity. It uses a minimal set of the Python language in a functional style.
