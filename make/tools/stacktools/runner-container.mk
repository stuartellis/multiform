# Terraform Stack Tools - Runner Container
#
# Makefile targets and variables
#
# Requirements: Docker, a UNIX shell, GNU Make 3 or above
#
# Override the versions variables to change the container build
#
# To build for another CPU architecture, override ST_RUNNER_TARGET_CPU_ARCH
# For example, use arm64 for ARM: ST_RUNNER_TARGET_CPU_ARCH=arm64
#

###### Versions ######

ST_RUNNER_TERRAFORM_VERSION		?= 1.3.6
ST_RUNNER_IMAGE_BASE			?= alpine:3.17.0
ST_RUNNER_VERSION				?= developer

###### Platform ######

ST_RUNNER_TARGET_CPU_ARCH		?= $(shell uname -m)
ST_RUNNER_TARGET_PLATFORM		?= linux/$(ST_RUNNER_TARGET_CPU_ARCH)

###### Runner Container Image ######

ST_RUNNER_APP_NAME			:= stacktools-runner
ST_RUNNER_SOURCE_HOST_DIR	:= $(shell pwd)
ST_RUNNER_DOCKER_FILE		:= $(shell pwd)/docker/tools/stacktools/runner.dockerfile
ST_RUNNER_IMAGE_TAG			:= $(ST_RUNNER_APP_NAME):$(ST_RUNNER_VERSION)

###### Docker ######

ST_RUNNER_DOCKER_BUILD_CMD	:= docker build

###### Targets ######

.PHONY stackrunner-build:
stackrunner-build:
	@$(ST_RUNNER_DOCKER_BUILD_CMD) $(ST_RUNNER_SOURCE_HOST_DIR) --platform $(ST_RUNNER_TARGET_PLATFORM) -f $(ST_RUNNER_DOCKER_FILE) -t $(ST_RUNNER_IMAGE_TAG) \
	--build-arg DOCKER_IMAGE_BASE=$(ST_RUNNER_IMAGE_BASE) \
	--build-arg TERRAFORM_VERSION=$(ST_RUNNER_TERRAFORM_VERSION) \
	--label org.opencontainers.image.version=$(ST_RUNNER_VERSION)

.PHONY stackrunner-info:
stackrunner-info:
	@echo "App Name: $(ST_RUNNER_APP_NAME)"
	@echo "App Version: $(ST_RUNNER_VERSION)"
	@echo "Docker File: $(ST_RUNNER_DOCKER_FILE)"
	@echo "Docker Image: $(ST_RUNNER_IMAGE_TAG)"
