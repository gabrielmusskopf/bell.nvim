# ==========================================================================
# Makefile -- Instalacao automatica do plugin bell.nvim + compilador bellc
# ==========================================================================

NVIM_PLUGIN_DIR = $(HOME)/.config/nvim/plugin
DATA_DIR        = $(HOME)/.local/share/nvim/bell.nvim

.PHONY: all install uninstall

all: install

install:
	@chmod +x install.sh
	@./install.sh

uninstall:
	rm -f "$(NVIM_PLUGIN_DIR)/bell.lua"
	rm -rf "$(DATA_DIR)"
	@echo "Plugin bell.nvim e binario bellc removidos com sucesso."
