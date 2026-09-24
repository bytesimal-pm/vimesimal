# vimesimal

Modular Neovim (0.12+) config: one global theme and global plugins, plus separate config and plugins for each language.

```
init.lua                    entry point
lua/config/options.lua      global options (line numbers, search, undo, …)
lua/config/keymaps.lua      global keymaps (leader = Space)
lua/config/autocmds.lua     tree-sitter highlighting, yank flash
lua/config/lsp.lua          diagnostics look + LSP keymaps
lua/config/lazy.lua         lazy.nvim: imports lua/plugins + lua/lang
lua/plugins/*.lua           global plugins
colors/vimesimal.lua        theme (transparent bg, matches kitty)
lua/vimesimal/              shared palette + lualine theme
tmux/tmux.conf              tmux: Ctrl-hjkl pane nav, true color, undercurl
asm-lsp/.asm-lsp.toml       asm-lsp: NASM x86-64 defaults
lua/lang/<name>.lua         language plugins: LSP server, formatter, extras
after/ftplugin/<name>.lua   language spacing / indent style
```

## Install

```sh
sudo pacman -S neovim clang   # clang provides clangd + clang-format
sudo pacman -S nasm rust && cargo install asm-lsp   # NASM + assembly completion
./install.sh                  # links ~/.config/nvim, tmux.conf and asm-lsp config, installs plugins
```

## Features

| | |
|---|---|
| Syntax highlight | built-in tree-sitter + `colors/vimesimal.lua`, LSP semantic tokens |
| Auto suggest | blink.cmp (LSP, paths, snippets, buffer words), signature help |
| Nest | indent-blankline (current scope highlighted) |
| Line | line numbers, cursorline, lualine, gitsigns |
| Navigate | fzf-lua, nvim-tree, LSP go-to, which-key hints, vim-tmux-navigator |

## Keys

| Key | Action |
|---|---|
| `<Space>f` / `g` / `b` / `/` / `r` | files / grep / buffers / lines / recent |
| `<Space>o` / `S` / `d` | document symbols / workspace symbols / diagnostics |
| `<Space>e` | file tree (`l` open, `h` close) |
| `gd` `gD` `gy` `grr` `gri` `K` | definition / declaration / type / references / impl / hover |
| `[d` `]d` `<Space>k` | prev / next / show diagnostic |
| `<Space>rn` `<Space>ca` `<Space>cf` | rename / code action / format |
| `Tab` `S-Tab` `CR` `C-Space` | completion next / prev / accept / show |
| `]h` `[h` `<Space>hp` | next / prev / preview git hunk |
| `gc` `gcc` | comment |
| `C-h/j/k/l` | move between splits and tmux panes |
| `S-h/l` | previous / next buffer |
| `<Space>a` | (C) toggle .c ↔ .h |

## C: kernel style

Hard tabs, 8 wide, no line wrapping, kernel `cinoptions`, `.h` treated as C. `<Space>cf` runs clang-format with a Linux kernel profile, unless the project has its own `.clang-format`.

## NASM: 8 spaces

`.asm`, `.nasm` and `.inc` open as NASM (x86/x86-64). Indent is 8 spaces (no tabs), with no line wrapping. `gcc` comments with `;`. Registers are violet and labels cyan; instructions use the keyword color. Once `asm-lsp` is installed (`~/.cargo/bin` on PATH), it adds instruction/register completion, hover docs (`K`) and nasm diagnostics automatically.

## Adding a language

1. `lua/lang/<name>.lua`: return lazy specs, e.g.
   ```lua
   return {
     { "neovim/nvim-lspconfig", opts = { servers = { pyright = {} } } },
     { "stevearc/conform.nvim", opts = { formatters_by_ft = { python = { "ruff_format" } } } },
   }
   ```
2. `after/ftplugin/<name>.lua`: `vim.bo.shiftwidth = …`
3. Tree-sitter parser: `sudo pacman -S tree-sitter-<name>` (C and Lua come with Neovim)

You don't need to edit anything under `lua/config/` or `lua/plugins/`.

## tmux

`tmux/tmux.conf` is linked to `~/.config/tmux/tmux.conf`. `Ctrl-h/j/k/l` moves between Neovim splits and tmux panes as one grid. Because `Ctrl-l` is taken, clear the shell with `<prefix> Ctrl-l`. Split with `<prefix> |` and `<prefix> -`. The config also turns on true color, wavy underlines and a short Esc delay so Neovim looks and feels the same inside tmux.
