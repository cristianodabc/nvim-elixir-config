return {
  -- Plenary (required by many plugins)
  {
    "nvim-lua/plenary.nvim",
  },

  -- which-key for keybinding hints
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      preset = "modern",
      delay = 300,
      -- BufferLine's numeric jumps and move mappings are 13 of the 24 Buffer
      -- entries and bury the rest. They keep working; which-key just hides them.
      filter = function(mapping)
        return not mapping.lhs:match("^%sb[%d<>]$")
      end,
      icons = {
        -- Matched against the lowercased mapping description, in order, before
        -- which-key's built-in rules. Plugin-wide rules are deliberately absent:
        -- they resolve first and would flatten every Gitsigns mapping to one icon.
        rules = {
          { pattern = "hunk", icon = "", color = "orange" },
          { pattern = "blame", icon = "", color = "orange" },
          { pattern = "diff", icon = "", color = "orange" },
          { pattern = "feed", icon = "", color = "orange" },
          { pattern = "backlink", icon = "", color = "blue" },
          { pattern = "note", icon = "", color = "purple" },
          { pattern = "obsidian", icon = "", color = "purple" },
          { pattern = "worktree", icon = "", color = "purple" },
          { pattern = "sort", icon = "", color = "cyan" },
          { pattern = "preview", icon = "", color = "azure" },
          { pattern = "go to", icon = "", color = "blue" },
          { pattern = "references", icon = "", color = "blue" },
          { pattern = "rename", icon = "", color = "yellow" },
          { pattern = "hover", icon = "", color = "blue" },
          { pattern = "dbg", icon = "󰃤", color = "red" },
          { pattern = "indent", icon = "", color = "blue" },
          { pattern = "move line", icon = "", color = "blue" },
          { pattern = "move selection", icon = "", color = "blue" },
          { pattern = "paste", icon = "", color = "yellow" },
          { pattern = "one dark", icon = "", color = "purple" },
        },
      },
      -- Groups without an icon fall back to which-key's built-in rules, which
      -- already cover AI, Buffer, Code, Find, Git, Search, and Diagnostics.
      spec = {
        { "<leader>a", group = "AI" },
        { "<leader>ao", group = "OpenCode" },
        { "<leader>b", group = "Buffer" },
        { "<leader>bs", group = "Sort", icon = { icon = "", color = "cyan" } },
        { "<leader>c", group = "Code" },
        { "<leader>f", group = "Find" },
        { "<leader>g", group = "Git" },
        { "<leader>gb", group = "Blame", icon = { icon = "", color = "orange" } },
        { "<leader>gh", group = "Hunks", icon = { icon = "", color = "orange" } },
        { "<leader>gl", group = "Links", icon = { icon = "", color = "blue" } },
        { "<leader>gw", group = "Worktrees", icon = { icon = "", color = "purple" } },
        { "<leader>n", group = "News", icon = { icon = "", color = "orange" } },
        { "<leader>o", group = "Notes", icon = { icon = "", color = "purple" } },
        { "<leader>s", group = "Search/Replace" },
        { "<leader>t", group = "Tests", icon = { icon = "", color = "green" } },
        { "<leader>u", group = "Utilities", icon = { icon = "", color = "grey" } },
        { "<leader>x", group = "Diagnostics" },
        { "gp", group = "Preview", icon = { icon = "", color = "azure" } },
      },
    },
    config = function(_, opts)
      require("which-key").setup(opts)
    end,
  },
}
