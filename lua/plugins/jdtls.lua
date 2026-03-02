return {
  "mfussenegger/nvim-jdtls",
  ft = "java",
  config = function()
    local jdtls = require("jdtls")
    local data_dir = vim.fn.stdpath("data") .. "/jdtls-workspace/" ..
      vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "java",
      callback = function()
        jdtls.start_or_attach({
          cmd = { "jdtls", "-data", data_dir },
          root_dir = vim.fs.root(0, { "gradlew", ".git", "mvnw" }),
        })
      end,
    })
  end,
}
