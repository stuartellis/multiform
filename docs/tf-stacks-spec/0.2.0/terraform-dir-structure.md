## Terraform Directory Structure 0.2.0

- Each project has a root directory for Terraform code and configuration, called *terraform/*
- The root directory for the set of Terraform stacks is called *terraform/stacks/*
- Each stack is a sub-directory under the *terraform/stacks/definitions/* directory.
- Code for stacks only references or rely upon files that are in the *terraform/stacks/* directory. It ignores other sub-directories under the *terraform/* directory. This enables co-existance with other solutions.

## TODO

- Define how run order lists are defined for multi-stack runs (a directory with sym links per list may be sufficient).
