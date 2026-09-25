#!/usr/bin/env bash
# Install the system packages, link this repo as ~/.config/nvim (plus its tmux
# and asm-lsp configs), then install plugins and tree-sitter parsers.
# Safe to re-run: pacman skips installed packages, links are checked first.
set -euo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
config="${XDG_CONFIG_HOME:-$HOME/.config}"
stamp="$(date +%Y%m%d-%H%M%S)"

# --- Packages -----------------------------------------------------------------
packages=(
	# Editor + terminal tools
	neovim git curl ripgrep fzf tmux
	# Tree-sitter parser builder (nvim-treesitter uses it with gcc)
	tree-sitter-cli gcc
	# C: clangd + clang-format
	clang make
	# NASM, plus rust to build asm-lsp
	nasm rust
	# QML: qmlls6
	qt6-declarative
	# Python
	pyright ruff
	# Shell
	bash-language-server shellcheck
	# Lua
	lua-language-server
	# TOML, JSON
	taplo-cli vscode-json-languageserver
)

if command -v pacman >/dev/null; then
	# pacman -T prints only the packages that aren't installed yet
	mapfile -t missing_pkgs < <(pacman -T "${packages[@]}" || true)
	if [ "${#missing_pkgs[@]}" -gt 0 ]; then
		echo "==> pacman: installing ${missing_pkgs[*]}"
		sudo pacman -S --needed "${missing_pkgs[@]}"
	else
		echo "==> pacman: all packages installed"
	fi
else
	echo "pacman not found; install these yourself: ${packages[*]}"
fi

# asm-lsp isn't packaged; build it with cargo (~2 min, once)
export PATH="$HOME/.cargo/bin:$PATH"
if ! command -v asm-lsp >/dev/null && command -v cargo >/dev/null; then
	echo "==> cargo: installing asm-lsp"
	cargo install asm-lsp
fi

# --- Links --------------------------------------------------------------------
link() {
	local src="$1" dst="$2"
	if [ -L "$dst" ] && [ "$(readlink -f "$dst")" = "$(readlink -f "$src")" ]; then
		echo "ok   $dst"
		return
	fi
	if [ -e "$dst" ] || [ -L "$dst" ]; then
		mv "$dst" "$dst.bak.$stamp"
		echo "bak  $dst -> $dst.bak.$stamp"
	fi
	mkdir -p "$(dirname "$dst")"
	ln -s "$src" "$dst"
	echo "link $dst -> $src"
}

echo "==> linking configs"
link "$repo" "$config/nvim"
link "$repo/tmux/tmux.conf" "$config/tmux/tmux.conf"
link "$repo/asm-lsp/.asm-lsp.toml" "$config/asm-lsp/.asm-lsp.toml"

if ! command -v nvim >/dev/null; then
	echo "missing: nvim  (sudo pacman -S neovim), then re-run this script"
	exit 1
fi

# --- Neovim plugins + parsers -------------------------------------------------
echo "==> neovim plugins"
nvim --headless "+Lazy! sync" +qa

if command -v tree-sitter >/dev/null; then
	echo "==> tree-sitter parsers"
	nvim --headless "+VimesimalTSInstall" +qa
fi

# --- Check --------------------------------------------------------------------
echo "==> check"
missing=0
for tool in nvim clangd clang-format rg fzf git curl tmux nasm asm-lsp tree-sitter \
	qmlls6 pyright-langserver ruff bash-language-server shellcheck lua-language-server \
	taplo vscode-json-language-server; do
	if ! command -v "$tool" >/dev/null; then
		echo "missing: $tool"
		missing=1
	fi
done
[ "$missing" -eq 0 ] && echo "all tools found"
echo "done"
