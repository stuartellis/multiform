# Terraform Command Builder - Version 0.4.0

- The command builder provides the *stack_name*, *environment* and *instance_prefix* as Terraform variables.

## Makefile Implementation of Terraform Command Builder

The current Makefile implementation of the Terraform command builder is here:

    make/tools/stackform/stackform-cli.mk

## Python Implementation of Terraform Command Builder

The current Python implementation of the Terraform command builder is here:

    python/utils/stackform/stackform.py

- The Python command builder is currently implemented as a Python 3 script, but this may change.
- The implementation is currently a single file to avoid dependency and deployment issues
- The license is embedded in the file
- The implementation only uses the Python standard library. It requires no additional packages.
- Each run of the command builder returns the string for a single Terraform command, based on the project files and the input parameters.
- The builder does not read environment variables.
- The builder does not execute any Terraform commands. 
- The builder does not create or change any files or state.
- The builder only outputs to standard output and standard error.
