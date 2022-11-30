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
