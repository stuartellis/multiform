# Multiform

Example of a monorepo that includes Terraform with multiple stacks.

> /!\ EXPERIMENTAL: This project is under development.

## Dependencies

- Bash 4 or above
- Git 2.32 or above
- GNU Make 3 or above
- Python 3.8 or above
- Terraform 1.x

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

---

## Design 

1. This design enables a project to use multiple Terraform root modules. These root modules are referred to as *stacks*.
2. The core of the design is a set of conventions for Terraform projects. These consist of an *expected directory structure* and a set of *code conventions for Terraform stacks*.
3. The settings for a deployment are inferred from the directory structure and Terraform files. This avoids the need to maintain additional configuration.
4. A helper program generates Terraform commands. This *command builder* relies on the conventions to produce a complete Terraform command with the correct options. The command builder returns the Terraform command to the caller as a string. The caller is then responsible for executing the command. The helper program does not execute commands, and does not manage the environment where code is executed.
5. Each Terraform command that the builder produces executes on a specific Terraform stack, which is defined by the *expected directory structure*.
6. This example implementation of a project uses a standard set of tools that are provided on current versions of macOS. Linux distributions provide newer versions of the same tools. This means that the project will run on any macOS, WSL or Linux system.

> *This design does not use Terraform workspaces*

### Specifications

- Expected directory structure for Terraform - **docs/tf-stacks-spec/0.2.0/terraform-dir-structure.md**
- Code conventions for Terraform stacks - **docs/tf-stacks-spec/0.2.0/terraform-stack-conventions.md**
- Terraform command builder - **docs/tf-stacks-spec/0.2.0/terraform-command-builder.md**

The specifications are included in this example project whilst it is being developed. It is expected that the specifications will be hosted in a separate repository at a later point in time.

### Implementation of Terraform Command Builder

The current implementation of the Terraform command builder is here:

- **python/utils/utils/multiform.py**

The Make targets in this project use the command builder. You may also run the command builder yourself.

The builder is included in this example project whilst it is being developed. It is expected that the builder will be hosted in a separate repository at a later point in time.

### Design of Example Project

- Dependencies - **docs/project-design/dependencies.md**
- Upgrade Process - **docs/project-design/managing-upgrades.md**
- Use of Make - **docs/project-design/use-of-make.md**
