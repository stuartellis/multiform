# Terraform Stacks - Tools Container
#
# Makefile targets and variables
#
# Requirements: Docker, a UNIX shell, GNU Make 3 or above
#
# Override the versions to change the container build
#
# To build for another CPU architecture, override STACKTOOLS_TARGET_CPU_ARCH
# For example, use arm64 for ARM: STACKTOOLS_TARGET_CPU_ARCH=arm64
#

###### Versions ######

STACKTOOLS_TERRAFORM_VERSION		?= 1.3.5
STACKTOOLS_DOCKER_IMAGE_BASE 		?= alpine:3.16.3
STACKTOOLS_VERSION					?= developer

###### Tools Container ######

STACKTOOLS_APP_NAME					:= stackform-tools
STACKTOOLS_SOURCE_HOST_DIR			:= $(shell pwd)
STACKTOOLS_DOCKER_FILE				:= $(shell pwd)/docker/stackform-tools.dockerfile
STACKTOOLS_IMAGE_TAG				:= $(STACKTOOLS_APP_NAME):$(STACKTOOLS_VERSION)

###### Docker ######

STACKTOOLS_DOCKER_BUILD_CMD 	:= docker build
STACKTOOLS_TARGET_CPU_ARCH		?= $(shell uname -m)
STACKTOOLS_TARGET_PLATFORM		?= linux/$(STACKTOOLS_TARGET_CPU_ARCH)

###### Targets ######

.PHONY stacktools-build:
stacktools-build:
	@$(STACKTOOLS_DOCKER_BUILD_CMD) $(STACKTOOLS_SOURCE_HOST_DIR) --platform $(STACKTOOLS_TARGET_PLATFORM) -f $(STACKTOOLS_DOCKER_FILE) -t $(STACKTOOLS_IMAGE_TAG) \
	--build-arg DOCKER_IMAGE_BASE=$(STACKTOOLS_DOCKER_IMAGE_BASE) \
	--build-arg TERRAFORM_VERSION=$(STACKTOOLS_TERRAFORM_VERSION) \
	--label org.opencontainers.image.version=$(STACKTOOLS_VERSION)

.PHONY stacktools-info:
stacktools-info:
	@echo "App Name: $(STACKTOOLS_APP_NAME)"
	@echo "App Version: $(STACKTOOLS_VERSION)"
	@echo "Docker File: $(STACKTOOLS_DOCKER_FILE)"
	@echo "Docker Image: $(STACKTOOLS_IMAGE_TAG)"
