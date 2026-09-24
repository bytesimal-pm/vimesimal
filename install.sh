#!/usr/bin/env bash
# Link this repo as ~/.config/nvim (and its tmux config), then install plugins.
set -euo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
config="${XDG_CONFIG_HOME:-$HOME/.config}"
stamp="$(date +%Y%m%d-%H%M%S)"

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

link "$repo" "$config/nvim"
link "$repo/tmux/tmux.conf" "$config/tmux/tmux.conf"

if ! command -v nvim >/dev/null; then
	echo "missing: nvim  (sudo pacman -S neovim), then re-run this script"
	exit 1
fi

nvim --headless "+Lazy! sync" +qa
echo "plugins installed"

for tool in clangd clang-format rg fzf git curl tmux; do
	command -v "$tool" >/dev/null || echo "missing: $tool"
done
