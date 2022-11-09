# Terraform CLI commands

TF_CMD_BUILDER	= ./python/utils/utils/multiform.py

.PHONY: terraform-fmt
terraform-fmt:
	@$(shell python $(TF_CMD_BUILDER) fmt -e $(ENVIRONMENT) -s $(STACK_NAME))
