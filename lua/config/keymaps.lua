vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.keymap.set("n", "<leader>pv", vim.cmd.Ex, { desc = "Open netrw explorer" })

vim.keymap.set("i", "<C-Space>", "<C-x><C-o>", { desc = "Trigger LSP completion" })
