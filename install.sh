#!/usr/bin/env bash
# ==========================================================================
# Script de Instalacao Automatica do Plugin bell.nvim
# Faz download do compilador 'bellc' direto do GitHub (bell-lang) e compila!
# ==========================================================================
set -e

REPO_URL="${BELL_REPO_URL:-https://github.com/gabrielmusskopf/bell-lang.git}"
BRANCH="${BELL_BRANCH:-main}"

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/nvim/bell.nvim"
SRC_DIR="$DATA_DIR/src"
NVIM_PLUGIN_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/nvim/plugin"

echo "==> [1/3] Baixando codigo-fonte do compilador bellc do GitHub..."
echo "    Repositorio: $REPO_URL (branch: $BRANCH)"
mkdir -p "$DATA_DIR"

if [ -d "$SRC_DIR/.git" ]; then
    git -C "$SRC_DIR" remote set-url origin "$REPO_URL"
    git -C "$SRC_DIR" fetch origin
    git -C "$SRC_DIR" checkout "$BRANCH"
    git -C "$SRC_DIR" pull origin "$BRANCH"
else
    rm -rf "$SRC_DIR"
    git clone --branch "$BRANCH" "$REPO_URL" "$SRC_DIR"
fi

echo "==> [2/3] Compilando o binario 'bellc' em $SRC_DIR..."
make -C "$SRC_DIR" clean
make -C "$SRC_DIR" TARGET=bellc

echo "==> [3/3] Instalando plugin bell.nvim em: $NVIM_PLUGIN_DIR"
mkdir -p "$NVIM_PLUGIN_DIR"
ln -sfn "$PLUGIN_DIR/plugin/bell.lua" "$NVIM_PLUGIN_DIR/bell.lua"

echo ""
echo "Sucesso! Compilador 'bellc' compilado em: $SRC_DIR/bellc"
echo "Plugin Neovim instalado em: $NVIM_PLUGIN_DIR/bell.lua"
echo ""
echo "Para testar agora:"
echo "  nvim $PLUGIN_DIR/exemplo.bell"
