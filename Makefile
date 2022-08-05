SERVICE = bin_scripts
DIRS := $(filter-out $(EXCLUDES), $(wildcard ??*))
PWD = $(shell realpath $(dir $(lastword $(MAKEFILE_LIST))))
BIN_SCRIPTS_ENV := ${BIN_SCRIPTS}
BIN_SCRIPTS := $(PWD)
BIN_SCRIPTS_BIN_EXTERNAL := $(PWD)/bin/external
BIN_SCRIPTS_BIN_OUTS := $(PWD)/bin/outs
TEST_FILES := $(filter %_test, $(shell ls tests))
SHFMT_REPO := mvdan/shfmt
SHFMT_VERSION := v3-alpine
SHFMT_IMAGE_NAME := $(SHFMT_REPO):$(SHFMT_VERSION)
SHFMT_IMAGE := $(shell docker images $(SHFMT_IMAGE_NAME) -q)
GO_REPO := golang
GO_VERSION := 1.18-alpine
GO_IMAGE_NAME := $(GO_REPO):$(GO_VERSION)
GO_IMAGE := $(shell docker images $(GO_IMAGE_NAME) -q)

.DEFAULT_GOAL := help

.PHONY: init
init: ## init
	make pull_go
	make pull_shfmt
	make install_bin_external
	make install_bin_outs
	make pre_commit_hook

.PHONY: install_bin_external
install_bin_external: ## install bin external
	@bash $(PWD)/scripts/install_bin_external

.PHONY: install_bin_outs
install_bin_outs: ## install bin outs
	@bash $(PWD)/scripts/install_bin_outs

.PHONY: pre_commit_hook
pre_commit_hook:
	@cp -f $(PWD)/scripts/pre-commit $(PWD)/.git/hooks/pre-commit

.PHONY: pull_go
pull_go: ## pull go
	@docker pull $(GO_IMAGE_NAME)

.PHONY: pull_shfmt
pull_shfmt: ## pull shfmt
	@docker pull $(SHFMT_IMAGE_NAME)

.PHONY: run_shfmt
run_shfmt: ## run shfmt
	@docker run -w /app -v $(PWD):/app $(SHFMT_IMAGE) shfmt -i 2 -ci -w /app/$(FILE)

.PHONY: run_go
run_go: ## run go
	@docker run -w /app -v $(PWD):/app $(GO_IMAGE) go $(PARAM)

.PHONY: go_fmt
go_fmt: ## go fmt
	@docker run -w /app -v $(PWD):/app $(GO_IMAGE) gofmt -w /app/$(FILE)

.PHONY: clean
clean: ## clean bin outputs
	@rm -rf $(BIN_SCRIPTS_BIN_EXTERNAL)
	@rm -rf $(BIN_SCRIPTS_BIN_OUTS)

.PHONY: go_build
go_build: ## go build
	@docker run -w /app -v $(PWD):/app $(GO_IMAGE) /bin/sh -c "GOOS=$(GOOS) GOARCH=$(GOARCH) go build -o /app/$(OUT_PATH) /app/$(SRC_PATH)"

.PHONY: bin_test
bin_test: ## test
	@$(foreach f, $(TEST_FILES), $(shell bash tests/$(f)))

.PHONY: help
help: ### display help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| sort \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
