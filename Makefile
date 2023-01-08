# Default Makefile

# Configuration for Make

SHELL := /bin/sh
.ONESHELL:
.SHELLFLAGS := -eu -c
.DELETE_ON_ERROR:
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

# Default Target

.DEFAULT_GOAL := stacktools-info

### Required for Stack Tools

PROJECT_DIR				:= $(shell pwd)
ENVIRONMENT				?= dev

include make/tools/stacktools/*.mk

###
