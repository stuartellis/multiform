SF_STACKS_SPEC_VERSION	:= 0.4.0
SF_STACKS_SPEC_URL		:= https://github.com/stuartellis/multiform/tree/main/docs/tf-stacks-spec/$(SF_STACKS_SPEC_VERSION)

SF_BACKEND_FILE		:= $(PROJECT_DIR)/terraform1/stacks/environments/$(ENVIRONMENT)/backend.json
SF_REMOTE_REGION 	:= $(shell jq '.aws.region' $(SF_BACKEND_FILE))
SF_REMOTE_BUCKET 	:= $(shell jq '.aws.bucket' $(SF_BACKEND_FILE))
SF_REMOTE_DDB_TABLE := $(shell jq '.aws.dynamodb_table' $(SF_BACKEND_FILE))
SF_REMOTE_BACKEND 	:= -backend-config=region=$(SF_REMOTE_REGION) -backend-config=bucket=$(SF_REMOTE_BUCKET) -backend-config=key=stacks/$(ENVIRONMENT)/$(STACK_NAME) -backend-config=dynamodb_table=$(SF_REMOTE_DDB_TABLE)

SF_WORKING_DIR	:= -chdir=$(PROJECT_DIR)/terraform1/stacks/definitions/$(STACK_NAME)
SF_VAR_FILES	:= -var-file=$(PROJECT_DIR)/terraform1/stacks/environments/all/$(STACK_NAME).tfvars -var-file=$(PROJECT_DIR)/terraform1/stacks/environments/$(ENVIRONMENT)/$(STACK_NAME).tfvars

ifdef STACK_INSTANCE
	SF_WORKSPACE := $(STACK_INSTANCE)
	SF_STACK_PREFIX := $(SF_WORKSPACE)-
	SF_VARS := -var="stack_name=$(STACK_NAME)" -var="environment=$(ENVIRONMENT)" -var="instance_prefix=$(SF_STACK_PREFIX)"
else
	SF_WORKSPACE := default
	SF_STACK_PREFIX :=
	SF_VARS := -var="stack_name=$(STACK_NAME)" -var="environment=$(ENVIRONMENT)"
endif

.PHONY: stack-info
stack-info:
	@echo "Terraform Command Builder: Makefile"
	@echo "Stacks Specification Version: $(SF_STACKS_SPEC_VERSION)"
	@echo "Stacks Specification URL: $(SF_STACKS_SPEC_URL)"
	@echo "Target Environment: $(ENVIRONMENT)"
	@echo "Target Stack: $(STACK_NAME)"
	@echo "Target Workspace: $(SF_WORKSPACE)"
	@echo "Stack Instance Prefix: $(SF_STACK_PREFIX)"

.PHONY: stack-apply
stack-apply: stack-plan
	TF_WORKSPACE=$(SF_WORKSPACE) terraform $(SF_WORKING_DIR) apply -auto-approve $(SF_VARS) $(SF_VAR_FILES)

.PHONY: stack-console
stack-console: stack-plan
	TF_WORKSPACE=$(SF_WORKSPACE) terraform $(SF_WORKING_DIR) console $(SF_VARS) $(SF_VAR_FILES)

.PHONY: stack-destroy
stack-destroy: stack-plan
	TF_WORKSPACE=$(SF_WORKSPACE) terraform $(SF_WORKING_DIR) destroy $(SF_VARS) $(SF_VAR_FILES)

.PHONY: stack-fmt
stack-fmt:
	@terraform $(SF_WORKING_DIR) fmt

.PHONY: stack-init
stack-init:
	@terraform $(SF_WORKING_DIR) init $(SF_REMOTE_BACKEND)

.PHONY: stack-plan
stack-plan: stack-validate
	TF_WORKSPACE=$(SF_WORKSPACE) terraform $(SF_WORKING_DIR) plan $(SF_VARS) $(SF_VAR_FILES)

.PHONY: stack-validate
stack-validate:
	TF_WORKSPACE=$(SF_WORKSPACE) terraform $(SF_WORKING_DIR) validate
