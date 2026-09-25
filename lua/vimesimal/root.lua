-- root_dir for language servers that do nothing without a project folder
-- (lua_ls, taplo). Uses the nearest project marker and falls back to the
-- file's own folder (never $HOME, to avoid indexing it).
--   root_dir = require("vimesimal.root").project_or_dir({ ".git" })
-- follow_symlinks = true resolves ~/.config/hypr/hyprland.lua into the dotfile
-- repo first; leave it off for servers that ignore files outside their root
-- (taplo would then "exclude" ~/.config/starship.toml).

local M = {}

function M.project_or_dir(markers, opts)
  opts = opts or {}
  return function(bufnr, on_dir)
    local name = vim.api.nvim_buf_get_name(bufnr)
    if name == "" then
      return
    end
    if opts.follow_symlinks then
      name = vim.uv.fs_realpath(name) or name
    end
    local root = vim.fs.root(name, markers) or vim.fs.dirname(name)
    if root ~= vim.fs.normalize("~") then
      on_dir(root)
    end
  end
end

return M
