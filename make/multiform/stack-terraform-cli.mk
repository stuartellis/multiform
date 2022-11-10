# Multiform: Terraform CLI commands

MF_STACK_NAME		?= default
MF_STACK_INSTANCE	?=
MF_TF_CMD_BUILDER	= ./python/utils/utils/multiform.py

.PHONY: stack-info
stack-info:
	@echo "Project: $(PROJECT_NAME)"
	@echo "Maintainers: $(PROJECT_MAINTAINERS)"
	@echo "Target Environment: $(ENVIRONMENT)"
	@echo "Target Stack: $(MF_STACK_NAME)"
	@echo "Target Stack Instance: $(MF_STACK_INSTANCE)"

.PHONY: stack-fmt
stack-fmt:
	@$(shell python $(MF_TF_CMD_BUILDER) fmt -e $(ENVIRONMENT) -i $(STACK_INSTANCE) -s $(STACK_NAME))

