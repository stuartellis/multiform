# Multiform

Example of a monorepo project with multiple infrastructure components. Each infrastructure component is a separate Terraform root module.

> /!\ EXPERIMENTAL: This project is under development.

## Dependencies

- Bash 4 or above
- Git 2.32 or above
- GNU Make 3 or above
- Terraform 1.x
- Python 3.8 or above for Python helper script

## Setup

This project includes the configuration for a [Development Container](https://containers.dev/). The Development Container provides a Linux development environment with all of the dependencies that the project requires.

To use a development container with Visual Studio Code:

1. Ensure that Docker is running
2. Ensure that the **Dev Containers** extension is installed on Visual Studio Code
3. Open the project as a folder in Visual Studio Code
4. Accept the option to reopen the project in a container when prompted.

## Usage

Use Make to run the appropriate tasks.

The *info* task provides current settings:

    make info

Use *make clean* to delete all generated files:

    make clean

Make targets for Terraform stacks use the prefix *stack-*. For example:

    make stack-info
    make stack-fmt STACK=example_app
    make stack-plan STACK=example_app ENVIRONMENT=prod

---

## TODOs

- Determine whether to use Terraform workspaces to implement stack instances.
- Standardise backend config settings.
- Standardise path for remote state files.
- Define handling of separator characters in identifiers.
- Define standard path structure for Parameter Store.
- Provide guidance on handling of secrets.
- Provide guidance on executing commands on multiple stacks.
- Improve guidance on cross-stack references.
