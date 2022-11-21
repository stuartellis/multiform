# Multiform

Example of a monorepo project with multiple infrastructure components.

Each infrastructure component is a separate Terraform root module. The project uses [Terraform workspaces](https://developer.hashicorp.com/terraform/language/state/workspaces) to support deploying multiple instances of the same component to the same environment.

> /!\ EXPERIMENTAL: This project is under development.

## Dependencies

- Terraform 1.x
- Makefile implementation: A UNIX shell, *GNU Make* 3, *jq*
- Python implementation: Python 3.8 or above

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
    make stack-fmt STACK_NAME=example_app
    make stack-plan STACK_NAME=example_app STACK_INSTANCE=feature1 ENVIRONMENT=prod

---

## TODOs

- Improve jq to read backend file only once.
- Define standard path structure for Parameter Store.
- Provide guidance on handling of secrets.
- Provide guidance on executing commands on multiple stacks.
- Improve guidance on cross-stack references.
- Add self-update for stackform assets
