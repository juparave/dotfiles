-- Safe CopilotChat setup with error handling
local ok, copilot_chat = pcall(require, "CopilotChat")
if not ok then
  vim.notify("CopilotChat not found", vim.log.levels.WARN)
  return
end



copilot_chat.setup({
  debug = false,
  log_level = "info",

  -- Model selection
  model = "gpt-4.1",

  -- Default context settings
  context = "buffers",

  -- Selection function
  selection = function(source)
    local select_ok, select = pcall(require, "CopilotChat.select")
    if select_ok then
      return select.visual(source) or select.buffer(source)
    end
    return nil
  end,

  -- Window settings
  window = {
    layout = "vertical", -- Creates a vertical split (left/right)
    width = 0.4,       -- Takes up 40% of the screen width
    height = 1.0,      -- Full height
    relative = "editor",
    border = "single",
    title = "Copilot Chat",
    zindex = 1,
  },

  -- Chat settings
  show_help = true,
  auto_follow_cursor = true,
  auto_insert_mode = false,
  clear_chat_on_new_prompt = false,

  -- Simple prompts without dependencies
  prompts = {
    Explain = {
      prompt = "Write an explanation for the active selection as paragraphs of text.",
    },
    Review = {
      prompt = "Review the selected code.",
    },
    Fix = {
      prompt = "There is a problem in this code. Rewrite the code to show it with the bug fixed.",
    },
    Optimize = {
      prompt = "Optimize the selected code to improve performance and readability.",
    },
    Docs = {
      prompt = "Please add documentation comment for the selection.",
    },
    Tests = {
      prompt = "Please generate tests for my code.",
    },
    Commit = {
      prompt =
      "Write commit message for the change with commitizen convention. Make sure the title has maximum 50 characters and message is wrapped at 72 characters. Wrap the whole message in code block with language gitcommit.",
      selection = function(source)
        return require("CopilotChat.select").gitdiff(source)
      end,
    },
  },
})

-- Keymaps
local opts = { noremap = true, silent = true }

-- Basic chat commands
vim.keymap.set(
  "n",
  "<leader>cc",
  "<cmd>CopilotChat<cr>",
  vim.tbl_extend("force", opts, { desc = "CopilotChat - Open chat" })
)
vim.keymap.set(
  "x",
  "<leader>cc",
  "<cmd>CopilotChat<cr>",
  vim.tbl_extend("force", opts, { desc = "CopilotChat - Chat with selection" })
)

-- Quick chat
vim.keymap.set("n", "<leader>cq", function()
  local input = vim.fn.input("Quick Chat: ")
  if input ~= "" then
    require("CopilotChat").ask(input, { selection = require("CopilotChat.select").buffer })
  end
end, vim.tbl_extend("force", opts, { desc = "CopilotChat - Quick chat" }))

-- Specific prompts (using safer approach)
vim.keymap.set("n", "<leader>ce", function()
  require("CopilotChat").ask("Explain this code", { selection = require("CopilotChat.select").buffer })
end, vim.tbl_extend("force", opts, { desc = "CopilotChat - Explain code" }))

vim.keymap.set("n", "<leader>ct", function()
  require("CopilotChat").ask("Generate tests for this code", { selection = require("CopilotChat.select").buffer })
end, vim.tbl_extend("force", opts, { desc = "CopilotChat - Generate tests" }))

vim.keymap.set("n", "<leader>cr", function()
  require("CopilotChat").ask("Review this code", { selection = require("CopilotChat.select").buffer })
end, vim.tbl_extend("force", opts, { desc = "CopilotChat - Review code" }))

vim.keymap.set("n", "<leader>cf", function()
  require("CopilotChat").ask("Fix any issues in this code", { selection = require("CopilotChat.select").buffer })
end, vim.tbl_extend("force", opts, { desc = "CopilotChat - Fix code" }))

vim.keymap.set("n", "<leader>co", function()
  require("CopilotChat").ask(
    "Optimize this code for performance and readability",
    { selection = require("CopilotChat.select").buffer }
  )
end, vim.tbl_extend("force", opts, { desc = "CopilotChat - Optimize code" }))

vim.keymap.set("n", "<leader>cd", function()
  require("CopilotChat").ask(
    "Add documentation comments to this code",
    { selection = require("CopilotChat.select").buffer }
  )
end, vim.tbl_extend("force", opts, { desc = "CopilotChat - Add documentation" }))

-- Git integration using built-in CopilotChatCommit
vim.keymap.set("n", "<leader>cm", function()
  vim.cmd("CopilotChatCommit")
end, vim.tbl_extend("force", opts, { desc = "CopilotChat - Generate commit message" }))

-- Alternative: Use predefined Commit prompt
vim.keymap.set("n", "<leader>cM", function()
  local actions = require("CopilotChat.actions")
  actions.pick(actions.prompt_actions({
    selection = require("CopilotChat.select").gitdiff,
  }))
end, vim.tbl_extend("force", opts, { desc = "CopilotChat - Pick commit prompt" }))

-- Visual mode versions of prompts
vim.keymap.set("x", "<leader>ce", function()
  require("CopilotChat").ask("Explain this code", { selection = require("CopilotChat.select").visual })
end, vim.tbl_extend("force", opts, { desc = "CopilotChat - Explain selection" }))

vim.keymap.set("x", "<leader>ct", function()
  require("CopilotChat").ask("Generate tests for this code", { selection = require("CopilotChat.select").visual })
end, vim.tbl_extend("force", opts, { desc = "CopilotChat - Generate tests for selection" }))

vim.keymap.set("x", "<leader>cr", function()
  require("CopilotChat").ask("Review this code", { selection = require("CopilotChat.select").visual })
end, vim.tbl_extend("force", opts, { desc = "CopilotChat - Review selection" }))

vim.keymap.set("x", "<leader>cf", function()
  require("CopilotChat").ask("Fix any issues in this code", { selection = require("CopilotChat.select").visual })
end, vim.tbl_extend("force", opts, { desc = "CopilotChat - Fix selection" }))

-- Advanced features (with error handling)
vim.keymap.set("n", "<leader>cp", function()
  local cmd_ok, _ = pcall(vim.cmd, "CopilotChatPrompts")
  if not cmd_ok then
    vim.notify("CopilotChatPrompts command not available", vim.log.levels.WARN)
  end
end, vim.tbl_extend("force", opts, { desc = "CopilotChat - Select prompts" }))

-- Alternative keymaps for common actions
vim.keymap.set("n", "<leader>ch", function()
  vim.cmd("CopilotChat")
  vim.cmd("help CopilotChat")
end, vim.tbl_extend("force", opts, { desc = "CopilotChat - Show help" }))
