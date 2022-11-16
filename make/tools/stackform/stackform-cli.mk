# Terraform Stacks: Make Targets and Variables

STACK_NAME				?= default
STACK_INSTANCE			?=
STACK_TF_CMD_BUILDER	= ./python/utils/utils/stackform.py

ifdef STACK_INSTANCE
	TF_STACK_OPTIONS := -i $(STACK_INSTANCE)
else
	TF_STACK_OPTIONS :=
endif

.PHONY: stack-info
stack-info:
	@echo "Terraform Command Builder: $(STACK_TF_CMD_BUILDER)"
	@echo "Target Environment: $(ENVIRONMENT)"
	@echo "Target Stack: $(STACK_NAME)"
	@echo "Target Stack Instance: $(STACK_INSTANCE)"


.PHONY: stack-fmt
stack-fmt:
	@$(shell python3 $(STACK_TF_CMD_BUILDER) fmt -e $(ENVIRONMENT) -s $(STACK_NAME) $(TF_STACK_OPTIONS))
