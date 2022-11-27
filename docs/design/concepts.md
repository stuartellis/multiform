# Concepts 

1. This design enables a project to use multiple Terraform root modules. These root modules are referred to as *stacks*.
2. The core of the design is a set of conventions for Terraform projects. These consist of a *specification* that defines the expected directory structure and code conventions for Terraform stacks.
3. The *tools* use the conventions to construct and executes Terraform commands.

## The Stacks Specification

The specification:

- Enables multiple tools to work with the same sets of files.
- Only requires the absolute minimum that is needed.
- Uses JSON for configuration, so that it does not restrict the tools that can be used.
- Is specifically designed to enable stacks to be added to an existing project.
- Explicitly does not specify dependencies between stacks. The order of execution for stacks is determined by the user or automation that calls the runner. This enables you to orchestrate processes as needed. For example, you can write a CI pipeline that deploys a stack and then performs other tasks before deploying another stack.

## The Stack Tools

- Stack Tools may be implemented with any programming language or command-line utilities.
- The implementation of Stack Tools that is provided has a minimal set of dependencies. This ensures that it can be used on any UNIX-based system, including macOS, Linux and WSL. This also reduces maintenance.
