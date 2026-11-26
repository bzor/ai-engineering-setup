-- Auto-reload buffers when the underlying file changes on disk
vim.opt.autoread = true
vim.opt.updatetime = 250 -- ms of idle before CursorHold fires (default 4000); makes the reload check snappier
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
  pattern = "*",
  command = "checktime",
})

-- Treesitter highlighting comes from Neovim's built-in runtime; nvim-treesitter
-- is deliberately not installed. Its master branch is frozen at Neovim 0.10 and
-- throws on 0.12, where Query:iter_matches no longer honours `all = false` and
-- capture values are always node lists — its `set-lang-from-info-string!`
-- markdown directive then calls :range() on a table, which broke every
-- image.nvim render. The main branch is the supported successor, but neither
-- branch can build a parser without a C compiler, and there is none on the
-- Windows box.
--
-- Neovim ships parsers and queries for c, lua, markdown, markdown_inline,
-- query, vim and vimdoc. Its own ftplugins already call vim.treesitter.start()
-- for markdown, lua, help, query and checkhealth; this covers the rest, and
-- picks up any parser dropped into the runtimepath later.
vim.api.nvim_create_autocmd("FileType", {
  desc = "Start treesitter highlighting whenever a parser is available",
  callback = function(args)
    pcall(vim.treesitter.start, args.buf)
  end,
})
