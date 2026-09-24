#!/usr/bin/env bash
# Link this repo as ~/.config/nvim, then install plugins.
set -euo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
dst="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"

if [ -L "$dst" ] && [ "$(readlink -f "$dst")" = "$repo" ]; then
	echo "ok   $dst"
else
	if [ -e "$dst" ] || [ -L "$dst" ]; then
		bak="$dst.bak.$(date +%Y%m%d-%H%M%S)"
		mv "$dst" "$bak"
		echo "bak  $dst -> $bak"
	fi
	ln -s "$repo" "$dst"
	echo "link $dst -> $repo"
fi

if ! command -v nvim >/dev/null; then
	echo "missing: nvim  (sudo pacman -S neovim), then re-run this script"
	exit 1
fi

nvim --headless "+Lazy! sync" +qa
echo "plugins installed"

for tool in clangd clang-format rg fzf git curl; do
	command -v "$tool" >/dev/null || echo "missing: $tool"
done
