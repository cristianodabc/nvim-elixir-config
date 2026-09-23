local function vault_path()
  local env_path = vim.env.OBSIDIAN_VAULT

  if not env_path or env_path == "" then
    return
  end

  local path = vim.fn.expand(env_path:gsub("\\ ", " "):gsub("\\~", "~"))

  if vim.fn.isdirectory(path) == 1 then
    return path
  end
end

local function note_id(title, dir)
  if type(title) ~= "string" then
    return require("obsidian.builtin").zettel_id()
  end

  local id = vim.trim(title):gsub("%.md$", "")

  if id == "" then
    return require("obsidian.builtin").zettel_id()
  end

  if not dir then
    return id
  end

  local base_dir = require("obsidian.path").new(dir)
  local candidate = id
  local index = 2

  while (base_dir / candidate):with_suffix(".md", true):exists() do
    candidate = string.format("%s %d", id, index)
    index = index + 1
  end

  return candidate
end

return {
  {
    "obsidian-nvim/obsidian.nvim",
    version = "*",
    dependencies = {
      "nvim-telescope/telescope.nvim",
    },
    ft = "markdown",
    cmd = "Obsidian",
    keys = {
      { "<leader>ob", "<cmd>Obsidian backlinks<cr>", desc = "Backlinks" },
      { "<leader>od", "<cmd>Obsidian dailies<cr>", desc = "Daily notes" },
      { "<leader>on", "<cmd>Obsidian new<cr>", desc = "New note" },
      { "<leader>oo", "<cmd>Obsidian open<cr>", desc = "Open in Obsidian" },
      { "<leader>oq", "<cmd>Obsidian quick_switch<cr>", desc = "Find note" },
      { "<leader>os", "<cmd>Obsidian search<cr>", desc = "Search notes" },
      { "<leader>ot", "<cmd>Obsidian today<cr>", desc = "Today's note" },
    },
    config = function()
      local path = vault_path()

      if not path then
        vim.notify("OBSIDIAN_VAULT must point to an existing directory", vim.log.levels.WARN)
        return
      end

      require("obsidian").setup({
        legacy_commands = false,
        note_id_func = note_id,
        daily_notes = {
          date_format = "YYYY/MM/YYYY-MM-DD",
          folder = "journal",
          template = "journal",
        },
        picker = {
          name = "telescope.nvim",
        },
        templates = {
          folder = "blueprints",
        },
        workspaces = {
          {
            path = path,
          },
        },
      })
    end,
  },
}
