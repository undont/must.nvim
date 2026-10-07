.PHONY: check test fmt help

check: ## run luacheck
	@luacheck .

test: ## run all busted tests
	@busted

fmt: ## run stylua on this codebase
	@echo 'running stylua...'
	@stylua .
	@echo 'stylua complete'

fmt-check: ## run stylua on this codebase
	@echo 'running stylua --check...'
	@stylua -c .
	@echo 'stylua --check complete'

help: ## show the help prompt
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
