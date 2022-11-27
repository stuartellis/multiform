# Code Conventions for a Terraform Stack 0.3.0

## The Definition of a Stack

- Each stack is a Terraform root module that has three variables: *stack_name*, *environment*, and *stack_instance*.
- The Terraform code and configuration in the stack should be standard Terraform code, compatible with Terraform 1.0.
- A stack may include Terraform modules.
- Avoid writing the name of a specific resource type in a stack name or instance identifier, such as *s3*. Use product names and areas of concern.

## Requirements: Required Terraform Variables

- Each stack accepts a *stack_name* variable. This is a string that begins with a letter, and contains only alphanumeric characters and hyphens. Characters must be in lowercase. It must have a maximum length of 30 characters.
- The *stack_name* variable should have no default value.
- Each stack accepts an *environment* variable. This is a string that begins with a letter, and contains only alphanumeric characters and hyphens. Characters must be in lowercase. It must have a maximum length of 10 characters. The content of the variable is deliberately undefined.
- The *environment* variable should have no default value.
- Each stack accepts a *stack_instance* variable. This is a string that begins with a letter, and contains only alphanumeric characters and hyphens. Characters must be in lowercase. It must have a maximum length of 10 characters. The content of the instance identifier is deliberately undefined: it could be a commit hash, release version, ticket ID, or other unique value. This enables various use cases, such as testing, blue-green deployment and disaster recovery.
- The *stack_instance* should have a default value of an empty string.

## Requirements: Terraform Var Files

> This specification limits the number of variable files to two in order to reduce complexity.

- Each stack uses two sets of Terraform variable files: a global configuration that applies the stack for all environments, and a configuration that is defined per environment. The global vars file is a *.tfvars* file in *terraform/stacks/environments/all/* with the same name as the stack. Each vars file for an environment is a *.tfvars* file in *terraform/stacks/environments/<environment-name>/* with the same name as the stack.
- Note: The reference command builder automatically provides the *stack_name*, *stack_instance* and *environment* as Terraform variables.

## Guidelines: Terraform Providers

- A stack may use multiple providers.
- Guideline: each stack should have one provider for a cloud service. If you have multiple providers for cloud services in the same stack, consider separating the resources into separate stacks.

## Guidelines: Terraform State

- Each stack should use a remote state backend.
- No values for remote state should be defined in the Terraform code. Each stack will have a separate Terraform state file per environment and stack instance. This configuration should be provided when a Terraform command is run. 
- Avoid references to remote Terraform state, so that instances of a stack do not have dependencies on the state of other Terraform deployments

## Guidelines: Terraform Resources

- Every resource name is prefixed with the *stack_instance* variable, so that multiple instances of a stack may be deployed to the same cloud account with the same *environment* definition.

## Guidelines: AWS

- A stack should not hard-code the IAM execution role that it uses with AWS.
- Each stack should be deployable on any AWS cloud account that can provide the resources that the stack depends on.
- Each stack should publish an ARN for each key resource that it manages to Parameter Store, in the same account and region.

## Guidelines: Code Deployment

- Stacks should only deploy artifacts that have already been built by a separate process.
- A stack should specify the name and version of each code artifact that it deploys as a Terraform variable.
- This specification does not require a particular format for artifact versions. For consistency, consider using either [Semantic Versioning](https://semver.org/) or a [Calendar Versioning](https://calver.org/) format.
