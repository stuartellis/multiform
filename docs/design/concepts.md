# Concepts 

1. This design enables a project to use multiple Terraform root modules. These root modules are referred to as *stacks*.
2. The core of the design is a set of conventions for Terraform projects. These consist of an *expected directory structure* and a set of *code conventions for Terraform stacks*.
3. The settings for a deployment are inferred from the directory structure and Terraform files as much as possible. This reduces the need to maintain additional configuration.
4. A helper program generates Terraform commands. This *command builder* relies on the conventions to produce a complete Terraform command with the correct options. The command builder returns the Terraform command to the caller as a string. The caller is then responsible for executing the command. The helper program does not execute commands, and does not manage the environment where code is executed.
5. Each Terraform command that the builder produces executes on a specific Terraform stack, which is defined by the *expected directory structure*.
6. This example implementation of a project uses a standard set of tools that are provided on current versions of macOS. Linux distributions provide newer versions of the same tools. This means that the project will run on any macOS, WSL or Linux system.
