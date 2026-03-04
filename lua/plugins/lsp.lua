-- mason-lspconfig v2 automatically calls vim.lsp.enable() for all
-- installed servers (automatic_enable = true is the default).
-- jdtls is excluded because it's managed by nvim-jdtls (lua/plugins/jdtls.lua)
-- which handles startup with the correct root_dir and workspace config.
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
        "jdtls",         -- Java (started by nvim-jdtls, not auto-enabled)
      },
      automatic_enable = {
        exclude = { "jdtls" },
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
      -- clangd: group all root_markers as equal priority (nested list) so vim.fs.root()
      -- finds the NEAREST ancestor containing any marker, instead of checking each
      -- marker sequentially across all ancestors (which causes ~/.clang-format to win
      -- over compile_commands.json in the project).
      vim.lsp.config("clangd", {
        root_markers = { { ".clangd", ".clang-tidy", ".clang-format", "compile_commands.json", "compile_flags.txt", "configure.ac", ".git" } },
      })

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
          -- BFS type hierarchy in Telescope (<leader>lh)
          vim.keymap.set("n", "<leader>lh", function()
            local client = vim.lsp.get_clients({ bufnr = 0 })[1]
            if not client then return end
            local params = vim.lsp.util.make_position_params(0, client.offset_encoding)
            client.request("textDocument/prepareTypeHierarchy", params, function(err, result)
              if err or not result or #result == 0 then
                vim.notify("No type hierarchy found", vim.log.levels.INFO)
                return
              end
              local locations = {}
              local queue = { { item = result[1], depth = 1 } }
              local function process()
                if #queue == 0 then
                  if #locations == 0 then
                    vim.notify("No subtypes found", vim.log.levels.INFO)
                    return
                  end
                  local pickers = require("telescope.pickers")
                  local finders = require("telescope.finders")
                  local conf = require("telescope.config").values
                  local make_entry = require("telescope.make_entry")
                  local gen = make_entry.gen_from_quickfix()
                  local function entry_maker(loc)
                    local entry = gen({ filename = loc.filename, lnum = loc.lnum, col = loc.col, text = loc.name })
                    local orig = entry.display
                    entry.display = function(e)
                      local str, hl = orig(e)
                      return loc.indent .. (str or ""), hl
                    end
                    return entry
                  end
                  pickers.new({ initial_mode = "normal" }, {
                    prompt_title = "Type Hierarchy (subtypes)",
                    finder = finders.new_table({ results = locations, entry_maker = entry_maker }),
                    sorter = conf.generic_sorter({}),
                    previewer = conf.qflist_previewer({}),
                  }):find()
                  return
                end
                local entry = table.remove(queue, 1)
                local item, depth = entry.item, entry.depth
                local indent = string.rep("  ", depth - 1)
                client.request("typeHierarchy/subtypes", { item = item }, function(err2, children)
                  if not err2 and children then
                    for _, child in ipairs(children) do
                      table.insert(locations, {
                        filename = vim.uri_to_fname(child.uri),
                        lnum = child.range.start.line + 1,
                        col = child.range.start.character + 1,
                        name = child.name,
                        indent = indent,
                      })
                      table.insert(queue, { item = child, depth = depth + 1 })
                    end
                  end
                  process()
                end)
              end
              process()
            end)
          end, opts)

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
