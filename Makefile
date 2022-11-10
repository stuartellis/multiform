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

### Multiform Targets

include make/multiform/stack-terraform-cli.mk

###
