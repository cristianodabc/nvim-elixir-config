return {
  -- Git signs in gutter
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("gitsigns").setup({
        signs = {
          add = { text = "│" },
          change = { text = "│" },
          delete = { text = "_" },
          topdelete = { text = "‾" },
          changedelete = { text = "~" },
        },
      })
    end,
    keys = {
      {
        "<leader>ghs",
        "<cmd>Gitsigns stage_hunk<cr>",
        mode = { "n", "v" },
        desc = "Stage hunk (toggles)",
      },
      { "<leader>ghr", "<cmd>Gitsigns reset_hunk<cr>", mode = { "n", "v" }, desc = "Reset hunk" },
      { "<leader>ghS", "<cmd>Gitsigns stage_buffer<cr>", desc = "Stage buffer" },
      { "<leader>ghR", "<cmd>Gitsigns reset_buffer<cr>", desc = "Reset buffer" },
      { "<leader>ghp", "<cmd>Gitsigns preview_hunk<cr>", desc = "Preview hunk" },
      { "<leader>ghi", "<cmd>Gitsigns preview_hunk_inline<cr>", desc = "Preview hunk inline" },
      { "<leader>ghb", "<cmd>Gitsigns blame_line<cr>", desc = "Blame line" },
      { "<leader>ghd", "<cmd>Gitsigns diffthis<cr>", desc = "Diff against index" },
      {
        "<leader>ghD",
        function()
          require("gitsigns").diffthis("~")
        end,
        desc = "Diff against last commit",
      },
      { "<leader>ghw", "<cmd>Gitsigns toggle_word_diff<cr>", desc = "Toggle word diff" },
      { "<leader>ghq", "<cmd>Gitsigns setqflist<cr>", desc = "Buffer hunks to quickfix" },
      { "<leader>ghQ", "<cmd>Gitsigns setqflist all<cr>", desc = "All hunks to quickfix" },
      { "<leader>ghl", "<cmd>Gitsigns setloclist<cr>", desc = "Buffer hunks to location list" },
      { "<leader>gbb", "<cmd>Gitsigns blame<cr>", desc = "Blame file" },
      {
        "<leader>gbl",
        "<cmd>Gitsigns toggle_current_line_blame<cr>",
        desc = "Toggle inline blame",
      },
      {
        "]h",
        function()
          require("gitsigns").nav_hunk("next")
        end,
        desc = "Next hunk",
      },
      {
        "[h",
        function()
          require("gitsigns").nav_hunk("prev")
        end,
        desc = "Previous hunk",
      },
      {
        "]H",
        function()
          require("gitsigns").nav_hunk("last")
        end,
        desc = "Last hunk",
      },
      {
        "[H",
        function()
          require("gitsigns").nav_hunk("first")
        end,
        desc = "First hunk",
      },
      { "ih", "<cmd>Gitsigns select_hunk<cr>", mode = { "o", "x" }, desc = "Select hunk" },
    },
  },

  -- Open or copy a permalink for the current file or selection
  {
    "folke/snacks.nvim",
    keys = {
      {
        "<leader>gg",
        function()
          Snacks.lazygit()
        end,
        desc = "LazyGit",
      },
      {
        "<leader>gG",
        function()
          Snacks.lazygit({ cwd = vim.fn.expand("%:p:h") })
        end,
        desc = "LazyGit for current file's repo",
      },
      {
        "<leader>gL",
        function()
          Snacks.lazygit.log_file()
        end,
        desc = "LazyGit log for current file",
      },
      {
        "<leader>gi",
        function()
          Snacks.picker.gh_issue()
        end,
        desc = "GitHub Issues (open)",
      },
      {
        "<leader>gI",
        function()
          Snacks.picker.gh_issue({ state = "all" })
        end,
        desc = "GitHub Issues (all)",
      },
      {
        "<leader>gp",
        function()
          Snacks.picker.gh_pr()
        end,
        desc = "GitHub Pull Requests (open)",
      },
      {
        "<leader>gP",
        function()
          Snacks.picker.gh_pr({ state = "all" })
        end,
        desc = "GitHub Pull Requests (all)",
      },
      {
        "<leader>glo",
        function()
          Snacks.gitbrowse({ what = "permalink" })
        end,
        mode = { "n", "v" },
        desc = "Open Git permalink",
      },
      {
        "<leader>gly",
        function()
          Snacks.gitbrowse({
            what = "permalink",
            notify = false,
            open = function(url)
              vim.fn.setreg("+", url)
              vim.notify(url, vim.log.levels.INFO, { title = "Copied Git permalink" })
            end,
          })
        end,
        mode = { "n", "v" },
        desc = "Copy Git permalink",
      },
    },
  },
}
