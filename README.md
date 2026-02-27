# nvim config

A minimalist Neovim configuration — a personal playground for learning and improving my development workflow.

## Structure

```
├── init.lua              # Entry point
└── lua/
    ├── config/
    │   ├── set.lua       # Editor options
    │   ├── keymaps.lua   # Global keymaps
    │   ├── colorscheme.lua
    │   └── lazy.lua      # Plugin manager bootstrap
    └── plugins/          # One file per plugin
```

Plugin management is handled by [lazy.nvim](https://lazy.folke.io/).

## Plugins

### [Telescope](https://github.com/nvim-telescope/telescope.nvim)
Fuzzy finder for files, buffers, grep, and help. Requires `ripgrep` for live grep.

| Key | Action |
|-----|--------|
| `<Space>ff` | Find files |
| `<Space>fg` | Live grep |
| `<Space>fb` | Buffers |
| `<Space>fr` | Recent files |
| `<Space>fh` | Help tags |

### [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) (main branch)
Syntax highlighting and folding. Parsers installed for: Lua, C/C++, Rust, Java, JS/TS, HTML, CSS, JSON, Bash, Markdown, and more.

### LSP
Native LSP via Neovim's built-in API (≥ 0.11). [Mason](https://github.com/mason-org/mason.nvim) manages server installation.

Configured servers: `lua_ls`, `ts_ls`, `clangd`, `rust_analyzer`, `html`, `cssls`, `jsonls`, `bashls`

| Key | Action |
|-----|--------|
| `K` | Hover docs |
| `gd` | Go to definition |
| `gr` | References |
| `<Space>lr` | Rename |
| `<Space>la` | Code action |
| `<Space>lf` | Format |

## Theme

Built-in `default` light theme with some custom highlights (full white background, clean statusline).
