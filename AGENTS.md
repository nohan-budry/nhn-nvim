# Agent Instructions — Neovim Configuration

## Architecture

This is a Neovim configuration using [lazy.nvim](https://lazy.folke.io/) as the plugin manager.

- `init.lua` — Entry point; loads `lua/config/`
- `lua/config/init.lua` — Bootstraps the config modules (options, keymaps, autocmds, lazy)
- `lua/config/lazy.lua` — Bootstraps and configures lazy.nvim; imports all plugin specs from `lua/plugins/`
- `lua/plugins/` — Each file returns a table (or list of tables) of [lazy.nvim plugin specs](https://lazy.folke.io/spec)

## Conventions

- **One plugin spec per file** in `lua/plugins/`. Name the file after the plugin (e.g., `telescope.lua`, `treesitter.lua`).
- Plugin specs use lazy.nvim's declarative format: `opts` for config tables, `config` only when a function is needed.
- Leader key is `<Space>`, local leader is `\`.
- All configuration is in Lua — no VimScript.

## Adding a Plugin

Create a new file in `lua/plugins/` returning a lazy.nvim spec table:

```lua
-- lua/plugins/example.lua
return {
  "author/plugin-name",
  opts = {},
}
```

## Validation

Open Neovim and run `:checkhealth lazy` to verify the config loads without errors.

---

## Plugins

### telescope.nvim

**File:** `lua/plugins/telescope.lua`
**Repo:** [nvim-telescope/telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)

Fuzzy finder over files, buffers, grep results, help tags, and more.

**Dependencies:**
- `nvim-lua/plenary.nvim` — required
- `nvim-telescope/telescope-fzf-native.nvim` — native FZF sorter (built with `make`); requires `make` and a C compiler
- `ripgrep` (system) — required for `live_grep` and `grep_string`

**Keymaps:**

| Key | Action |
|---|---|
| `<Space>ff` | Find files |
| `<Space>fg` | Live grep |
| `<Space>fb` | Buffers |
| `<Space>fh` | Help tags |
| `<Space>fr` | Recent files |
| `<Space>fs` | Grep string under cursor |

**Notes:**
- Uses a `config` function (not `opts`) because keymaps and `load_extension` must be called after setup.
- Run `:checkhealth telescope` to verify the install.

---

### nvim-treesitter (main branch)

**File:** `lua/plugins/treesitter.lua`
**Repo:** [nvim-treesitter/nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter/tree/main)

Syntax highlighting and folding via tree-sitter parsers.

> ⚠️ Uses the `main` branch — a full incompatible rewrite. Do **not** use the old `ensure_installed` / `highlight.enable` API.

**Requirements:** `tar`, `curl`, `tree-sitter-cli` (≥0.26.1), and a C compiler in `$PATH`.

**Installed parsers:** `c`, `cpp`, `rust`, `java`, `html`, `css`, `javascript`, `typescript`, `tsx`, `json`, `jsdoc`, `lua`, `vim`, `vimdoc`, `query`, `bash`, `regex`, `markdown`, `markdown_inline`, `comment`

**Features enabled:**
- **Highlighting** — via `vim.treesitter.start()` in a `FileType` autocmd
- **Folding** — `foldmethod=expr` + `vim.treesitter.foldexpr()`; folds start open (`foldenable=false`)

**Notes:**
- `lazy = false` is required — the plugin does not support lazy-loading.
- Run `:TSUpdate` after upgrading the plugin to keep parsers in sync.
- Run `:checkhealth nvim-treesitter` to verify the install.
