# Code Conventions for a Terraform Stack 0.1.0

- Each stack is a Terraform root module that has two variables: *stack_name* and *stack_instance*.
- The Terraform code and configuration in the stack should be standard Terraform code, compatible with Terraform 1.0.
- A stack may include Terraform modules.
- Each stack accepts a *stack_name* variable. This is a string that begins with a lowercase letter, and contains only alphanumeric characters and hyphens. It must have a maximum length of 30 characters.
- The *stack_name* variable should have no default value.
- Each stack accepts a *stack_instance* variable. This is a string that begins with a lowercase letter, and contains only alphanumeric characters and hyphens. It must have a maximum length of 10 characters. The content of the instance identifier is deliberately undefined: it could be a commit hash, ticket ID or other unique value. This enables various use cases, such as testing, blue-green deployment and disaster recovery.
- The *stack_instance* should have a default value of an empty string.
- Every resource name is prefixed with the *stack_instance* variable, so that multiple instances of a stack may be deployed to the same cloud account with the same *environment* definition.
- Each stack uses two sets of variable files: a *global  configuration* that applies to all instances of all stacks in all environments, and a *stack* configuration that is defined per *environment*.
- The stack should use S3 remote state, but no values should be defined in the code. Each stack will have a separate Terraform state file per environment and stack instance, but this is not handled in the stack code.
- The stack should not hard-code the IAM execution role that it uses with AWS.
- Each stack should be deployable on any cloud account that can provide the resources that the stack depends on.
- If using AWS, each stack should publish an ARN for each key resource that it manages to Parameter Store in the same account and region
- Avoid references to remote Terraform state, so that instances of a stack do not have dependencies on the state of other Terraform deployments

## TODO

- Explain why configuration is opinionated (to avoid confusion and complexity).
- Define how remote state identifiers are collected.
- Define handling of separator characters in identifiers.
- Provide guidance on handling of secrets.
- Improve guidance on cross-stack references.
