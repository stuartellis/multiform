# Default Makefile

# Configuration for Make

SHELL := /bin/sh
.ONESHELL:
.SHELLFLAGS := -eu -c
.DELETE_ON_ERROR:
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

# Default Target

.DEFAULT_GOAL := stack-info

### Stackform

PROJECT_DIR				:= $(shell pwd)
STACK_NAME				?= example_app
STACK_INSTANCE			?=
ENVIRONMENT				?= dev
DOCKER_HOST				?= true

include make/tools/stackform/stackform-cli.mk
include make/tools/stackform/stackform-tools-container.mk

###
