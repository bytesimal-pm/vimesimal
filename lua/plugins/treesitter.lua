-- Rich highlighting: nvim-treesitter provides parsers + highlight queries for
-- languages Neovim doesn't bundle (it only ships c, lua, markdown, vim, query),
-- and maps filetypes like qml -> qmljs, ld -> linkerscript, jsonc -> json.
-- Parsers are built locally with tree-sitter-cli + gcc.
-- Languages add parsers from lua/lang/<name>.lua:
--   opts = function(_, o) vim.list_extend(o.parsers, { "python" }) end
-- (a function, because lazy.nvim replaces plain lists instead of merging).
-- Highlighting itself is started for every filetype in lua/config/autocmds.lua.

return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  lazy = false,
  build = ":TSUpdate",
  opts = { parsers = {} },
  config = function(_, opts)
    local function install()
      return require("nvim-treesitter").install(opts.parsers)
    end

    -- Blocking install, used by install.sh: nvim --headless +VimesimalTSInstall +qa
    vim.api.nvim_create_user_command("VimesimalTSInstall", function()
      install():wait(300000)
    end, { desc = "Build all configured tree-sitter parsers" })

    -- In a normal session, quietly build anything missing in the background
    vim.api.nvim_create_autocmd("VimEnter", {
      once = true,
      callback = function()
        if #vim.api.nvim_list_uis() > 0 and vim.fn.executable("tree-sitter") == 1 then
          install()
        end
      end,
    })
  end,
}
