SERVICE = bin_scripts
DIRS := $(filter-out $(EXCLUDES), $(wildcard ??*))
PWD = $(shell realpath $(dir $(lastword $(MAKEFILE_LIST))))
SHFMT_REPO := mvdan/shfmt
SHFMT_VERSION := v3-alpine
BIN_SCRIPTS_ENV := ${BIN_SCRIPTS}
SHFMT_IMAGE_NAME := $(SHFMT_REPO):$(SHFMT_VERSION)
SHFMT_IMAGE := $(shell docker images $(SHFMT_IMAGE_NAME) -q)
TEST_FILES := $(filter %_test, $(shell ls bin))

.DEFAULT_GOAL := help

.PHONY: init
init: ## init
	install_bin_ex
	pull_shfmt
	pre_commit_hook

.PHONY: install_bin_ex
install_bin_ex: ## install bin ex
	@bash $(PWD)/bin/install/install_bin_ex

.PHONY: pre_commit_hook
pre_commit_hook:
	@cp -f $(PWD)/ci/pre-commit $(PWD)/.git/hooks/pre-commit

.PHONY: pull_shfmt
pull_shfmt: ## pull shfmt
	@docker pull $(SHFMT_IMAGE_NAME)

.PHONY: run_shfmt
run_shfmt: ## run shfmt
	@docker run -w /app -v $(PWD):/app $(SHFMT_IMAGE) shfmt -i 2 -ci -w /app/$(FILE)

.PHONY: run_test
run_test: ## test
	@$(foreach f, $(TEST_FILES), $(shell bash $(f)))

.PHONY: help
help: ### display help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| sort \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
