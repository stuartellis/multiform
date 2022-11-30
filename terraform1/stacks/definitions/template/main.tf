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
