# Terraform Stacks
#
# Makefile targets and variables
#
# Requirements: A UNIX shell, jq, GNU Make 3 or above
#
# Terraform variables: stack_name, environment, instance_prefix
#

SF_STACKS_TOOLS_VERSION	:= 0.4.0
SF_STACKS_SPEC_VERSION	:= 0.4.0
SF_STACKS_SPEC_URL		:= https://github.com/stuartellis/multiform/tree/main/docs/tf-stacks-spec/$(SF_STACKS_SPEC_VERSION)/README.md

SF_STACKS_DIR		:= $(PROJECT_DIR)/terraform1/stacks

SF_BACKEND_FILE		:= $(SF_STACKS_DIR)/environments/$(ENVIRONMENT)/backend.json
SF_REMOTE_REGION 	:= $(shell jq '.aws.region' $(SF_BACKEND_FILE))
SF_REMOTE_BUCKET 	:= $(shell jq '.aws.bucket' $(SF_BACKEND_FILE))
SF_REMOTE_DDB_TABLE := $(shell jq '.aws.dynamodb_table' $(SF_BACKEND_FILE))
SF_REMOTE_BACKEND 	:= -backend-config=region=$(SF_REMOTE_REGION) -backend-config=bucket=$(SF_REMOTE_BUCKET) -backend-config=key=stacks/$(ENVIRONMENT)/$(STACK_NAME) -backend-config=dynamodb_table=$(SF_REMOTE_DDB_TABLE)

SF_WORKING_DIR	:= -chdir=$(SF_STACKS_DIR)/definitions/$(STACK_NAME)
SF_VAR_FILES	:= -var-file=$(SF_STACKS_DIR)/environments/all/$(STACK_NAME).tfvars -var-file=$(SF_STACKS_DIR)/environments/$(ENVIRONMENT)/$(STACK_NAME).tfvars

ifdef STACK_INSTANCE
	SF_WORKSPACE := $(STACK_INSTANCE)
	SF_VARIANT_ID := $(SF_WORKSPACE)
	SF_VARS := -var="stack_name=$(STACK_NAME)" -var="environment=$(ENVIRONMENT)" -var="variant=$(SF_VARIANT_ID)"
else
	SF_WORKSPACE := default
	SF_VARIANT_ID :=
	SF_VARS := -var="stack_name=$(STACK_NAME)" -var="environment=$(ENVIRONMENT)"
endif

SF_CMD := TF_WORKSPACE=$(SF_WORKSPACE) terraform

## Targets

.PHONY: stack-info
stack-info:
	@echo "Stacks Tools Version: $(SF_STACKS_TOOLS_VERSION)"
	@echo "Stacks Specification Version: $(SF_STACKS_SPEC_VERSION)"
	@echo "Stacks Specification URL: $(SF_STACKS_SPEC_URL)"
	@echo "Stacks Directory: $(SF_STACKS_DIR)"
	@echo "Environment: $(ENVIRONMENT)"
	@echo "Stack: $(STACK_NAME)"
	@echo "Terraform Workspace: $(SF_WORKSPACE)"
	@echo "Stack Variant Identifier: $(SF_VARIANT_ID)"

.PHONY: stack-apply
stack-apply: stack-plan
	$(SF_CMD) $(SF_WORKING_DIR) apply -auto-approve $(SF_VARS) $(SF_VAR_FILES)

.PHONY: stack-console
stack-console: stack-plan
	$(SF_CMD) $(SF_WORKING_DIR) console $(SF_VARS) $(SF_VAR_FILES)

.PHONY: stack-destroy
stack-destroy: stack-plan
	$(SF_CMD) $(SF_WORKING_DIR) destroy $(SF_VARS) $(SF_VAR_FILES)

.PHONY: stack-fmt
stack-fmt:
	$(SF_CMD) $(SF_WORKING_DIR) fmt

.PHONY: stack-init
stack-init:
	$(SF_CMD) $(SF_WORKING_DIR) init $(SF_REMOTE_BACKEND)

.PHONY: stack-plan
stack-plan: stack-validate
	$(SF_CMD) $(SF_WORKING_DIR) plan $(SF_VARS) $(SF_VAR_FILES)

.PHONY: stack-validate
stack-validate:
	$(SF_CMD) $(SF_WORKING_DIR) validate
