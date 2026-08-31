-- Center the window after half-page scrolls
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll down half page and center" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll up half page and center" })

-- Center the window after paragraph/block jumps
vim.keymap.set("n", "{", "{zz", { desc = "Jump to previous block and center" })
vim.keymap.set("n", "}", "}zz", { desc = "Jump to next block and center" })

-- Fast vertical movement: 10 lines at a time, centered
vim.keymap.set({ "n", "x" }, "J", "10jzz", { desc = "Move down 10 lines and center" })
vim.keymap.set({ "n", "x" }, "K", "10kzz", { desc = "Move up 10 lines and center" })
