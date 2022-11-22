# Terraform Stacks
#
# Example Make targets and variables for Python implementation

STACK_PY_CMD_BUILDER	= ./python/utils/stackform/stackform.py

ifdef STACK_INSTANCE
	STACK_PY_OPTIONS := -i $(STACK_INSTANCE)
else
	STACK_PY_OPTIONS :=
endif

.PHONY: pystack-info
pystack-info:
	@echo "Terraform Command Builder: $(STACK_PY_CMD_BUILDER)"
	@echo "Target Environment: $(ENVIRONMENT)"
	@echo "Target Stack: $(STACK_NAME)"
	@echo "Target Stack Instance: $(STACK_INSTANCE)"


.PHONY: pystack-fmt
pystack-fmt:
	@$(shell python3 $(STACK_PY_CMD_BUILDER) fmt -e $(ENVIRONMENT) -s $(STACK_NAME) $(STACK_PY_OPTIONS))
