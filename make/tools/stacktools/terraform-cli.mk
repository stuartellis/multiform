# Stack Tools - Terraform Commands
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

ST_STACKTOOLS_VERSION	:= 0.4.12
ST_STACKS_SPEC_VERSION	:= 0.4.0
ST_STACKS_SPEC_URL		:= https://github.com/stuartellis/multiform/tree/main/docs/terraform-stacks-spec/$(ST_STACKS_SPEC_VERSION)/README.md

###### Docker Image ######

STACK_RUNNER_IMAGE		?= stacktools-runner:developer

###### Options ######

ST_ENABLE_BACKEND	?= true
ST_RUN_CONTAINER	?= true

###### Paths ######

ST_HOST_DEFS_DIR		:= $(PROJECT_DIR)/terraform1/stacks/definitions
ST_HOST_ENVS_DIR		:= $(PROJECT_DIR)/terraform1/stacks/environments
ST_HOST_MODULES_DIR		:= $(PROJECT_DIR)/terraform1/stacks/modules
ST_HOST_TMP_DIR			:= $(PROJECT_DIR)/terraform1/stacks/tmp
ST_BACKEND_FILE			:= $(ST_HOST_ENVS_DIR)/$(ENVIRONMENT)/backend.json
ST_CONTAINER_BIND_DIR	:= /src

ifeq ($(ST_RUN_CONTAINER), true)
	ST_TF_BASE_DIR		:= $(ST_CONTAINER_BIND_DIR)/terraform1/stacks
else
	ST_TF_BASE_DIR		:= $(PROJECT_DIR)/terraform1/stacks
endif

###### Terraform Variables ######

ifeq ($(MAKECMDGOALS), stack-init)
	ifeq ($(ST_ENABLE_BACKEND), true)
		ST_BACKEND_AWS				:= $(shell cat $(ST_BACKEND_FILE) | jq '.aws')
		ST_AWS_BACKEND_REGION		:= $(shell echo '$(ST_BACKEND_AWS)' | jq '.region')
		ST_AWS_BACKEND_BUCKET		:= $(shell echo '$(ST_BACKEND_AWS)' | jq '.bucket')
		ST_AWS_BACKEND_DDB_TABLE	:= $(shell echo '$(ST_BACKEND_AWS)' | jq '.dynamodb_table')
		ST_AWS_BACKEND_KEY			:= "stacks/$(ENVIRONMENT)/$(STACK_NAME)"
		ST_TF_BACKEND_OPT			:= -backend-config=region=$(ST_AWS_BACKEND_REGION) -backend-config=bucket=$(ST_AWS_BACKEND_BUCKET) -backend-config=key=$(ST_AWS_BACKEND_KEY) -backend-config=dynamodb_table=$(ST_AWS_BACKEND_DDB_TABLE)
	else
		ST_TF_BACKEND_OPT			:=
	endif
endif

ifdef STACK_VARIANT
	ifeq ($(MAKECMDGOALS), stack-forget)
		ST_WORKSPACE	:= default
	else
		ST_WORKSPACE	:= $(STACK_VARIANT)
	endif
	ST_VARIANT_ID	:= $(STACK_VARIANT)
	ST_TF_VARS_OPT	:= -var="stack_name=$(STACK_NAME)" -var="environment=$(ENVIRONMENT)" -var="variant=$(ST_VARIANT_ID)"
else
	ifeq ($(MAKECMDGOALS), stack-forget)
		ST_VARIANT_ID 	:= default
	else
		ST_VARIANT_ID 	:=
	endif
	ST_WORKSPACE	:= default
	ST_TF_VARS_OPT	:= -var="stack_name=$(STACK_NAME)" -var="environment=$(ENVIRONMENT)"
endif

ST_DOCKER_ENV_VARS := -e TF_WORKSPACE=$(ST_WORKSPACE)

ifdef AWS_ACCESS_KEY_ID
	ST_DOCKER_ENV_VARS += -e TF_WORKSPACE=$(ST_WORKSPACE) -e AWS_REGION=$(AWS_REGION) -e AWS_ACCESS_KEY_ID=$(AWS_ACCESS_KEY_ID) -e AWS_SECRET_ACCESS_KEY=$(AWS_SECRET_ACCESS_KEY) -e AWS_SESSION_TOKEN=$(AWS_SESSION_TOKEN)
endif

ifdef DD_APP_KEY
	ST_DOCKER_ENV_VARS += -e DD_APP_KEY=$(DD_APP_KEY) -e DD_API_KEY=$(DD_API_KEY)
endif

ST_TF_STACK_DIR		:= $(ST_TF_BASE_DIR)/definitions/$(STACK_NAME)
ST_TF_TMP_DIR		:= $(ST_TF_BASE_DIR)/tmp
ST_TF_PLAN_FILE		:= $(STACK_NAME)-$(ENVIRONMENT)-$(ST_WORKSPACE).tfplan
ST_TF_OUTPUT_PATH	:= $(ST_TF_TMP_DIR)/$(ST_TF_PLAN_FILE)
ST_TF_CHDIR_OPT		:= -chdir=$(ST_TF_BASE_DIR)/definitions/$(STACK_NAME)
ST_TF_PLAN_FILE_OPT	:= -out=$(ST_TF_OUTPUT_PATH)
ST_TF_VAR_FILES_OPT	:= -var-file=$(ST_TF_BASE_DIR)/environments/all/$(STACK_NAME).tfvars -var-file=$(ST_TF_BASE_DIR)/environments/$(ENVIRONMENT)/$(STACK_NAME).tfvars

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

