PWD = $(shell realpath $(dir $(lastword $(MAKEFILE_LIST))))
TEST_FILES := $(filter %_test, $(shell ls bin))

.DEFAULT_GOAL := help

.PHONY: test
test: ## test
	@$(foreach f, $(TEST_FILES), $(shell bash $(f)))

.PHONY: install_bin_ex
install_bin_ex:
	@bash ./bin/install_bin_ex

.PHONY: help
help: ### display help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| sort \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
