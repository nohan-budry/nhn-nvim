# Copilot Instructions — Neovim Configuration

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
