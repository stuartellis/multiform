# Multiform

Example of a monorepo that includes Terraform with multiple stacks. Each stack is a Terraform root module.

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
    make stack-fmt STACK=example_app
    make stack-plan STACK=example_app ENVIRONMENT=prod

---

## Why?

- We want to define all of the aspects of the infrastructure for a project with Terraform. This may include configurations in multiple cloud services, such as AWS and Datadog.
- It is more effective to maintain all of the components of a service in one repository. It quickly becomes cumbersome and error-prone to maintain a separate repository for each component of a service. A service is likely to have at least three infrastructure components, and may also have custom application code.
- We want to be able to deploy, update and destroy instances of an infrastructure component without changing the state of other components. For example, we want to release updates to an application without changing storage or monitoring components.
- We may want to deploy some components for a limited time or a specific purpose. For example, we may want to delete test instances of application components on a schedule, or when they are no longer needed, or have instructure components that are only deployed to run performance tests.
- We may want to be able to manage multiple instances of an infrastructure component in the same cloud account without deploying all of the components. For example, we may want to deploy separate copies of components to develop multiple features in parallel, or as part of a process for recovering data.
- We want to minimise the size of the Terraform state that is used for each operation. This enables us to run Terraform quickly and safely.
- We want to manage the Terraform state for all of the components of a project in a consistent way. This enables us to develop and apply tooling, such as automated backups, removal of obsolete state files, or using [tfquery](https://github.com/mazen160/tfquery).

## Design 

1. This design enables a project to use multiple Terraform root modules. These root modules are referred to as *stacks*.
2. The core of the design is a set of conventions for Terraform projects. These consist of an *expected directory structure* and a set of *code conventions for Terraform stacks*.
3. The settings for a deployment are inferred from the directory structure and Terraform files as much as possible. This reduces the need to maintain additional configuration.
4. A helper program generates Terraform commands. This *command builder* relies on the conventions to produce a complete Terraform command with the correct options. The command builder returns the Terraform command to the caller as a string. The caller is then responsible for executing the command. The helper program does not execute commands, and does not manage the environment where code is executed.
5. Each Terraform command that the builder produces executes on a specific Terraform stack, which is defined by the *expected directory structure*.
6. This example implementation of a project uses a standard set of tools that are provided on current versions of macOS. Linux distributions provide newer versions of the same tools. This means that the project will run on any macOS, WSL or Linux system.

### Specifications

- Expected directory structure for Terraform - **docs/tf-stacks-spec/0.3.0/terraform-dir-structure.md**
- Code conventions for Terraform stacks - **docs/tf-stacks-spec/0.3.0/terraform-stack-conventions.md**
- Terraform command builder - **docs/tf-stacks-spec/0.3.0/terraform-command-builder.md**

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
