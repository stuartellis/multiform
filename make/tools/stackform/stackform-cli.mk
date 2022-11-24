# Terraform Stacks - Commands
#
# Makefile targets and variables
#
# Requirements: A UNIX shell, jq, GNU Make 3 or above
#
# Set DOCKER_HOST=true to run in a Docker container
#
# This provides the Terraform variables: stack_name, environment, variant
#

###### Versions ######

SF_STACKS_TOOLS_VERSION	:= 0.4.1
SF_STACKS_SPEC_VERSION	:= 0.4.0
SF_STACKS_SPEC_URL		:= https://github.com/stuartellis/multiform/tree/main/docs/tf-stacks-spec/$(SF_STACKS_SPEC_VERSION)/README.md

###### Docker Image ######

SF_CMD_DOCKER_IMAGE		:= stackform-tools:developer

###### Root Directory ######

SF_STACKS_DIR		:= $(PROJECT_DIR)/terraform1/stacks

###### Terraform Variables ######

SF_BACKEND_FILE		:= $(SF_STACKS_DIR)/environments/$(ENVIRONMENT)/backend.json

SF_BACKEND_AWS		:= $(shell cat $(SF_BACKEND_FILE) | jq '.aws')
SF_REMOTE_REGION 	:= $(shell echo '$(SF_BACKEND_AWS)' | jq '.region')
SF_REMOTE_BUCKET 	:= $(shell echo '$(SF_BACKEND_AWS)' | jq '.bucket')
SF_REMOTE_DDB_TABLE := $(shell echo '$(SF_BACKEND_AWS)' | jq '.dynamodb_table')
SF_REMOTE_BACKEND 	:= -backend-config=region=$(SF_REMOTE_REGION) -backend-config=bucket=$(SF_REMOTE_BUCKET) -backend-config=key=stacks/$(ENVIRONMENT)/$(STACK_NAME) -backend-config=dynamodb_table=$(SF_REMOTE_DDB_TABLE)

SF_WORKING_DIR	:= -chdir=$(SF_STACKS_DIR)/definitions/$(STACK_NAME)
SF_VAR_FILES	:= -var-file=$(SF_STACKS_DIR)/environments/all/$(STACK_NAME).tfvars -var-file=$(SF_STACKS_DIR)/environments/$(ENVIRONMENT)/$(STACK_NAME).tfvars

ifdef AWS_ACCESS_KEY_ID
	DOCKER_ENV_VARS := -e TF_WORKSPACE=$(SF_WORKSPACE) -e AWS_REGION=$(AWS_REGION) -e AWS_ACCESS_KEY_ID=$(AWS_ACCESS_KEY_ID) -e AWS_SECRET_ACCESS_KEY=$(AWS_SECRET_ACCESS_KEY)
else
	DOCKER_ENV_VARS := -e TF_WORKSPACE=$(SF_WORKSPACE)
endif

ifdef STACK_VARIANT
	SF_WORKSPACE := $(STACK_VARIANT)
	SF_VARIANT_ID := $(STACK_VARIANT)
	SF_VARS := -var="stack_name=$(STACK_NAME)" -var="environment=$(ENVIRONMENT)" -var="variant=$(SF_VARIANT_ID)"
else
	SF_WORKSPACE := default
	SF_VARIANT_ID :=
	SF_VARS := -var="stack_name=$(STACK_NAME)" -var="environment=$(ENVIRONMENT)"
endif

###### Terraform Command ######

SF_DOCKER_RUN_CMD 		:= docker run --rm
SF_DOCKER_SHELL_CMD		:= docker run --rm -it --entrypoint /bin/sh

ifeq ($(DOCKER_HOST), true)
	SF_SRC_BIND_DIR		:= /src
	SF_UID				:= $(shell id -u)
	SF_TF_DOCKER_OPTS	:= --user $(SF_UID) \
 		--mount type=bind,source=$(PROJECT_DIR),destination=$(SF_SRC_BIND_DIR) \
 		-w $(SF_SRC_BIND_DIR) \
		$(DOCKER_ENV_VARS) \
 		$(SF_CMD_DOCKER_IMAGE)

	SF_TF_RUN_CMD := $(SF_DOCKER_RUN_CMD) $(SF_TF_DOCKER_OPTS) terraform
	SF_TF_SHELL_CMD := $(SF_DOCKER_SHELL_CMD) $(SF_TF_DOCKER_OPTS)
else
	SF_TF_RUN_CMD := TF_WORKSPACE=$(SF_WORKSPACE) terraform
	SF_TF_SHELL_CMD := /bin/sh
endif

###### Targets ######

.PHONY: stack-apply
stack-apply: stack-plan
	@$(SF_TF_RUN_CMD) $(SF_WORKING_DIR) apply -auto-approve $(SF_VARS) $(SF_VAR_FILES)

.PHONY: stack-console
stack-console:
	@$(SF_TF_RUN_CMD) $(SF_WORKING_DIR) console $(SF_VARS) $(SF_VAR_FILES)

.PHONY: stack-fmt
stack-fmt:
	@$(SF_TF_RUN_CMD) $(SF_WORKING_DIR) fmt

.PHONY: stack-info
stack-info:
	@echo "Stacks Tools Version: $(SF_STACKS_TOOLS_VERSION)"
	@echo "Stacks Specification Version: $(SF_STACKS_SPEC_VERSION)"
	@echo "Stacks Specification URL: $(SF_STACKS_SPEC_URL)"
	@echo "Stacks Directory: $(SF_STACKS_DIR)"
	@echo "Stack Name: $(STACK_NAME)"
	@echo "Stack Variant Identifier: $(SF_VARIANT_ID)"
	@echo "Stack Environment: $(ENVIRONMENT)"
	@echo "Backend AWS Region: $(SF_REMOTE_REGION)"
	@echo "Backend AWS S3 Bucket: $(SF_REMOTE_BUCKET)"
	@echo "Backend AWS DynamoDB: $(SF_REMOTE_DDB_TABLE)"
	@echo "Terraform Workspace: $(SF_WORKSPACE)"

.PHONY: stack-init
stack-init:
	@$(SF_TF_RUN_CMD) $(SF_WORKING_DIR) init $(SF_REMOTE_BACKEND)

.PHONY: stack-plan
stack-plan: stack-validate
	@$(SF_TF_RUN_CMD) $(SF_WORKING_DIR) plan $(SF_VARS) $(SF_VAR_FILES)

.PHONY: stack-shell
stack-shell:
	@$(SF_TF_SHELL_CMD)

.PHONY: stack-validate
stack-validate:
	@$(SF_TF_RUN_CMD) $(SF_WORKING_DIR) validate
