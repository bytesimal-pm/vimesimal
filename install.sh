#!/usr/bin/env bash
# Link this repo as ~/.vim and ~/.vimrc, then install plugins.
set -euo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
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
	ln -s "$src" "$dst"
	echo "link $dst -> $src"
}

link "$repo" "$HOME/.vim"
link "$repo/vimrc" "$HOME/.vimrc"

plug="$repo/autoload/plug.vim"
if [ ! -f "$plug" ]; then
	curl -fsLo "$plug" --create-dirs \
		https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi

vim -es -u "$repo/vimrc" -i NONE -c 'PlugInstall --sync' -c 'qa' || true
echo "plugins installed"

for tool in clangd clang-format rg fzf; do
	command -v "$tool" >/dev/null || echo "missing: $tool"
done
