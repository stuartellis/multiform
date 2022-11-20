## Terraform Directory Structure 0.4.0

- Each project has a root directory for Terraform code and configuration, called *terraform1/*
- The root directory for the set of Terraform stacks is called *terraform1/stacks/*
- Each stack is a sub-directory under the *terraform1/stacks/definitions/* directory.
- Each environment is a sub-directory under the *terraform1/stacks/environments/* directory.
- The *terraform1/stacks/environments/* directory also contains a subdirectory called *all/*.
- Code for stacks only references or relies upon Terraform modules and files that are under the *terraform1/stacks/* directory and subdirectories. They do not rely on any other files or directories.
