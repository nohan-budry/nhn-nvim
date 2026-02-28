-- mason-lspconfig v2 automatically calls vim.lsp.enable() for all
-- installed servers (automatic_enable = true is the default).
return {
  {
    "mason-org/mason-lspconfig.nvim",
    opts = {
      ensure_installed = {
        "lua_ls",        -- Lua
        "ts_ls",         -- JavaScript / TypeScript / TSX
        "clangd",        -- C / C++
        "rust_analyzer", -- Rust
        "html",          -- HTML
        "cssls",         -- CSS
        "jsonls",        -- JSON
        "bashls",        -- Bash
        -- Note: Java (jdtls) requires extra per-project setup; add manually if needed.
      },
    },
    dependencies = {
      { "mason-org/mason.nvim", opts = {} },
      "neovim/nvim-lspconfig",
    },
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = { "nvim-telescope/telescope.nvim" },
    config = function()
      -- Teach lua_ls about Neovim's runtime so the "vim" global is recognized.
      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            runtime = { version = "LuaJIT" },
            workspace = {
              checkThirdParty = false,
              library = { vim.env.VIMRUNTIME },
            },
          },
        },
      })

      -- Keymaps and native completion are only set when an LSP actually attaches.
      -- Files with no configured server are unaffected.
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          -- Built-in LSP completion; trigger with <C-Space> or <C-x><C-o>.
          vim.lsp.completion.enable(true, args.data.client_id, args.buf, { autotrigger = false })

          local opts = { buffer = args.buf }
          -- Navigation (g-prefix: idiomatic Vim)
          vim.keymap.set("n", "K",  vim.lsp.buf.hover,           opts)
          vim.keymap.set("n", "gD", vim.lsp.buf.definition,      opts)
          vim.keymap.set("n", "gd", vim.lsp.buf.declaration,     opts)
          vim.keymap.set("n", "gi", function()
            local client = vim.lsp.get_clients({ bufnr = 0 })[1]
            local params = vim.lsp.util.make_position_params(0, client and client.offset_encoding)
            vim.lsp.buf_request(0, "textDocument/implementation", params, function(err, result, ctx)
              if err or not result or vim.tbl_isempty(result) then
                require("telescope.builtin").lsp_definitions({ initial_mode = "normal" })
                return
              end
              local items = vim.lsp.util.locations_to_items(result, client.offset_encoding)
              local pickers = require("telescope.pickers")
              local finders = require("telescope.finders")
              local conf = require("telescope.config").values
              local make_entry = require("telescope.make_entry")
              pickers.new({ initial_mode = "normal" }, {
                prompt_title = "Implementations",
                finder = finders.new_table({ results = items, entry_maker = make_entry.gen_from_quickfix() }),
                sorter = conf.generic_sorter({}),
                previewer = conf.qflist_previewer({}),
              }):find()
            end)
          end, opts)
          vim.keymap.set("n", "go", function() require("telescope.builtin").lsp_type_definitions({ initial_mode = "normal" }) end, opts)
          vim.keymap.set("n", "gr", function() require("telescope.builtin").lsp_references({ initial_mode = "normal" }) end, opts)
          vim.keymap.set("n", "gs", vim.lsp.buf.signature_help,  opts)
          -- Actions (<leader>l prefix: mnemonic for "Language")
          vim.keymap.set("n",           "<leader>lr", vim.lsp.buf.rename,       opts)
          vim.keymap.set("n",           "<leader>la", vim.lsp.buf.code_action,  opts)
          vim.keymap.set({ "n", "x" },  "<leader>lf", function()
            vim.lsp.buf.format({ async = true })
          end, opts)
        end,
      })
    end,
  },
}
