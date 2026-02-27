# Agent Instructions — Neovim Configuration

## Architecture

This is a Neovim configuration using [lazy.nvim](https://lazy.folke.io/) as the plugin manager.

- `init.lua` — Entry point; loads `lua/config/`
- `lua/config/init.lua` — Bootstraps the config modules in order: keymaps → set → lazy → colorscheme
- `lua/config/set.lua` — Editor options (line numbers, tabs, search, undo, etc.)
- `lua/config/keymaps.lua` — Global keymaps and leader key definition
- `lua/config/colorscheme.lua` — Colorscheme and highlight overrides
- `lua/config/lazy.lua` — Bootstraps and configures lazy.nvim; imports all plugin specs from `lua/plugins/`
- `lua/plugins/` — Each file returns a table (or list of tables) of [lazy.nvim plugin specs](https://lazy.folke.io/spec)

## Platform Support

This configuration targets **macOS, Linux, and Windows** (Neovim ≥ 0.11 on all platforms).

### Cross-platform rules

- **Never use `os.getenv("HOME")`** — it is `nil` on Windows. Use `vim.fn.stdpath()` instead:
  - `vim.fn.stdpath("data")` → `~/.local/share/nvim` (Unix) / `%LOCALAPPDATA%\nvim-data` (Windows)
  - `vim.fn.stdpath("config")` → `~/.config/nvim` (Unix) / `%LOCALAPPDATA%\nvim` (Windows)
- **Never hardcode `/` path separators** in Lua path construction. Use `vim.fs.joinpath()` or rely on `stdpath` which already returns the correct separator.
- **Avoid shell-specific syntax** in `vim.fn.system()` calls (e.g., `&&`, `||`, `~`). Use `vim.fn.has("win32")` to branch when a platform difference is unavoidable.

### Windows-specific caveats

| Area | Issue | Recommendation |
|---|---|---|
| `telescope-fzf-native` | Requires `make` + a C compiler (MSVC or MinGW). `make` is not available by default. | Install via [MSYS2](https://www.msys2.org/) or use the pre-built `cmake` build option in the spec. |
| `ripgrep` | Not installed by default. | Install with `winget install BurntSushi.ripgrep.MSVC` or via Scoop/Chocolatey. |
| `nvim-treesitter` | Requires a C compiler in `PATH`. | Install MSVC Build Tools or LLVM (clang). |
| `bashls` | Bash is uncommon on Windows; the server may fail to install or attach. | **Not supported on Windows.** Remove `bashls` from `ensure_installed` when running on Windows, or guard it with `if vim.fn.has("win32") == 0 then`. |
| `tree-sitter-cli` | Must be ≥ 0.26.1 and in `PATH`. | Install via `npm install -g tree-sitter-cli` or a pre-built release. |

## Conventions

- **One plugin spec per file** in `lua/plugins/`. Name the file after the plugin (e.g., `telescope.lua`, `treesitter.lua`).
- Plugin specs use lazy.nvim's declarative format: `opts` for config tables, `config` only when a function is needed.
- Leader key is `<Space>`, local leader is `\`.
- All configuration is in Lua — no VimScript.
- No F-key mappings (Mac-unfriendly). Use `g`-prefix for navigation, `<leader>` for actions.

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

---

### Colorscheme

**File:** `lua/config/colorscheme.lua`

Uses the built-in `default` light theme with custom highlight overrides applied via a `ColorScheme` autocmd (so they survive any colorscheme reload).

| Highlight group | Value |
|---|---|
| `Normal` / `NormalNC` bg | `#ffffff` (full white) |
| `StatusLine` bg / fg | `#e0e0e0` / `#333333` (light gray bar) |
| `StatusLineNC` bg / fg | `#e8e8e8` / `#888888` (inactive windows) |

---

### Global keymaps

**File:** `lua/config/keymaps.lua`

| Key | Action |
|---|---|
| `<Space>pv` | Open netrw file explorer |

---

### LSP

**File:** `lua/plugins/lsp.lua`
**Requires Neovim:** ≥ 0.11 (uses `vim.lsp.config` / `vim.lsp.enable` native API)

**Plugins:**
- `mason-org/mason.nvim` — installs language server binaries locally
- `mason-org/mason-lspconfig.nvim` — ensures servers listed in `ensure_installed` are installed and auto-calls `vim.lsp.enable()` for each
- `neovim/nvim-lspconfig` — provides server config recipes consumed by `vim.lsp.enable()`

**Installed servers:**

| Server | Language(s) |
|---|---|
| `lua_ls` | Lua (Neovim-aware: JuaJIT runtime + `$VIMRUNTIME` workspace) |
| `ts_ls` | JavaScript / TypeScript / TSX |
| `clangd` | C / C++ |
| `rust_analyzer` | Rust |
| `html` | HTML |
| `cssls` | CSS |
| `jsonls` | JSON |
| `bashls` | Bash (**Unix only** — not supported on Windows) |

> Java (`jdtls`) requires extra per-project setup — add manually if needed.

**Completion:** native built-in (`vim.lsp.completion`), triggered manually with `<C-Space>` or `<C-x><C-o>`. No completion plugin.

**Keymaps** (buffer-local, only set when an LSP attaches):

| Key | Action |
|---|---|
| `K` | Hover docs |
| `gd` / `gD` | Definition / Declaration |
| `gi` / `go` / `gr` | Implementation / Type definition / References |
| `gs` | Signature help |
| `<Space>lr` | Rename |
| `<Space>la` | Code action |
| `<Space>lf` | Format (normal + visual) |

**Notes:**
- Keymaps are only registered when an LSP client attaches — files with no server configured are unaffected.
- Run `:checkhealth vim.lsp` to verify servers are attached.
