## Terraform Directory Structure 0.2.0

- Each project has a root directory for Terraform code and configuration, called *terraform/*
- The root directory for the set of Terraform stacks is called *terraform/stacks/*
- Each stack is a sub-directory under the *terraform/stacks/definitions/* directory.
- Code for stacks only references or relies upon files that are under the *terraform/stacks/* directory and subdirectories. They do not rely on any other files or directories.
- Stacks never use any other directories under the *terraform/* directory except *terraform/stacks/*. This enables co-existance with other tools and solutions.

## TODO

- Define how run order lists are defined for multi-stack runs (a directory with sym links per list may be sufficient).
