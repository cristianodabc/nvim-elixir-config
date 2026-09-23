-- Style loaded at startup. toggle_theme tracks the live style in
-- vim.g.onedark_style, so both must start from the same value.
local default_style = "dark"

local function show_winbar()
  return vim.bo.buftype == "" and vim.api.nvim_buf_get_name(0) ~= ""
end

local function winbar_sections()
  return {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {
      {
        "filename",
        path = 1,
        cond = show_winbar,
        symbols = {
          modified = " ●",
          readonly = " ",
          unnamed = "",
        },
      },
    },
    lualine_x = {},
    lualine_y = {},
    lualine_z = {},
  }
end

local function bufferline_highlights(config)
  config.highlights.indicator_selected.fg = {
    attribute = "fg",
    highlight = "String",
  }

  return config.highlights
end

-- Cycle through One Dark variants
local function toggle_theme()
  local styles = { "dark", "darker", "cool", "deep", "warm", "warmer", "light" }
  local current = vim.g.onedark_style or default_style

  local current_index = 1
  for i, style in ipairs(styles) do
    if style == current then
      current_index = i
      break
    end
  end

  local next_index = (current_index % #styles) + 1
  vim.g.onedark_style = styles[next_index]
  require("onedark").setup({ style = styles[next_index] })
  require("onedark").load()
  vim.notify("Theme: " .. styles[next_index], vim.log.levels.INFO)
end

return {
  -- One Dark theme
  {
    "navarasu/onedark.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.g.onedark_style = default_style

      require("onedark").setup({
        style = default_style,
        code_style = {
          comments = "italic",
        },
      })

      vim.cmd("colorscheme onedark")
    end,
    keys = {
      { "<leader>ut", toggle_theme, desc = "Cycle One Dark styles" },
    },
  },

  {
    -- TEMP: tracking our fork branch until the upstream PR merges the
    -- gh_start_review empty-input fix (folke/snacks.nvim, fix/gh-start-review-empty-input).
    -- Revert to "folke/snacks.nvim" (drop `branch`) once merged.
    "ccarvalho-eng/snacks.nvim",
    branch = "fix/gh-start-review-empty-input",
    lazy = false,
    priority = 1000,
    opts = {
      bigfile = { enabled = true },
      dashboard = { enabled = false },
      gh = { enabled = true },
      gitbrowse = { enabled = true },
      -- Inline images and mermaid diagrams over the Kitty graphics protocol.
      -- Needs `magick` and `mmdc`. Math stays off so it does not require tectonic.
      image = {
        enabled = true,
        math = { enabled = false },
      },
      indent = { enabled = true },
      input = { enabled = true },
      -- Only for the vim.ui.select override, so prompts match snacks.input
      -- instead of falling back to Neovim's numbered cmdline list. Telescope
      -- keeps every <leader>f mapping.
      picker = {
        enabled = true,
        ui_select = true,
        sources = {
          gh_issue = {},
          gh_pr = {},
        },
      },
      statuscolumn = { enabled = true },
      notifier = {
        enabled = true,
        style = "compact",
      },
      quickfile = { enabled = true },
      scope = { enabled = true },
      scroll = { enabled = true },
      words = { enabled = true },
    },
    keys = {
      {
        "<leader>un",
        function()
          Snacks.notifier.show_history()
        end,
        desc = "Notification history",
      },
    },
  },

  -- Lualine status line
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = {
          theme = "auto",
          component_separators = { left = "|", right = "|" },
          section_separators = { left = "", right = "" },
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff", "diagnostics" },
          -- The winbar already shows the filename with its path.
          lualine_c = {},
          lualine_x = { "encoding", "fileformat", "filetype" },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
        winbar = winbar_sections(),
        inactive_winbar = winbar_sections(),
      })
    end,
  },

  -- Bufferline for tabs
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    -- The tabline has to exist from startup, so the keys below must not make
    -- lazy.nvim defer the plugin.
    lazy = false,
    keys = {
      { "<leader>bo", "<cmd>BufferLineCloseOthers<cr>", desc = "Close other buffers" },
      { "<leader>bh", "<cmd>BufferLineCloseLeft<cr>", desc = "Close buffers to the left" },
      { "<leader>bl", "<cmd>BufferLineCloseRight<cr>", desc = "Close buffers to the right" },
      { "<leader>bp", "<cmd>BufferLineTogglePin<cr>", desc = "Toggle pin" },
      { "<leader>bj", "<cmd>BufferLinePick<cr>", desc = "Pick buffer" },
      { "<leader>bx", "<cmd>BufferLinePickClose<cr>", desc = "Pick buffer to close" },
      { "<leader>b<", "<cmd>BufferLineMovePrev<cr>", desc = "Move buffer left" },
      { "<leader>b>", "<cmd>BufferLineMoveNext<cr>", desc = "Move buffer right" },
      { "<leader>bse", "<cmd>BufferLineSortByExtension<cr>", desc = "Sort by extension" },
      { "<leader>bsd", "<cmd>BufferLineSortByDirectory<cr>", desc = "Sort by directory" },
      { "<leader>b1", "<cmd>BufferLineGoToBuffer 1<cr>", desc = "Go to buffer 1" },
      { "<leader>b2", "<cmd>BufferLineGoToBuffer 2<cr>", desc = "Go to buffer 2" },
      { "<leader>b3", "<cmd>BufferLineGoToBuffer 3<cr>", desc = "Go to buffer 3" },
      { "<leader>b4", "<cmd>BufferLineGoToBuffer 4<cr>", desc = "Go to buffer 4" },
      { "<leader>b5", "<cmd>BufferLineGoToBuffer 5<cr>", desc = "Go to buffer 5" },
      { "<leader>b6", "<cmd>BufferLineGoToBuffer 6<cr>", desc = "Go to buffer 6" },
      { "<leader>b7", "<cmd>BufferLineGoToBuffer 7<cr>", desc = "Go to buffer 7" },
      { "<leader>b8", "<cmd>BufferLineGoToBuffer 8<cr>", desc = "Go to buffer 8" },
      { "<leader>b9", "<cmd>BufferLineGoToBuffer 9<cr>", desc = "Go to buffer 9" },
      { "<leader>b0", "<cmd>BufferLineGoToBuffer -1<cr>", desc = "Go to last buffer" },
    },
    config = function()
      local bufferline = require("bufferline")

      bufferline.setup({
        options = {
          mode = "buffers",
          style_preset = bufferline.style_preset.minimal,
          numbers = "none",
          close_command = "bdelete %d",
          right_mouse_command = "bdelete %d",
          left_mouse_command = "buffer %d",
          indicator = {
            icon = "▎",
            style = "icon",
          },
          diagnostics = "nvim_lsp",
          diagnostics_indicator = false,
          offsets = {
            {
              filetype = "NvimTree",
              text = "File Explorer",
              text_align = "center",
              separator = true,
            },
          },
          show_buffer_close_icons = false,
          show_close_icon = false,
          separator_style = "thin",
          always_show_bufferline = false,
        },
        highlights = bufferline_highlights,
      })
    end,
  },

  -- Noice for better UI
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
    },
    config = function()
      require("noice").setup({
        lsp = {
          -- Fidget owns LSP progress; noice enables it by default and would
          -- render a second widget in the same corner.
          progress = { enabled = false },
          override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"] = true,
            ["cmp.entry.get_documentation"] = true,
          },
        },
        presets = {
          bottom_search = true,
          command_palette = true,
          long_message_to_split = true,
          inc_rename = false,
          lsp_doc_border = true,
        },
      })
    end,
  },
}
