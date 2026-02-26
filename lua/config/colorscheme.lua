vim.opt.background = "light"
vim.cmd("colorscheme default")

local function apply_highlights()
  vim.api.nvim_set_hl(0, "Normal",       { bg = "#ffffff" })
  vim.api.nvim_set_hl(0, "NormalNC",     { bg = "#ffffff" })
  vim.api.nvim_set_hl(0, "StatusLine",   { bg = "#e0e0e0", fg = "#333333" })
  vim.api.nvim_set_hl(0, "StatusLineNC", { bg = "#e8e8e8", fg = "#888888" })
end

apply_highlights()

vim.api.nvim_create_autocmd("ColorScheme", {
  callback = apply_highlights,
})
