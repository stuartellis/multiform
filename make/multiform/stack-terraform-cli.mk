# Multiform: Terraform CLI commands

ifdef STACK_INSTANCE
	MF_EXTRA_OPTIONS := -i $(STACK_INSTANCE)
else
	MF_EXTRA_OPTIONS :=
endif

.PHONY: stack-fmt
	stack-fmt:@$(shell python $(MF_TF_CMD_BUILDER) fmt -e $(ENVIRONMENT) -s $(MF_STACK_NAME) $(MF_EXTRA_OPTIONS))
