# Conventions for Terraform Stacks - Version 0.4.0

This design enables a project to include multiple Terraform root modules. These root modules are referred to as *stacks*.

It also enables you to use [Terraform workspaces](https://developer.hashicorp.com/terraform/language/state/workspaces) to deploy multiple instances of the same component to the same environment.

## The Definition of a Stack

- Each stack is a Terraform root module that has three variables: *stack_name*, *environment*, and *variant*.
- The Terraform code and configuration in the stack should be standard Terraform code, compatible with Terraform 1.0.
- A stack may include Terraform modules.

---

## Requirements

This diagram summarizes the required directory structure and files:

```
<project>/
|
|- terraform1/
    |
    |- .gitignore
    |
    |- README.md
    |
    |- stacks/
        |
        |- definitions/
        |   |
        |   |- <stack_one>/
        |   |     |
        |   |     |- <Terraform code>
        |   | 
        |   |- <stack_two>/
        |   |     |
        |   |     |- <Terraform code>
        |   |
        |   |- template/
        |         |
        |         |- <Terraform code>
        |
        |- modules/
        |   |
        |   |- <module>/
        |   |     |
        |   |     |- <Terraform code>
        |   | 
        |   |- <module>/
        |         |
        |         |- <Terraform code>
        |
        |
        |- tmp/
        |
        |- environments/
            |
            |- all/
            |   |
            |   |- stack_one.tfvars
            |   |- stack_two.tfvars
            |
            |- dev/
            |   |
            |   |- backend.json
            |   |- stack_one.tfvars
            |   |- stack_two.tfvars
            |
            |- test/
                |
                |- backend.json
                |- stack_one.tfvars
                |- stack_two.tfvars
```

### Required Directory Structure

- Each project has a root directory for Terraform code and configuration, called *terraform1/*
- The root directory for the set of Terraform stacks is called *terraform1/stacks/*
- The root directory *terraform1/* should only contain the *stacks/* directory, a *.gitignore* file and a *README.md* file.
- Each stack is a sub-directory under the *terraform1/stacks/definitions/* directory.
- The *terraform1/stacks/definitions/* directory also contains a subdirectory called *template/*.
- Each environment is a sub-directory under the *terraform1/stacks/environments/* directory.
- The *terraform1/stacks/environments/* directory also contains a subdirectory called *all/*.
- The *terraform1/stacks/modules/* directory contains any Terraform modules that are only used by the stacks in this project.
- The *terraform1/stacks/tmp/* directory contains plan files, and any other generated files.
- The Terraform code for a stack should only use Terraform modules and the files that are under the *terraform1/stacks/* directory and subdirectories. It should not rely on any other files or directories.

### Required Terraform Variables

The following three Terraform variables are required for every stack. Each stack may have any other variables that you wish.

```terraform
variable "environment" {
  type = string
}

variable "stack_name" {
  type = string
}

variable "variant" {
  type    = string
  default = ""
}
```

#### stack_name

The unique name of the stack. The *stack_name* should start with the name of the project.

- Each stack accepts a *stack_name* variable. 
- This variable is a string that begins with a letter
- It must contains only alphanumeric characters and hyphens. Characters must be in lowercase. 
- It must have a maximum length of 30 characters.
- Avoid using these words in the stack name: *all*, *default*, *global*, *main* and *template*.
- The *stack_name* variable should have no default value.

#### environment

The environment where the stack is deployed.

- Each stack accepts an *environment* variable. 
- This variable is a string that begins with a letter.
- It must contain only alphanumeric characters and hyphens. Characters must be in lowercase.
- It must have a maximum length of 10 characters.
- Avoid using these words in the environment name: *all*, *default*, *global*, *main* and *template*.
- The *environment* variable should have no default value.

#### variant

The *variant* is an identifier for a specific instance of a stack. It is an empty string for the original or default instance of a stack. This enables various use cases, such as testing, blue-green deployment and disaster recovery.

- Each stack accepts a *variant* variable. 
- This variable is a string that begins with a letter. 
- It must contain only alphanumeric characters and hyphens. Characters must be in lowercase. 
- It must have a maximum length of 10 characters.
- Avoid using these words in the variant name: *all*, *default*, *global*, *main* and *template*.
- The *variant* should have a default value of an empty string.
- If you are using a Terraform workspace, the *variant* should be the name of the workspace. 

### Terraform Var Files

These files may contain no values.

#### Global

- A global configuration that applies to a stack in all environments. The global vars file is a *.tfvars* file in *terraform1/stacks/environments/all/* with the same name as the stack. 

#### Per-Environment

- Each vars file for an environment is a *.tfvars* file in *terraform1/stacks/environments/environment_name* with the same name as the stack.

### Backend Configuration

#### Backend JSON File

Example *backend.json* file:

```
{
    "aws": {
        "bucket": "234567891012-terraform",
        "dynamodb_table": "terraform-state-lock_234567891012_dev",
        "region": "eu-west-2"
    }
}
```

- Tools read the settings for the backend from a JSON file. Each environment has a *backend.json* file in the relevant subdirectory in *environments/* subdirectory.
- A *backend.json* file has an entry for the cloud provider. For AWS, this is *aws*.
- The entry for the cloud provider should contain the required items. For AWS, these items are *bucket*, *region* and *dynamodb_table*.
- The *key* should use the format */stacks/environment_name/stack_name*

#### Terraform *backend*

Here is an example of the Terraform:

```terraform
terraform {
  required_version = "> 1.0.0"

  backend "s3" {
    workspace_key_prefix = "workspaces"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 4.41.0"
    }
  }
}
```

- Each stack should use the *s3* remote state backend.
- The Terraform backend should declare a *workspace_key_prefix* with the value *workspaces*. Provide all other settings when Terraform runs.

---

## Guidelines

### Terraform Workspaces

- A workspace name should contain only alphanumeric characters and hyphens. Characters must be in lowercase. It must have a maximum length of 10 characters. 
- The content of a workspace name is deliberately undefined: it could be a commit hash, release version, ticket ID, or other unique value.

### Terraform Providers

- A stack may use multiple providers.
- Each stack should have one provider for a cloud service. If you have multiple providers for cloud services in the same stack, consider separating the resources into separate stacks.

### Terraform State

- Avoid references to other remote Terraform states, so that instances of a stack do not have dependencies on the state of other Terraform deployments

### Terraform Resources

- Every resource name is prefixed with the *variant* variable, so that multiple instances of a stack may be deployed to the same cloud account with the same *environment* definition.

### AWS Provider

Example *aws* provider:

```terraform
provider "aws" {
  default_tags {
    tags = {
      Environment = var.environment
      Provisioner = "Terraform"
      Stack       = var.stack_name
      Variant     = var.variant == "" ? "default" : var.variant
    }
  }
}
```

- Use the *default_tags* option of the AWS provider to set tags for all resources.
- A stack should not hard-code the IAM execution role that it uses with AWS.
- Each stack should be deployable on any AWS cloud account that can provide the resources that the stack depends upon.

### Code Deployment

- Stacks should only deploy artifacts that have already been built by a separate process.
- A stack should specify the name and version of each code artifact that it deploys as a Terraform variable.
- This specification does not require a particular format for artifact versions. For consistency, consider using either [Semantic Versioning](https://semver.org/) or a [Calendar Versioning](https://calver.org/) format.
