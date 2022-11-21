# Default Makefile

# Configuration for Make

SHELL := /bin/bash
.ONESHELL:
.SHELLFLAGS := -eu -c
.DELETE_ON_ERROR:
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules


# Project Variables

PROJECT_NAME			?= multiform
PROJECT_MAINTAINERS		?= FIXME
PROJECT_DIR				:= $(shell pwd)
STACK_NAME				?= example_app
STACK_INSTANCE			?=
ENVIRONMENT				?= dev

# Default Target

.DEFAULT_GOAL := info


## Project Targets

.PHONY: clean
clean:
	rm -rf tmp
	rm -rf out

.PHONY: info
info:
	@echo "Project: $(PROJECT_NAME)"
	@echo "Maintainers: $(PROJECT_MAINTAINERS)"
	@echo "Target Environment: $(ENVIRONMENT)"

### Stackform Targets

include make/tools/stackform/stackform-cli.mk
include make/tools/stackform/stackform-py.mk

###
