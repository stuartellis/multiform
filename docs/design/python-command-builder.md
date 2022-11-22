# Python Command Builder

The command builder is a Python script that uses the Terraform stacks specification to generate Terraform commands.

The current command builder is here:

    python/utils/stackform/stackform.py

- The Python command builder is currently implemented as a Python 3 script.
- The implementation is currently a single file to avoid dependency and deployment issues
- The license is embedded in the file
- The implementation only uses the Python standard library. It requires no additional packages.
- Each run of the command builder returns the string for a single Terraform command, based on the project files and the input parameters.
- The builder does not read environment variables.
- The builder does not execute any Terraform commands. 
- The builder does not create or change any files or state.
- The builder only outputs to standard output and standard error.
