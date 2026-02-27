return {
  "nvim-telescope/telescope.nvim",
  version = "*",
  dependencies = {
    "nvim-lua/plenary.nvim",
    {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = vim.fn.has("win32") == 1
        and "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release --target install"
        or "make",
    },
  },
  config = function()
    require("telescope").setup({
      defaults = {},
      pickers = {},
      extensions = {
        fzf = {},
      },
    })

    require("telescope").load_extension("fzf")

    local builtin = require("telescope.builtin")
    vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Telescope find files" })
    vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Telescope live grep" })
    vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Telescope buffers" })
    vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Telescope help tags" })
    vim.keymap.set("n", "<leader>fr", builtin.oldfiles, { desc = "Telescope recent files" })
    vim.keymap.set("n", "<leader>fs", builtin.grep_string, { desc = "Telescope grep string" })
  end,
}
