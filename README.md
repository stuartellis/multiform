# Multiform

Example of a monorepo project with multiple infrastructure components.

Each infrastructure component is a separate Terraform root module. The project uses [Terraform workspaces](https://developer.hashicorp.com/terraform/language/state/workspaces) to support deploying multiple instances of the same component to the same environment.

The main implementation uses UNIX shell and a Makefile. This project also includes an alternative implementation in Python 3.

> /!\ EXPERIMENTAL: This project is under development.

## How to Reuse

The Makefile implementation consists of these three files:

- make/tools/stackform/stackform-cli.mk
- make/tools/stackform/stackform-tools-container.mk
- docker/stackform-tools.dockerfile

The following *variables* and *includes* must be present in the main Makefile:

```make
### Stackform

PROJECT_DIR		:= $(shell pwd)
STACK_NAME		?= example_app
STACK_VARIANT  ?=
ENVIRONMENT		?= dev
DOCKER_HOST     ?= true

include make/tools/stackform/stackform-cli.mk
include make/tools/stackform/stackform-tools-container.mk

###
```

> This does not interfere with any other use of Make. All of the targets and variables in the *mk* files are namespaced.

The implementation references this external URL:

https://github.com/stuartellis/multiform/tree/main/docs/tf-stacks-spec/0.4.0/README.md

## Dependencies

- Terraform 1.x
- Makefile implementation: A UNIX shell, *GNU Make* 3, *jq*
- OPTIONAL: Docker

The Python implementation requires Python 3.8 or above. It has no dependencies apart from the Python standard library.

## Setup

This project includes the configuration for a [Development Container](https://containers.dev/). The Development Container provides a Linux development environment with all of the dependencies that the project requires.

To use a development container with Visual Studio Code:

1. Ensure that Docker is running
2. Ensure that the **Dev Containers** extension is installed on Visual Studio Code
3. Open the project as a folder in Visual Studio Code
4. Accept the option to reopen the project in a container when prompted.
5. Run *make stacktools-build* to create the Docker container for the tools

## Usage

Use Make to run the appropriate tasks.

The *stacktools-build* target creates a Docker container image for the tools to use:

    make stacktools-build

By default, the container is built for the same CPU architecture as the machine that the command is run on. To build for another CPU architecture, override STACKTOOLS_TARGET_CPU_ARCH. For example, use arm64 for ARM:

    make stacktools-build STACKTOOLS_TARGET_CPU_ARCH=arm64

Make targets for Terraform stacks use the prefix *stack-*. For example:

    make stack-info
    make stack-fmt STACK_NAME=example_app

Specify *STACK_VARIANT* to create an alternate deployment of the same stack in the same environment:

    make stack-plan STACK_NAME=example_app STACK_VARIANT=feature1 ENVIRONMENT=dev

> The variants feature uses Terraform workspaces.

By default, all commands apart from *stack-info* run in a container. To run without a container, set *DOCKER_HOST=false*. For example:

    make stack-fmt STACK_NAME=example_app DOCKER_HOST=false

---

## TODOs

- Improve jq to read backend file only once.
- Define standard path structure for Parameter Store.
- Provide guidance on handling of secrets.
- Provide guidance on executing commands on multiple stacks.
- Improve guidance on cross-stack references.
- Add self-update for stackform assets
