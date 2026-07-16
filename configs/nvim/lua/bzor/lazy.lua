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
