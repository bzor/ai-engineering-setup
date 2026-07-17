-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    lazyrepo,
    lazypath,
  })

  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})

    vim.fn.getchar()
    os.exit(1)
  end
end

vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    {
      "metalelf0/black-metal-theme-neovim",
      lazy = false,
      priority = 1000,
      config = function()
        require("black-metal").setup({
          theme = "gorgoroth",
        })

        require("black-metal").load()
      end,
    },

    {
      "folke/snacks.nvim",
      priority = 900,
      lazy = false,
      ---@type snacks.Config
      opts = {
        bigfile = { enabled = true }, -- disable heavy features (treesitter etc.) on huge files
        quickfile = { enabled = true }, -- render the file before plugins finish loading
        notifier = { enabled = true }, -- vim.notify as floating popups with history
        indent = { enabled = true }, -- indent guides + current-scope highlight
        input = { enabled = true }, -- nicer vim.ui.input (rename prompts etc.)
        words = { enabled = true }, -- highlight other references of symbol under cursor (needs LSP)
        dashboard = {
          enabled = true,
          preset = {
            header = [[
 %%%%%%%%%%%%%%%%%%%%%%*%%%%%%%%%%%%%%%%%%+  %%%%%%%%%%%%%%%%%%%%%%%# %%%%%%%%%%%%%%%%%%%%%%%=    
 @@@@*************+%@#***************%@%*.   @@@@@@@@@@@@@@@@@@@@@@@% @@@@@#***********#%@%+      
 @@@@*           +%#-              .*%*.     @@@@@@@@@@@@@@@@@@@@@@@% @@@@@           -#%+        
 @@@@*         +%%=              .*%*.       @@@@@@@@@@@@@@@@@@@@@@@% @@@@@         -#@*          
 @@@@*        -#@@%=           .*%*.         @@@@@@@@@@@@@@@@@@@@@@@% @@@@@         +%@%*.        
 @@@@*          -#%@%+       .*%+.           @@@@@@@@@@@@@@@@@@@@@@@% @@@@@           +%@%*.      
 @@@@*            -*%@%+   .*%+.             @@@@@@@@@@@@@@@@@@@@@@@% @@@@@             +%@%*.    
 @@@@***************+%@@%+-%%*************** @@@@@@@@@@@@@@@@@@@@@@@% @@@@@               +%@%*.  
 %%%%%%%%%%%%%%%%%%%%%%%%%#=+#%%%%%%%%%%%%%% #%%%%%%%%%%%%%%%%%%%%%%# %%%%%                 +#%%+.]],
            keys = {
              { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
              { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
              { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
              { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
              { icon = " ", key = "c", desc = "Config", action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
              { icon = "󰒲 ", key = "L", desc = "Lazy", action = ":Lazy" },
              { icon = " ", key = "q", desc = "Quit", action = ":qa" },
            },
          },
          sections = {
            { section = "header" },
            { section = "keys", gap = 1, padding = 1 },
            { section = "recent_files", icon = " ", title = "Recent Files", indent = 2, padding = 1 },
            { section = "startup" },
          },
        },
      },
      keys = {
        { "<leader>nh", function() Snacks.notifier.show_history() end, desc = "Notification history" },
        { "<leader>nd", function() Snacks.notifier.hide() end, desc = "Dismiss notifications" },
      },
    },

    {
      "nvim-telescope/telescope.nvim",
      version = "*",
      dependencies = {
        "nvim-lua/plenary.nvim",
        {
          "nvim-telescope/telescope-fzf-native.nvim",
          build = "make",
        },
      },
      config = function()
        local telescope = require("telescope")
        local builtin = require("telescope.builtin")

        telescope.setup({})

        pcall(telescope.load_extension, "fzf")

        vim.keymap.set("n", "<leader>pf", builtin.find_files, { desc = "Project files" })
        vim.keymap.set("n", "<leader>ps", builtin.live_grep, { desc = "Project search" })
        vim.keymap.set("n", "<leader>pb", builtin.buffers, { desc = "Project buffers" })
        vim.keymap.set("n", "<leader>ph", builtin.help_tags, { desc = "Help tags" })
      end,
    },

    {
      "mikavilpas/yazi.nvim",
      version = "*",
      event = "VeryLazy",
      dependencies = {
        "nvim-lua/plenary.nvim",
      },
      keys = {
        {
          "<leader>py",
          "<cmd>Yazi<cr>",
          desc = "Open Yazi",
        },
      },
      opts = {
        open_for_directories = false,
      },
    },

    {
      "nvim-treesitter/nvim-treesitter",
      branch = "master",
      build = ":TSUpdate",
      config = function()
        require("nvim-treesitter.configs").setup({
          ensure_installed = { "glsl", "lua", "javascript", "typescript", "tsx" },
          auto_install = true,
          highlight = { enable = true },
          indent = { enable = true },
        })
      end,
    },
  },

  install = {
    colorscheme = { "habamax" },
  },

  checker = {
    enabled = true,
  },
})
