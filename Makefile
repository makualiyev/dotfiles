.DEFAULT_GOAL := help
DOTFILES := $(shell pwd)

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | \
		awk 'BEGIN{FS=":.*?## "}{printf "  \033[36m%-12s\033[0m %s\n",$$1,$$2}'

all: ## Full setup: packages + symlinks + default shell
	@bash $(DOTFILES)/install.sh all

link: ## Symlink dotfiles into $$HOME
	@bash $(DOTFILES)/install.sh link

packages: ## Install apt packages + language toolchains
	@bash $(DOTFILES)/install.sh packages

shell: ## Switch default shell to zsh
	@bash $(DOTFILES)/install.sh shell

.PHONY: help all link packages shell
