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
          vim.keymap.set("n", "gd", vim.lsp.buf.definition,      opts)
          vim.keymap.set("n", "gD", vim.lsp.buf.declaration,     opts)
          vim.keymap.set("n", "gi", vim.lsp.buf.implementation,  opts)
          vim.keymap.set("n", "go", vim.lsp.buf.type_definition, opts)
          vim.keymap.set("n", "gr", vim.lsp.buf.references,      opts)
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
