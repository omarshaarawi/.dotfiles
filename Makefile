# Variables
DOTFILES_DIR := $(HOME)/.dotfiles
STOW_DIRS := $(filter-out .git .gitignore Makefile README.md install_scripts.sh,$(wildcard .[!.]* *))
SCRIPTS_DIR=".scripts"
CONFIG_DIR=".config"
TIMESTAMP := $(shell date +%Y%m%d_%H%M%S)


.PHONY: all init list stow unstow restow

all: list

# initialize the dirs if they don't exist
init:
	if [ ! -d $(HOME)/$(SCRIPTS_DIR) ]; then \
		@mkdir -p $(HOME)/$(SCRIPTS_DIR); \
	fi
	if [ ! -d $(HOME)/$(CONFIG_DIR) ]; then \
		@mkdir -p $(HOME)/$(CONFIG_DIR); \
	fi


# List all items that can be stowed
list:
	@echo "Available items to stow:"
	@for item in $(STOW_DIRS); do \
		echo "  $$item"; \
	done

# Stow all items
stow:
	@for item in $(STOW_DIRS); do \
		if [ -d "$$item" ]; then \
			echo "Stowing directory: $$item"; \
			stow -v -R -t $(HOME) $$item; \
		else \
			echo "Stowing file: $$item"; \
			ln -svf $(DOTFILES_DIR)/$$item $(HOME)/$$item; \
		fi; \
	done

# Unstow all items
unstow:
	@for item in $(STOW_DIRS); do \
		if [ -d "$$item" ]; then \
			echo "Unstowing directory: $$item"; \
			stow -v -D -t $(HOME) $$item; \
		else \
			echo "Removing symlink: $$item"; \
			rm -vf $(HOME)/$$item; \
		fi; \
	done

restow: unstow stow

# Help
help:
	@echo "Available targets:"
	@echo "  list        - List all items that can be stowed"
	@echo "  stow        - Stow all items"
	@echo "  unstow      - Unstow all items"
	@echo "  restow      - Restow all items"
	@echo "  help        - Show this help message"
