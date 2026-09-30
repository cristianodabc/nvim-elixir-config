-- One width for every assistant chat panel, as a ratio of the editor that each
-- plugin reapplies on open.
local CHAT_WIDTH_RATIO = 0.30

return {
  {
    "ishiooon/codex.nvim",
    cmd = {
      "Codex",
      "CodexFocus",
      "CodexMaximizeToggle",
      "CodexSend",
      "CodexTreeAdd",
    },
    opts = {
      -- Its defaults claim <leader>cc/cf/cm/cs, which collide with the Code
      -- group: cf is the LSP format map and cs is Trouble document symbols.
      -- Codex is bound explicitly below.
      keymaps = false,
      env = {
        ENABLE_IDE_INTEGRATION = "true",
      },
      status_indicator = {
        enabled = false,
      },
      terminal = {
        provider = "snacks",
        split_side = "right",
        split_width_percentage = CHAT_WIDTH_RATIO,
      },
      diff_opts = {
        layout = "horizontal",
      },
    },
    config = function(_, opts)
      require("codex").setup(opts)
    end,
    keys = {
      {
        "<leader>ax",
        function()
          require("codex").toggle()
        end,
        desc = "Codex",
      },
      {
        "<F9>",
        function()
          require("codex").toggle()
        end,
        desc = "Codex",
        mode = { "n", "t" },
      },
    },
  },

  {
    "coder/claudecode.nvim",
    dependencies = { "folke/snacks.nvim" },
    cmd = {
      "ClaudeCode",
      "ClaudeCodeAdd",
      "ClaudeCodeCloseAllDiffs",
      "ClaudeCodeDiffAccept",
      "ClaudeCodeDiffDeny",
      "ClaudeCodeFocus",
      "ClaudeCodeSelectModel",
      "ClaudeCodeSend",
      "ClaudeCodeStatus",
      "ClaudeCodeTreeAdd",
    },
    opts = {
      terminal_cmd = vim.fn.exepath("claude") ~= "" and vim.fn.exepath("claude") or "claude",
      terminal = {
        provider = "snacks",
        split_side = "right",
        split_width_percentage = CHAT_WIDTH_RATIO,
      },
      diff_opts = {
        layout = "horizontal",
      },
    },
    config = function(_, opts)
      require("claudecode").setup(opts)

      -- The plugin ships the accept/deny commands but binds no keys. Register
      -- them buffer-local on the proposed pane so they only exist while a diff
      -- is live and die with the buffer.
      local function map(buffer, lhs, rhs, desc)
        vim.keymap.set("n", lhs, rhs, { buffer = buffer, desc = desc })
      end

      vim.api.nvim_create_autocmd("User", {
        group = vim.api.nvim_create_augroup("claudecode-diff-keymaps", { clear = true }),
        pattern = "ClaudeCodeDiffOpened",
        callback = function(event)
          local window = event.data and event.data.diff_window

          if not window or not vim.api.nvim_win_is_valid(window) then
            return
          end

          local buffer = vim.api.nvim_win_get_buf(window)

          map(buffer, "<leader>da", "<cmd>ClaudeCodeDiffAccept<cr>", "Accept diff")
          map(buffer, "<leader>dr", "<cmd>ClaudeCodeDiffDeny<cr>", "Reject diff")
          map(buffer, "<leader>dq", "<cmd>ClaudeCodeCloseAllDiffs<cr>", "Close pending diffs")
        end,
      })
    end,
    keys = {
      {
        "<leader>ac",
        "<cmd>ClaudeCode<cr>",
        desc = "Claude Code",
      },
    },
  },

  {
    "sudo-tee/opencode.nvim",
    dependencies = {
      "folke/snacks.nvim",
      {
        "MeanderingProgrammer/render-markdown.nvim",
        ft = "opencode_output",
        opts = {
          anti_conceal = { enabled = false },
          file_types = { "opencode_output" },
        },
      },
    },
    opts = {
      -- Default prefix is <leader>o, which collides with the Notes group
      -- (obsidian), so scope every opencode keymap under <leader>ao instead.
      keymap_prefix = "<leader>ao",
      preferred_picker = "telescope",
      keymap = {
        editor = {
          ["<leader>aom"] = { "configure_provider", desc = "Select OpenCode model" },
        },
      },
      ui = {
        position = "right",
        window_width = CHAT_WIDTH_RATIO,
      },
    },
    config = function(_, opts)
      require("opencode").setup(opts)
    end,
  },
}
