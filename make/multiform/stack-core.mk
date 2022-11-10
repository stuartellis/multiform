# Multiform: Core Make Targets and Variables

STACK_NAME			?= default
STACK_INSTANCE		?=
MF_TF_CMD_BUILDER	= ./python/utils/utils/multiform.py

.PHONY: stack-info
stack-info:
	@echo "Project: $(PROJECT_NAME)"
	@echo "Maintainers: $(PROJECT_MAINTAINERS)"
	@echo "Target Environment: $(ENVIRONMENT)"
	@echo "Target Stack: $(STACK_NAME)"
	@echo "Target Stack Instance: $(STACK_INSTANCE)"