.PHONY: stacktools-info
stacktools-info:
	@echo "Stack Tools Version: $(ST_STACKTOOLS_VERSION)"
	@echo "Stacks Specification Version: $(ST_STACKS_SPEC_VERSION)"
	@echo "Stacks Specification URL: $(ST_STACKS_SPEC_URL)"
	@echo "Stacks Directory: $(ST_TF_BASE_DIR)"

.PHONY: stacks-environments
stacks-environments:
	@ls -d $(ST_HOST_ENVS_DIR)/*/ | xargs -n 1 basename | sed s/all// | grep '\S'

.PHONY: stacks-list
stacks-list:
	@ls -d $(ST_HOST_DEFS_DIR)/*/ | xargs -n 1 basename | sed s/template// | grep '\S'

.PHONY: stacks-new-tree
stacks-new-tree:
	@mkdir -p $(ST_HOST_DEFS_DIR)
	@echo "# Terraform Stacks" > $(ST_HOST_DEFS_DIR)/README.md
	@mkdir -p $(ST_HOST_DEFS_DIR)/template
	@echo "# Terraform Stack" > $(ST_HOST_DEFS_DIR)/template/README.md
	@mkdir -p $(ST_HOST_ENVS_DIR)
	@echo "# Terraform Environments" > $(ST_HOST_ENVS_DIR)/README.md
	@mkdir -p $(ST_HOST_ENVS_DIR)/all
	@echo "# Terraform Variables Active for All Environments" > $(ST_HOST_ENVS_DIR)/all/README.md
	@mkdir -p $(ST_HOST_MODULES_DIR)
	@echo "# Terraform Modules" > $(ST_HOST_MODULES_DIR)/README.md
	@mkdir -p $(ST_HOST_TMP_DIR)
	@echo "# Terraform Generated Files" > $(ST_HOST_TMP_DIR)/README.md

###### Stack Targets ######

.PHONY: stack-apply
stack-apply:
	@$(ST_TF_RUN_CMD) $(ST_TF_CHDIR_OPT) apply -auto-approve $(ST_TF_OUTPUT_PATH)

.PHONY: stack-check-fmt
stack-check-fmt:
	@$(ST_TF_RUN_CMD) $(ST_TF_CHDIR_OPT) fmt -check -diff -recursive

.PHONY: stack-console
stack-console:
	@$(ST_TF_RUN_CMD) $(ST_TF_CHDIR_OPT) console $(ST_TF_VARS_OPT) $(ST_TF_VAR_FILES_OPT)

.PHONY: stack-destroy
stack-destroy:
	@$(ST_TF_RUN_CMD) $(ST_TF_CHDIR_OPT) apply -destroy -auto-approve $(ST_TF_VARS_OPT) $(ST_TF_VAR_FILES_OPT)

.PHONY: stack-fmt
stack-fmt:
	@$(ST_TF_RUN_CMD) $(ST_TF_CHDIR_OPT) fmt

.PHONY: stack-forget
stack-forget:
	@$(ST_TF_RUN_CMD) $(ST_TF_CHDIR_OPT) workspace delete $(ST_VARIANT_ID)

.PHONY: stack-info
stack-info:
	@echo "Stack Name: $(STACK_NAME)"
	@echo "Stack Variant Identifier: $(ST_VARIANT_ID)"
	@echo "Stack Environment: $(ENVIRONMENT)"
	@echo "Terraform Workspace: $(ST_WORKSPACE)"

.PHONY: stack-init
stack-init:
	@$(ST_TF_RUN_CMD) $(ST_TF_CHDIR_OPT) init $(ST_TF_BACKEND_OPT)

.PHONY: stack-new
stack-new:
	@mkdir -p $(ST_HOST_DEFS_DIR)/$(STACK_NAME)
	@ls -d $(ST_HOST_ENVS_DIR)/*/ | sed 's/$$/$(STACK_NAME).tfvars/' | xargs touch
	@cp -r $(ST_HOST_DEFS_DIR)/template/* $(ST_HOST_DEFS_DIR)/$(STACK_NAME)

.PHONY: stack-plan
stack-plan:
	@$(ST_TF_RUN_CMD) $(ST_TF_CHDIR_OPT) plan $(ST_TF_PLAN_FILE_OPT) $(ST_TF_VARS_OPT) $(ST_TF_VAR_FILES_OPT)

.PHONY: stack-plan-json
stack-plan-json:
	@$(ST_TF_RUN_CMD) $(ST_TF_CHDIR_OPT) show -json

.PHONY: stack-rm
stack-rm:
	@ls -d $(ST_HOST_ENVS_DIR)/*/ | sed 's/$$/$(STACK_NAME).tfvars/' | xargs rm
	@rm -r $(ST_HOST_DEFS_DIR)/$(STACK_NAME)

.PHONY: stack-shell
stack-shell:
	@$(ST_TF_SHELL_CMD)

.PHONY: stack-validate
stack-validate:
	@$(ST_TF_RUN_CMD) $(ST_TF_CHDIR_OPT) validate
