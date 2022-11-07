# Code Conventions for a Terraform Stack 0.1.0

- Each stack is a Terraform root module.
- A stack may include Terraform modules.
- Each stack uses two sets of variable files: a *global  configuration* that applies to all instances of all stacks in all environments, and a *stack* configuration that is defined per *environment*.
- Each stack accepts an *instance identifier* variable, which is a string. Every resource name is prefixed with this string, so that multiple instances of a stack may be deployed to the same cloud account with the same *environment* definition. This enables various use cases, such as testing, blue-green deployment and disaster recovery.
- The *instance identifier* should have a default value of an empty string.
- Each stack has a separate Terraform state file per environment and instance identifier
- Each stack should be deployable on any cloud account that can provide the resources that the stack depends on.
- If using AWS, each stack should publish an ARN for each key resource that it manages to Parameter Store in the same account and region
- Avoid references to remote Terraform state, so that instances of a stack do not have dependencies on the state of other Terraform deployments
