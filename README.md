# Multiform

> /!\ EXPERIMENTAL: This project is under development.

A test monorepo project with multiple infrastructure components.

Each infrastructure component is a separate Terraform root module. The project uses [Terraform workspaces](https://developer.hashicorp.com/terraform/language/state/workspaces) to support deploying multiple instances of the same component to the same environment.

The Terraform root modules are referred to as *stacks*. The tooling that runs Terraform on stacks is referred to as *stackform*.

The tooling uses UNIX shell, Makefiles and the [jq](https://stedolan.github.io/jq/) utility. This project also includes an alternative implementation in Python 3. By default, the tooling uses Docker and a container to provide Terraform. You can override this to either provide your own container image, or use a separate copy of Terraform.

## How to Add Tooling to a Project

The tooling consists of these three files:

- make/tools/stackform/stackform-cli.mk
- make/tools/stackform/stackform-tools-container.mk
- docker/tools/stackform/stackform-tools.dockerfile

The following *include* and *variables* and must be present in the top-level Makefile for your project:

```make
PROJECT_DIR		:= $(shell pwd)
ENVIRONMENT		?= dev

include make/tools/stackform/*.mk
```

> This does not interfere with any other use of Make. All of the targets and variables in the *mk* files are namespaced.

All of the files for Terraform are in the directory *terraform1/*. Refer to the conventions README for the expected directory structure:

https://github.com/stuartellis/multiform/tree/main/docs/tf-stacks-spec/0.4.0/README.md

Any other directories that contain Terraform code are ignored.

> If you fork this repository, update the URL in the file *make/tools/stackform/stackform-cli.mk* to point to the conventions README in your fork.

## Dependencies

- A UNIX shell
- *GNU Make* 3 or above 
- [jq](https://stedolan.github.io/jq/)
- EITHER: Docker OR provide Terraform 1.x separately

The tooling is compatible with the UNIX shell and Make versions that are provided by *macOS*.

> /!\ This project is not yet tested on WSL. It should work correctly on any WSL environment that has Make, jq and Docker installed.

The alternative Python implementation requires Python 3.8 or above. It only uses the Python standard library, and requires no other Python packages.

## Setup

This project includes the configuration for a [Development Container](https://containers.dev/). This means that Visual Studio Code and Visual Studio can automatically set up a working environment for you.

To run the project on Visual Studio Code:

1. Ensure that Docker is running
2. Ensure that the **Dev Containers** extension is installed on Visual Studio Code
3. Open the project as a folder in Visual Studio Code
4. Accept the option to reopen the project in a development container when prompted.
5. Run *make stacktools-build* to create the Docker container for Terraform

## Usage

Use Make to run the appropriate commands.

Before you run other commands, use the *stacktools-build* target to create a Docker container image for Terraform:

    make stacktools-build

This creates the container image *stacktools:developer*.

Make targets for Terraform stacks use the prefix *stack-*. For example:

    make stack-info
    make stack-fmt STACK_NAME=example_app

Specify *ENVIRONMENT* to create a deployment of the stack in the target environment:

    make stack-apply STACK_NAME=example_app STACK_VARIANT=feature1 ENVIRONMENT=dev

Specify *STACK_VARIANT* to create an alternate deployment of the same stack in the same environment:

    make stack-apply STACK_NAME=example_app STACK_VARIANT=feature1 ENVIRONMENT=dev

By default, the tooling runs every Terraform command in a temporary container. To run Terraform without a container, set *SF_RUN_CONTAINER=false*. For example:

    make stack-fmt STACK_NAME=example_app SF_RUN_CONTAINER=false

To specify a different container image for Terraform, set the *SF_TOOLS_DOCKER_IMAGE* variable to the name of the container:

    make stack-fmt STACK_NAME=example_app SF_TOOLS_DOCKER_IMAGE=stackform-tools:0.4.2

## Terraform State

Each stack always has a separate Terraform state file for each environment. The variants feature uses [Terraform workspaces](https://developer.hashicorp.com/terraform/language/state/workspaces). This means that Terraform creates an extra state file for each variant.

## More About Containers

### Development Containers

The *.devcontainer/* directory provides Development Container configuration files that are compatible with the [Development Container specification](https://containers.dev/). They provides a Linux development environment with all of the dependencies that the project requires.

### Automation and CI/CD

The Dockerfile for *stacktools* containers includes Make and [jq](https://stedolan.github.io/jq/), as well as Terraform. This means that you can use it to provide a complete environment to deploy your project with Continuous Integration.

If you run all of the deployment process for your project in a *stacktools* container, consider using *SF_RUN_CONTAINER=false* to prevent the tooling from creating a new temporary container for each command.

### Cross-Architecture Support

By default, *stacktools-build* builds the *stacktools* container image for the same CPU architecture as the machine that the command is run on. To build for another CPU architecture, override STACKTOOLS_TARGET_CPU_ARCH. For example, specify *arm64* for ARM:

    make stacktools-build STACKTOOLS_TARGET_CPU_ARCH=arm64

---

## TODOs

- Complete support for CI/CD.
- Add guards in Make for undefined PROJECT_DIR, STACK_NAME or ENVIRONMENT variables.
- Add self-update target for stackform files, to enable refreshes
- Define standard path structure for Parameter Store.
- Provide guidance on handling of secrets.
- Provide guidance on executing commands on multiple stacks.
- Improve guidance on cross-stack references.
