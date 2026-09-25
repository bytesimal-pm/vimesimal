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
sudo pacman -S tree-sitter-cli pyright ruff bash-language-server shellcheck \
  lua-language-server taplo-cli vscode-json-languageserver   # other languages
sudo pacman -S typescript-language-server tailwindcss-language-server prettier   # Next.js
npm install -g --prefix ~/.local vscode-langservers-extracted   # ESLint server (no sudo)
./install.sh                  # links ~/.config/nvim, tmux.conf and asm-lsp config, installs plugins
```

## Features

| | |
|---|---|
| Syntax highlight | tree-sitter (nvim-treesitter builds parsers) + `colors/vimesimal.lua`, LSP semantic tokens |
| Auto suggest | blink.cmp (LSP, paths, snippets, buffer words), signature help |
| Nest | indent-blankline (current scope highlighted) |
| Line | line numbers, cursorline, lualine, gitsigns |
| Navigate | fzf-lua, nvim-tree, flash (jump to word), LSP go-to, which-key hints, vim-tmux-navigator |

## Keys

| Key | Action |
|---|---|
| `<Space>f` / `g` / `b` / `/` / `r` | files / grep / buffers / lines / recent |
| `<Space>o` / `S` / `D` | document symbols / workspace symbols / diagnostics list |
| `<Space>e` | file tree (`l` open, `h` close) |
| `f` + word + `Enter` | jump to any visible word (or press the label shown on a match); `S` selects a code block |
| `gd` `gD` `gy` `grr` `gri` `K` | definition / declaration / type / references / impl / hover |
| `[d` `]d` `<Space>d` | prev / next / show diagnostic under cursor |
| `<Space>rn` `<Space>ca` `<Space>cf` | rename / code action / format |
| `Tab` | step into the suggestion menu (then `j`/`k` move, `y` accept, `n` cancel) |
| `S-Tab` `CR` `C-Space` | completion prev / accept / show |
| `]h` `[h` `<Space>hp` | next / prev / preview git hunk |
| `gc` `gcc` | comment |
| `C-h/j/k/l` | move between splits and tmux panes |
| `S-h/l` | previous / next buffer |
| `<Space>a` | (C) toggle .c ↔ .h |

## C: kernel style

Hard tabs, 8 wide, no line wrapping, kernel `cinoptions`, `.h` treated as C. `<Space>cf` runs clang-format with a Linux kernel profile, unless the project has its own `.clang-format`.

## Languages

| Language | Spacing | Server / lint | Files |
|---|---|---|---|
| C | tabs, 8 | clangd, clang-format (kernel) | `lang/c.lua`, `ftplugin/c.lua` |
| NASM | 8 spaces | asm-lsp | `lang/nasm.lua`, `ftplugin/nasm.lua` |
| QML | 4 spaces | qmlls6 | `lang/qml.lua`, `ftplugin/qml.lua` |
| Python | 4 spaces | pyright + ruff | `lang/python.lua`, `ftplugin/python.lua` |
| Makefile | tabs, 8 | — | `lang/make.lua`, `ftplugin/make.lua` |
| Linker script (`.ld` `.lds`) | tabs, 8 | — | `lang/ld.lua`, `ftplugin/ld.lua` |
| Shell (sh, bash, zsh) | 4 spaces | bash-language-server + shellcheck | `lang/sh.lua`, `ftplugin/sh.lua` |
| Lua | 2 spaces (4 in `hypr/`) | lua-language-server + lazydev | `lang/lua.lua`, `ftplugin/lua.lua` |
| TypeScript / TSX / JS (Next.js) | 2 spaces, tree-sitter indent | ts_ls, tailwindcss, eslint, prettier (`<Space>cf`) | `lang/typescript.lua`, `ftplugin/typescript.lua`, `indent/typescript.lua` |
| JSON, TOML, CSS/QSS, GLSL | 4 spaces | jsonls, taplo | `lang/data.lua` |

Servers turn on by themselves once their binary is installed. Spacing files call `require("vimesimal.spacing").set({ width = 4 })` (add `tabs = true` for hard tabs). For Quickshell types in QML, keep an empty `.qmlls.ini` in the shell folder; Quickshell fills in the import paths.

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
2. `after/ftplugin/<name>.lua`: `require("vimesimal.spacing").set({ width = 4 })`
3. Tree-sitter parser: in the lang file, `{ "nvim-treesitter/nvim-treesitter", opts = function(_, o) vim.list_extend(o.parsers, { "<name>" }) end }`

You don't need to edit anything under `lua/config/` or `lua/plugins/`.

## Claude Code

Claude Code runs in a split on the right (claudecode.nvim, Claude's IDE protocol: it sees your file and selection). In the default `manual` mode every edit Claude wants to make is **proposed in your code window first**: the file shows the new text with changed/added lines green and removed lines as red ghost lines, nothing is written yet, and Claude waits. `y` applies it, `n` rejects it (Claude is told). You can also tweak the proposed text before `y`, or answer in Claude's own prompt. Open files are saved when you switch to Claude so it edits what you see. In `auto`/`acceptEdits` mode (`:ClaudeConfig`), changes are applied first and then shown the same way with `y` keep / `n` undo.

| Key | Action |
|---|---|
| `<Space>ae` | popup: **edit** / quick answer via `claude -p` (Claude gets only Read + Edit). Edits show right in the code like VS Code: changed/added lines green, removed lines as red ghost lines, and a bar at the top: `y` keep, `n` undo (typing in the file also keeps it). Plain questions get an answer popup. In visual mode the selection goes along |
| `<Space>ac` | popup: **chat**, sent to the Claude split (starts it if needed); in visual mode the selection goes along as `@file#L10-24` |
| `<Space>aa` / `<Space>ar` | toggle the Claude split / resume the last conversation |
| `<Space>af` / `<Space>as` | add the current file / send the selection |
| `<Space>am` | pick a model for this session |
| `Ctrl-h` / `Ctrl-l` | leave the Claude terminal like any split (`Esc` stays with Claude) |

`:ClaudeConfig` opens a menu for model, permission mode (`manual` review first, `acceptEdits`, `auto`, `plan`), compile/run checks (off by default: Claude relies on the editor's diagnostics instead of compiling to check its work) and window side/width. Settings are saved to `~/.local/share/nvim/vimesimal-claude.json` and apply to the next session.

## tmux

`tmux/tmux.conf` is linked to `~/.config/tmux/tmux.conf`. `Ctrl-h/j/k/l` moves between Neovim splits and tmux panes as one grid. Because `Ctrl-l` is taken, clear the shell with `<prefix> Ctrl-l`. Split with `<prefix> |` and `<prefix> -`. The config also turns on true color, wavy underlines and a short Esc delay so Neovim looks and feels the same inside tmux.
