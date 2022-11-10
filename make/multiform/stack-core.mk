# Multiform: Core Make Targets and Variables

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
