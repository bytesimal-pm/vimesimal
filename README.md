# vimesimal

Modular Vim 9 config: one global theme and global plugins, plus separate config and plugins for each language.

```
vimrc                     entry point
core/options.vim          global options (line numbers, search, undo, …)
core/keymaps.vim          global keymaps (leader = Space)
core/plugins.vim          global plugin list (vim-plug) + pulls in lang/*/plugins.vim
plugin-config/*.vim       settings for global plugins
colors/vimesimal.vim      theme (transparent bg, matches kitty)
autoload/vimesimal.vim    shared palette
lang/<name>/plugins.vim   language-only plugins
lang/<name>/config.vim    language LSP server, formatter, maps
after/ftplugin/<name>.vim language spacing / indent style
```

## Install

```sh
./install.sh             # links ~/.vim and ~/.vimrc here, installs plugins
sudo pacman -S clang     # clangd + clang-format for C
```

## Features

| | |
|---|---|
| Syntax highlight | `colors/vimesimal.vim`, vim-c-cpp-modern |
| Auto suggest | vim-lsp + asyncomplete (LSP, buffer words, paths) |
| Nest | tab guides via `listchars`, indentLine for spaces, rainbow brackets |
| Line | relative numbers, cursorline, lightline, gitgutter |
| Navigate | fzf, fern tree, LSP go-to |

## Keys

| Key | Action |
|---|---|
| `<Space>f` / `g` / `b` / `/` / `r` | files / ripgrep / buffers / lines / recent |
| `<Space>e` | file tree (`l` open, `h` collapse) |
| `gd` `gD` `gr` `gi` `gy` `K` | definition / declaration / references / impl / type / hover |
| `[d` `]d` `<Space>d` | prev / next / list diagnostics |
| `<Space>rn` `<Space>ca` | rename / code action |
| `<Space>o` `<Space>S` | document / workspace symbols |
| `Tab` `S-Tab` `CR` `C-Space` | completion next / prev / accept / force |
| `C-h/j/k/l` `S-h/l` | windows / buffers |
| `<Space>cf` `<Space>a` | (C) clang-format / toggle .c ↔ .h |

## C: kernel style

Hard tabs, 8 wide, 80 columns, kernel `cinoptions`. `clang-format` and clangd fall back to a Linux-style profile when a project has no `.clang-format` of its own.

## Adding a language

1. `lang/<name>/plugins.vim`: `Plug '…', {'for': '<name>'}`
2. `lang/<name>/config.vim`: `lsp#register_server(...)` in an `User lsp_setup` autocmd, plus any maps
3. `after/ftplugin/<name>.vim`: `setlocal` spacing
4. `:PlugInstall`

You don't need to edit anything under `core/`.
