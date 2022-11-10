# Multiform: Terraform CLI commands

.PHONY: stack-fmt
stack-fmt:
	@$(shell python $(MF_TF_CMD_BUILDER) fmt -e $(ENVIRONMENT) -i $(STACK_INSTANCE) -s $(STACK_NAME))
