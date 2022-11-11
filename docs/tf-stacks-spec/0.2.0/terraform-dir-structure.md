## Terraform Directory Structure 0.2.0

- Each project has single root directory for Terraform code and configuration
- The project root directory for Terraform is called *terraform/stacks/*
- Other sub-directories under the *terraform/* directory are ignored. This enables co-existance with other solutions.
- Each stack is a sub-directory under the *terraform/stacks/definitions/* directory.

## TODO

- Define how run order lists are defined for multi-stack runs (a directory with sym links per list may be sufficient).
