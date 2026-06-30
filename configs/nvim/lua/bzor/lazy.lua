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
  },

  install = {
    colorscheme = { "habamax" },
  },

  checker = {
    enabled = true,
  },
})
