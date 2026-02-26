local languages = {
  -- Systems
  "c", "cpp", "rust",
  -- JVM
  "java",
  -- Web
  "html", "css", "javascript", "typescript", "tsx", "json", "jsdoc",
  -- Lua / Vim (for Neovim config)
  "lua", "vim", "vimdoc", "query",
  -- Shell / config
  "bash", "regex", "markdown", "markdown_inline", "comment",
}

return {
  "nvim-treesitter/nvim-treesitter",
  lazy = false,
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter").setup()

    require("nvim-treesitter").install(languages)

    vim.api.nvim_create_autocmd("FileType", {
      pattern = languages,
      callback = function()
        vim.treesitter.start()
        vim.wo[0][0].foldmethod = "expr"
        vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
        vim.wo[0][0].foldenable = false -- open all folds by default
      end,
    })
  end,
}
