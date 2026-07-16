-- Auto-reload buffers when the underlying file changes on disk
vim.opt.autoread = true
vim.opt.updatetime = 250 -- ms of idle before CursorHold fires (default 4000); makes the reload check snappier
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
  pattern = "*",
  command = "checktime",
})
