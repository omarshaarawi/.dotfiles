STOW := stow
STOW_FLAGS := -v -t $(HOME)

# All directories to stow
STOW_DIRS := .scripts .zsh

# Individual files to stow
STOW_FILES := .gitconfig .gitconfig-personal .gitconfig-work .wezterm.lua .zshrc

# .config subdirectories to stow
CONFIG_DIRS := nvim zellij ghostty

# Backup suffix
BACKUP_SUFFIX := .backup_$(shell date +%Y%m%d_%H%M%S)

.PHONY: all stow unstow restow list help validate backup

all: stow

stow: backup
	@echo "Stowing dotfiles..."
	@$(STOW) $(STOW_FLAGS) $(STOW_DIRS)
	@for file in $(STOW_FILES); do \
		ln -sf $(PWD)/$$file $(HOME)/$$file; \
	done
	@for dir in $(CONFIG_DIRS); do \
		ln -sf $(PWD)/.config/$$dir $(HOME)/.config/$$dir; \
	done

unstow:
	@echo "Unstowing dotfiles..."
	@$(STOW) -D $(STOW_FLAGS) $(STOW_DIRS)
	@for file in $(STOW_FILES); do \
		rm -f $(HOME)/$$file; \
	done
	@for dir in $(CONFIG_DIRS); do \
		rm -f $(HOME)/.config/$$dir; \
	done

restow: unstow stow

backup:
	@echo "Backing up existing configurations..."
	@for dir in $(CONFIG_DIRS); do \
		echo $(HOME)/.config/$$dir$(BACKUP_SUFFIX); \
		if [ -e $(HOME)/.config/$$dir ]; then \
			mv $(HOME)/.config/$$dir $(HOME)/.config/$$dir$(BACKUP_SUFFIX); \
			echo "Backed up $$dir to $$dir$(BACKUP_SUFFIX)"; \
		fi; \
	done
	@for file in $(STOW_FILES); do \
		if [ -e $(HOME)/$$file ]; then \
			mv $(HOME)/$$file $(HOME)/$$file$(BACKUP_SUFFIX); \
			echo "Backed up $$file to $$file$(BACKUP_SUFFIX)"; \
		fi; \
	done

validate:
	@echo "Validating stowed items..."
	@for dir in $(STOW_DIRS); do \
		[ -L $(HOME)/$$dir ] && echo "$$dir: OK" || echo "$$dir: MISSING"; \
	done
	@for file in $(STOW_FILES); do \
		[ -L $(HOME)/$$file ] && echo "$$file: OK" || echo "$$file: MISSING"; \
	done
	@for dir in $(CONFIG_DIRS); do \
		[ -L $(HOME)/.config/$$dir ] && echo ".config/$$dir: OK" || echo ".config/$$dir: MISSING"; \
	done

list:
	@echo "Directories to stow: $(STOW_DIRS)"
	@echo "Files to stow: $(STOW_FILES)"
	@echo ".config subdirectories to stow: $(CONFIG_DIRS)"

help:
	@echo "Available targets:"
	@echo "  stow    - Stow all dotfiles (includes backup)"
	@echo "  unstow  - Unstow all dotfiles"
	@echo "  restow  - Restow all dotfiles"
	@echo "  backup  - Backup existing configurations"
	@echo "  validate- Validate stowed symlinks"
	@echo "  list    - List all items to be stowed"
	@echo "  help    - Show this help message"
