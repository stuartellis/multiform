# Terraform Stack Tools - Commands
#
# Makefile targets and variables
#
# Requirements: A UNIX shell, jq, GNU Make 3 or above
#
# Set ST_RUN_CONTAINER=true to run Terraform in a Docker container
#
# This provides the Terraform variables: stack_name, environment, variant
#

###### Versions ######

ST_STACKTOOLS_VERSION	:= 0.4.6
ST_STACKS_SPEC_VERSION	:= 0.4.0
ST_STACKS_SPEC_URL		:= https://github.com/stuartellis/multiform/tree/main/docs/terraform-stacks-spec/$(ST_STACKS_SPEC_VERSION)/README.md

###### Docker Image ######

STACK_RUNNER_IMAGE		?= stacktools-runner:developer

###### Options ######

ST_ENABLE_BACKEND	:= true
ST_RUN_CONTAINER	:= true

###### Paths ######

ST_CONTAINER_BIND_DIR	:= /src
ST_BACKEND_DIR			:= $(PROJECT_DIR)/terraform1/stacks/environments
ST_BACKEND_FILE			:= $(ST_BACKEND_DIR)/$(ENVIRONMENT)/backend.json

ifeq ($(ST_RUN_CONTAINER), true)
	ST_STACKS_DIR		:= $(ST_CONTAINER_BIND_DIR)/terraform1/stacks
else
	ST_STACKS_DIR		:= $(PROJECT_DIR)/terraform1/stacks
endif

###### Terraform Variables ######

ifeq ($(MAKECMDGOALS), stack-init)
	ifeq ($(ST_ENABLE_BACKEND), true)
		ST_BACKEND_AWS				:= $(shell cat $(ST_BACKEND_FILE) | jq '.aws')
		ST_AWS_BACKEND_REGION		:= $(shell echo '$(ST_BACKEND_AWS)' | jq '.region')
		ST_AWS_BACKEND_BUCKET		:= $(shell echo '$(ST_BACKEND_AWS)' | jq '.bucket')
		ST_AWS_BACKEND_DDB_TABLE	:= $(shell echo '$(ST_BACKEND_AWS)' | jq '.dynamodb_table')
		ST_AWS_BACKEND_KEY			:= "stacks/$(ENVIRONMENT)/$(STACK_NAME)"
		ST_TF_BACKEND				:= -backend-config=region=$(ST_AWS_BACKEND_REGION) -backend-config=bucket=$(ST_AWS_BACKEND_BUCKET) -backend-config=key=$(ST_AWS_BACKEND_KEY) -backend-config=dynamodb_table=$(ST_AWS_BACKEND_DDB_TABLE)
	else
		ST_TF_BACKEND				:=
	endif
endif

ST_TF_WORKING_DIR	:= -chdir=$(ST_STACKS_DIR)/definitions/$(STACK_NAME)
ST_TF_VAR_FILES		:= -var-file=$(ST_STACKS_DIR)/environments/all/$(STACK_NAME).tfvars -var-file=$(ST_STACKS_DIR)/environments/$(ENVIRONMENT)/$(STACK_NAME).tfvars

ifdef AWS_ACCESS_KEY_ID
	ST_DOCKER_ENV_VARS := -e TF_WORKSPACE=$(ST_WORKSPACE) -e AWS_REGION=$(AWS_REGION) -e AWS_ACCESS_KEY_ID=$(AWS_ACCESS_KEY_ID) -e AWS_SECRET_ACCESS_KEY=$(AWS_SECRET_ACCESS_KEY)
else
	ST_DOCKER_ENV_VARS := -e TF_WORKSPACE=$(ST_WORKSPACE)
endif

ifdef STACK_VARIANT
	ST_WORKSPACE	:= $(STACK_VARIANT)
	ST_VARIANT_ID	:= $(STACK_VARIANT)
	ST_TF_VARS		:= -var="stack_name=$(STACK_NAME)" -var="environment=$(ENVIRONMENT)" -var="variant=$(ST_VARIANT_ID)"
else
	ST_WORKSPACE	:= default
	ST_VARIANT_ID 	:=
	ST_TF_VARS		:= -var="stack_name=$(STACK_NAME)" -var="environment=$(ENVIRONMENT)"
endif

###### Terraform Command ######

ifeq ($(ST_RUN_CONTAINER), true)
	ST_DOCKER_RUN_CMD 		:= docker run --rm
	ST_DOCKER_SHELL_CMD		:= docker run --rm -it --entrypoint /bin/sh

	ST_UID				:= $(shell id -u)
	ST_TF_DOCKER_OPTS	:= --user $(ST_UID) \
 		--mount type=bind,source=$(PROJECT_DIR),destination=$(ST_CONTAINER_BIND_DIR) \
 		-w $(ST_CONTAINER_BIND_DIR) \
		$(ST_DOCKER_ENV_VARS) \
 		$(STACK_RUNNER_IMAGE)

	ST_TF_RUN_CMD := $(ST_DOCKER_RUN_CMD) $(ST_TF_DOCKER_OPTS) terraform
	ST_TF_SHELL_CMD := $(ST_DOCKER_SHELL_CMD) $(ST_TF_DOCKER_OPTS)
else
	ST_TF_RUN_CMD := TF_WORKSPACE=$(ST_WORKSPACE) terraform
	ST_TF_SHELL_CMD := TF_WORKSPACE=$(ST_WORKSPACE) /bin/sh
endif

###### Targets ######

.PHONY: stack-apply
stack-apply: stack-plan
	@$(ST_TF_RUN_CMD) $(ST_TF_WORKING_DIR) apply -auto-approve $(ST_TF_VARS) $(ST_TF_VAR_FILES)

.PHONY: stack-console
stack-console:
	@$(ST_TF_RUN_CMD) $(ST_TF_WORKING_DIR) console $(ST_TF_VARS) $(ST_TF_VAR_FILES)

.PHONY: stack-destroy
stack-destroy: stack-plan
	@$(ST_TF_RUN_CMD) $(ST_TF_WORKING_DIR) apply -destroy -auto-approve $(ST_TF_VARS) $(ST_TF_VAR_FILES)

.PHONY: stack-fmt
stack-fmt:
	@$(ST_TF_RUN_CMD) $(ST_TF_WORKING_DIR) fmt

.PHONY: stack-info
stack-info:
	@echo "Stack Tools Version: $(ST_STACKTOOLS_VERSION)"
	@echo "Stacks Specification Version: $(ST_STACKS_SPEC_VERSION)"
	@echo "Stacks Specification URL: $(ST_STACKS_SPEC_URL)"
	@echo "Stacks Directory: $(ST_STACKS_DIR)"
	@echo "Stack Name: $(STACK_NAME)"
	@echo "Stack Variant Identifier: $(ST_VARIANT_ID)"
	@echo "Stack Environment: $(ENVIRONMENT)"
	@echo "Terraform Workspace: $(ST_WORKSPACE)"

.PHONY: stack-init
stack-init:
	$(ST_TF_RUN_CMD) $(ST_TF_WORKING_DIR) init $(ST_TF_BACKEND)

.PHONY: stack-plan
stack-plan: stack-validate
	@$(ST_TF_RUN_CMD) $(ST_TF_WORKING_DIR) plan $(ST_TF_VARS) $(ST_TF_VAR_FILES)

.PHONY: stack-shell
stack-shell:
	@$(ST_TF_SHELL_CMD)

.PHONY: stack-validate
stack-validate:
	@$(ST_TF_RUN_CMD) $(ST_TF_WORKING_DIR) validate