-- General keybindings (non-plugin specific)

-- Clear search highlighting
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlighting" })

-- Window navigation
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to bottom window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to top window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- Resize windows with arrows
vim.keymap.set("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase window height" })
vim.keymap.set("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease window height" })
vim.keymap.set("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })
vim.keymap.set("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })

-- Move lines up/down
vim.keymap.set("n", "<A-j>", "<cmd>m .+1<cr>==", { desc = "Move line down" })
vim.keymap.set("n", "<A-k>", "<cmd>m .-2<cr>==", { desc = "Move line up" })
vim.keymap.set("v", "<A-j>", ":m '>+1<cr>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "<A-k>", ":m '<-2<cr>gv=gv", { desc = "Move selection up" })

-- Better indenting
vim.keymap.set("v", "<", "<gv", { desc = "Indent left and reselect" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent right and reselect" })

-- Stay in visual mode when pasting
vim.keymap.set("v", "p", '"_dP', { desc = "Paste without yanking" })

-- Buffer navigation
vim.keymap.set("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
vim.keymap.set("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })

local function listed_buffers()
  return vim.tbl_filter(function(bufnr)
    return vim.bo[bufnr].buflisted
  end, vim.api.nvim_list_bufs())
end

-- Move off the buffer that is about to be deleted so the window survives, and
-- fall back to an empty buffer when it was the last one open.
local function leave_current_buffer()
  if #listed_buffers() > 1 then
    vim.cmd.bprevious()
  else
    vim.cmd.enew()
  end
end

local function is_terminal(bufnr)
  return vim.bo[bufnr].buftype == "terminal"
end

local function delete_current_buffer(force)
  local current = vim.api.nvim_get_current_buf()

  -- :bdelete refuses to close a terminal whose job is still running (E89).
  -- That guard protects a live process, not unsaved work, so force it here.
  -- The modified-file protection below is unaffected.
  force = force or is_terminal(current)

  leave_current_buffer()
  vim.cmd.bdelete({ args = { tostring(current) }, bang = force })
end

vim.keymap.set("n", "<leader>bd", function()
  delete_current_buffer(false)
end, { desc = "Delete buffer" })

vim.keymap.set("n", "<leader>bD", function()
  delete_current_buffer(true)
end, { desc = "Delete buffer (discard changes)" })

vim.keymap.set("n", "<leader>ba", function()
  vim.cmd.enew()

  local scratch = vim.api.nvim_get_current_buf()
  local kept = 0

  for _, bufnr in ipairs(listed_buffers()) do
    -- Deleting a modified buffer errors instead of discarding it, which is the
    -- behaviour we want here: unsaved work stays open. Terminals are forced
    -- for the same reason as above: E89 is about the job, not unsaved data.
    local delete = function()
      vim.cmd.bdelete({ args = { tostring(bufnr) }, bang = is_terminal(bufnr) })
    end

    if bufnr ~= scratch and not pcall(delete) then
      kept = kept + 1
    end
  end

  if kept > 0 then
    vim.notify(kept .. " buffer(s) kept open with unsaved changes", vim.log.levels.WARN)
  end
end, { desc = "Close all buffers" })

vim.keymap.set("n", "<leader>bb", "<C-^>", { desc = "Alternate buffer" })
vim.keymap.set("n", "<leader>bn", "<cmd>enew<cr>", { desc = "New buffer" })

-- Save and quit shortcuts
vim.keymap.set("n", "<leader>w", "<cmd>w<cr>", { desc = "Save file" })
vim.keymap.set("n", "<leader>q", "<cmd>q<cr>", { desc = "Quit" })

-- Git worktree navigation
vim.keymap.set("n", "<leader>gww", function()
  require("config.worktree").switch()
end, { desc = "Switch worktree in tab" })

vim.keymap.set("n", "<leader>gwt", function()
  require("config.worktree").tab()
end, { desc = "Open worktree in new tab" })

-- Copy the current file path to the clipboard
local function copy_path(modifier)
  local path = vim.fn.expand("%" .. modifier)

  if path == "" then
    vim.notify("Buffer has no file path", vim.log.levels.WARN)
    return
  end

  vim.fn.setreg("+", path)
  vim.notify(path, vim.log.levels.INFO)
end

vim.keymap.set("n", "<leader>up", function()
  copy_path(":.")
end, { desc = "Copy relative file path" })

vim.keymap.set("n", "<leader>uP", function()
  copy_path(":p")
end, { desc = "Copy absolute file path" })

vim.keymap.set("n", "<leader>uf", function()
  copy_path(":t")
end, { desc = "Copy file name" })
