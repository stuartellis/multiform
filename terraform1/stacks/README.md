# Terraform Stacks

This is the root directory for Terraform stacks.

Each stack is a subdirectory under the *definitions/* directory.

A stack is a Terraform root module. Every stack must include three Terraform variables:

- *environment*
- *stack_name*
- *variant*
