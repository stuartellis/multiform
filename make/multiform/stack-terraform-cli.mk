# Multiform: Terraform CLI commands

ifdef STACK_INSTANCE
	MF_STACK_OPTIONS := -i $(STACK_INSTANCE)
else
	MF_STACK_OPTIONS :=
endif

.PHONY: stack-fmt
stack-fmt:
	@$(shell python $(MF_TF_CMD_BUILDER) fmt -e $(ENVIRONMENT) -s $(STACK_NAME) $(MF_STACK_OPTIONS))
