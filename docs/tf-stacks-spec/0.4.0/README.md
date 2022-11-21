# Conventions for a Terraform Stack - Version 0.4.0

## The Definition of a Stack

- Each stack is a Terraform root module that has three variables: *stack_name*, *environment*, and *instance_prefix*.
- The Terraform code and configuration in the stack should be standard Terraform code, compatible with Terraform 1.0.
- A stack may include Terraform modules.
- Avoid writing the name of a specific resource type in a stack name or instance identifier, such as *s3*. Use product names and areas of concern.

---

## Requirements

### Required Directory Structure

- Each project has a root directory for Terraform code and configuration, called *terraform1/*
- The root directory for the set of Terraform stacks is called *terraform1/stacks/*
- Each stack is a sub-directory under the *terraform1/stacks/definitions/* directory.
- Each environment is a sub-directory under the *terraform1/stacks/environments/* directory.
- The *terraform1/stacks/environments/* directory also contains a subdirectory called *all/*.
- Code for stacks only references or relies upon Terraform modules and files that are under the *terraform1/stacks/* directory and subdirectories. They do not rely on any other files or directories.

### Required Terraform Variables

#### stack_name

- Each stack accepts a *stack_name* variable. This is a string that begins with a letter, and contains only alphanumeric characters and hyphens. Characters must be in lowercase. It must have a maximum length of 30 characters.
- The *stack_name* variable should have no default value.

#### environment

- Each stack accepts an *environment* variable. This is a string that begins with a letter, and contains only alphanumeric characters and hyphens. Characters must be in lowercase. It must have a maximum length of 10 characters. The content of the variable is deliberately undefined.
- The *environment* variable should have no default value.

#### instance_prefix

- Each stack accepts a *instance_prefix* variable. This is a string that begins with a letter and end with a hyphen. It should contain only alphanumeric characters and hyphens. Characters must be in lowercase. It must have a maximum length of 10 characters. If you are using Terraform workspaces, the *instance_prefix* should be the name of the workspace followed by a hyphen. This enables various use cases, such as testing, blue-green deployment and disaster recovery.
- The *instance_prefix* should have a default value of an empty string.

### Terraform Var Files

> This specification limits the number of variable files to two in order to reduce complexity.

#### Global

- A global configuration that applies the stack for all environments. The global vars file is a *.tfvars* file in *terraform1/stacks/environments/all/* with the same name as the stack. 

#### Per-Environment

- Each vars file for an environment is a *.tfvars* file in *terraform1/stacks/environments/<environment-name>/* with the same name as the stack.

### Terraform Backend Configuration

- Tools read the settings for the backend from a JSON file. Each environment has a *backend.json* file in the relevant subdirectory in *environments/* subdirectory.
- A *backend.json* file has an entry for the cloud provider. For AWS, this is *aws*.
- The entry for the cloud provider should contain the required items. For AWS, these items are *bucket*, *region* and *dynamodb_table*.
- The *key* should use the format */stacks/<environment_name>/<stack_name>*

---

## Guidelines

### Terraform Workspaces

- A workspace name should contain only alphanumeric characters and hyphens. Characters must be in lowercase. It must have a maximum length of 10 characters. 
- The content of a workspace name is deliberately undefined: it could be a commit hash, release version, ticket ID, or other unique value.

### Terraform Providers

- A stack may use multiple providers.
- Guideline: each stack should have one provider for a cloud service. If you have multiple providers for cloud services in the same stack, consider separating the resources into separate stacks.

### Terraform State

- Each stack should use a remote state backend.
- No values for remote state should be defined in the Terraform code. Each stack will have a separate Terraform state file per environment and stack instance. This configuration should be provided when a Terraform command is run. 
- Avoid references to remote Terraform state, so that instances of a stack do not have dependencies on the state of other Terraform deployments

### Terraform Resources

- Every resource name is prefixed with the *instance_prefix* variable, so that multiple instances of a stack may be deployed to the same cloud account with the same *environment* definition.

### AWS

- A stack should not hard-code the IAM execution role that it uses with AWS.
- Each stack should be deployable on any AWS cloud account that can provide the resources that the stack depends on.
- Each stack should publish an ARN for each key resource that it manages to Parameter Store, in the same account and region.

### Code Deployment

- Stacks should only deploy artifacts that have already been built by a separate process.
- A stack should specify the name and version of each code artifact that it deploys as a Terraform variable.
- This specification does not require a particular format for artifact versions. For consistency, consider using either [Semantic Versioning](https://semver.org/) or a [Calendar Versioning](https://calver.org/) format.
