# Multiform

> /!\ **EXPERIMENTAL:** This project is under development.

A test monorepo project with multiple infrastructure components and reusable tooling.

Each infrastructure component is a separate Terraform root module. The tooling uses built-in features of Terraform to support both multiple components in the same repository and deploying multiple instances of the same component to the same environment.

The Terraform root modules are referred to as *stacks*. The tooling that runs Terraform is named *stacktools* for convenience.

You can add the *stacktools* to any project by copying three files into the project repository. The tooling only requires a UNIX shell, the Make utility and the [jq](https://stedolan.github.io/jq/) command-line tool.

By default, the tools use Docker and a container to provide Terraform. You can override this to either provide your own container image, or use a separate copy of Terraform.

> **The Stacks Specification:** The *stacktools* follow a [documented and versioned set of conventions](https://github.com/stuartellis/multiform/tree/main/docs/terraform-stacks-spec/0.4.0/README.md). These conventions only require three variables in each root module. They enable you to upgrade, replace or remove the tools at any time, without changing your Terraform code.

## Setting Up This Example Project

### Visual Studio Code

This project includes the configuration for a [development container](https://containers.dev/). This means that Visual Studio Code and Visual Studio can set up a working environment for you on any operating system.

To run the project on Visual Studio Code:

1. Ensure that Docker is running
2. Ensure that the **Dev Containers** extension is installed in Visual Studio Code
3. Open the project as a folder in Visual Studio Code
4. Accept the option to reopen the project in a development container when prompted.
5. Run *make stackrunner-build* to create the Docker container for Terraform

### Manual Project Setup

The Stack Tools require:

- A UNIX shell
- *GNU Make* 3 or above 
- [jq](https://stedolan.github.io/jq/)
- EITHER: Docker OR provide Terraform 1.x separately

The tooling is compatible with the UNIX shell and Make versions that are provided by macOS. You can install *jq* and Docker on macOS with whatever tools that you prefer.

> /!\ **WSL:** The project and tooling are not yet tested on WSL. They should work correctly on any WSL environment that has Make, jq and Docker installed. Alternatively, use a development container.

## How to Add The Tooling to Another Project

The *stacktools* consist of these three files:

- make/tools/stacktools/cli.mk
- make/tools/stacktools/runner.mk
- docker/tools/stacktools/runner.dockerfile

The following *include* and *variables* must be present in the top-level Makefile for your project:

```make
PROJECT_DIR		:= $(shell pwd)
ENVIRONMENT		?= dev

include make/tools/stacktools/*.mk
```

> This does not interfere with any other use of Make. All of the targets and variables in the *mk* files are namespaced.

All of the files for Terraform are in the directory *terraform1/*. Refer to the conventions for the expected directory structure:

https://github.com/stuartellis/multiform/tree/main/docs/terraform-stacks-spec/0.4.0/README.md

Any other directories that contain Terraform code are ignored.

> If you fork this repository, update the URL in the file *make/tools/stacktools/cli.mk* to point to the conventions README in your fork.

## Usage

Use Make to run the appropriate commands.

Before you run other commands, use the *stackrunner-build* target to create a Docker container image for Terraform:

    make stackrunner-build

This creates the container image *stacktools-runner:developer*.

Make targets for Terraform stacks use the prefix *stack-*. For example:

    make stack-info
    make stack-fmt STACK_NAME=example_app

Specify *ENVIRONMENT* to create a deployment of the stack in the target environment:

    make stack-apply ENVIRONMENT=dev STACK_NAME=example_app

Specify *STACK_VARIANT* to create an alternate deployment of the same stack in the same environment:

    make stack-apply ENVIRONMENT=dev STACK_NAME=example_app STACK_VARIANT=feature1

By default, the tooling runs every Terraform command in a temporary container. To run Terraform without a container, set *ST_RUN_CONTAINER=false*. For example:

    make stack-fmt STACK_NAME=example_app ST_RUN_CONTAINER=false

To specify a different container image for Terraform, set the *STACK_RUNNER_IMAGE* variable to the name of the container:

    make stack-fmt STACK_NAME=example_app STACK_RUNNER_IMAGE=mytools-runner:1.4.5

### Current *stack* Targets

| Name           | Description                            |
|----------------|----------------------------------------|
| stack-apply    | *terraform apply* for a stack          |
| stack-console  | *terraform console* for a stack        |
| stack-destroy  | *terraform apply -destroy* for a stack |
| stack-fmt      | *terraform fmt* for a stack            |
| stack-info     | Show information for a stack           |
| stack-init     | *terraform init* for a stack           |
| stack-plan     | *terraform plan* for a stack           |
| stack-shell    | Open a shell                           |
| stack-validate | *terraform validate* for a stack       |

### Current *stackrunner* Targets

| Name              | Description           |
|-------------------|-----------------------|
| stackrunner-build | Build container image |
| stackrunner-info  | Show details          |

## Terraform State

Each stack always has a separate Terraform state file for each environment. The variants feature uses [Terraform workspaces](https://developer.hashicorp.com/terraform/language/state/workspaces). This means that Terraform creates an extra state file for each variant.

## More About Containers

### Runner Containers

The *stacktools-runner* images are built to provide a complete environment for running Terraform and the *stacktools*. This means that they include Make and jq as well as Terraform.

The defaults for the *stacktools-runner* container image use Alpine Linux to produce small images.

The default image tag uses the version *developer*. This enables you to rebuild the container image on your machine at any time. If you publish an image to a shared repository, set the version to a fixed number.

Use the *ST_RUNNER_VERSION* variable to build a container image with a fixed version:

    make stackrunner-build ST_RUNNER_VERSION=1.4.5

### Automation and CI/CD

You can use a *stacktools-runner* container to provide an environment to deploy Terraform with Continuous Integration. In most cases, use your own container image instead. You can run *stacktools* in any container that includes Make, jq, a UNIX shell and either Docker-in-Docker or Terraform.

If you run all of the deployment process for your project in a container, include a copy of Terraform in the container and use *ST_RUN_CONTAINER=false* to prevent the tooling from creating a new temporary container for each command.

    make stack-apply ENVIRONMENT=dev STACK_NAME=example_app ST_RUN_CONTAINER=false

### Cross-Architecture Support

By default, *stackrunner-build* builds the *stacktools-runner* container image for the same CPU architecture as the machine that the command is run on. To build for another CPU architecture, override *ST_RUNNER_TARGET_CPU_ARCH*. For example, specify *arm64* for ARM:

    make stackrunner-build ST_RUNNER_TARGET_CPU_ARCH=arm64

### Development Containers

The *.devcontainer/* directory provides development container configuration files that are compatible with the [Development Container specification](https://containers.dev/). This provides a Linux development environment with all of the dependencies that the project requires.

The development containers configuration provides a Debian container for compatibility with Python code.

---

## TODOs

- Complete support for CI/CD.
- Add guards in Make for undefined PROJECT_DIR, STACK_NAME or ENVIRONMENT variables.
- Add target to generate directory structure for terraform1/
- Add target to generate a stack in terraform1/, copying content from terraform1/stacks/definitions/template/ if present
- Add self-update target for stacktools files, to enable refreshes
- Define standard path structure for Parameter Store.
- Provide guidance on handling of secrets.
- Provide guidance on executing commands on multiple stacks.
- Improve guidance on cross-stack references.
