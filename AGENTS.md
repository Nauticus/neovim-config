# Neovim Configuration — AGENTS.md

> **Read this before making any changes to the Neovim configuration.**

## Critical Rule: Check Runtime Documentation First

When working with **any** plugin or Neovim API, **always consult the local runtime documentation** before relying on your training data. Plugin APIs change frequently, and documentation in your training data may be outdated or incorrect.

### Where to Find Documentation

#### Neovim Core APIs
Neovim's built-in help files are located at:
```
/usr/share/nvim/runtime/doc/
```
Key files:
- `api.txt` — Lua API (`vim.api.nvim_*`)
- `lsp.txt` — LSP client API
- `autocmd.txt` — Autocommands
- `options.txt` — Vim options (`vim.opt.*`)
- `lua.txt` — Lua integration
- `vimscript.lua.txt` — Lua-specific vim functions
- `eval.txt` — Expression functions

View with: `nvim -h :help` or `:help <topic>` inside Neovim.

#### Plugin Documentation
Plugins are managed by **lazy.nvim** and installed to:
```
~/.local/share/nvim/lazy/<plugin-name>/
```

Each plugin typically has its own docs:
```
~/.local/share/nvim/lazy/<plugin-name>/doc/
~/.local/share/nvim/lazy/<plugin-name>/README.md
```

#### Installed Plugins
Plugins are managed by **lazy.nvim** and installed under `~/.local/share/nvim/lazy/`.

To discover what's installed: `ls ~/.local/share/nvim/lazy/`

### Workflow Checklist

Before modifying any plugin configuration:

1. **Read the plugin's README or doc files** at `~/.local/share/nvim/lazy/<plugin>/`
2. **Check `lua/plugins/<plugin>.lua`** to understand current configuration
3. **Verify the API hasn't changed** — compare what you know with the actual docs
4. **Check Neovim's built-in docs** for core APIs at `/usr/share/nvim/runtime/doc/`
5. **Only after confirming**, make changes

### Configuration Structure

```
~/.config/nvim/
├── init.lua              # Entry point
├── lua/
│   ├── config/
│   │   └── lazy.lua      # lazy.nvim bootstrap & global settings
│   └── plugins/          # Plugin specs & configurations
│       ├── init.lua
│       ├── completion.lua
│       ├── conform.lua
│       ├── gitsigns.lua
│       ├── treesitter.lua
│       ├── telescope.lua
│       └── ...           # One file per plugin or related group
├── lsp/                  # LSP server configurations
├── snippets/             # VSCode-compatible snippets
├── after/                # After-directory overrides
└── stylua.toml           # Lua formatter config
```

### Formatting

- **Lua code** is formatted with **StyLua** (config: `stylua.toml`)
- Run `stylua .` to format all Lua files

### Neovim Version

Current version: **NVIM v0.12.4** (LuaJIT 2.1.178505726)

### Quick Reference Commands

```bash
# Find a plugin's docs
ls ~/.local/share/nvim/lazy/<plugin>/doc/
cat ~/.local/share/nvim/lazy/<plugin>/README.md

# Search Neovim docs
grep -r "nvim_create_autocmd" /usr/share/nvim/runtime/doc/

# List installed plugins with lazy
nvim -c "Lazy" -c "q"

# Check plugin version
nvim -c "Lazy version" -c "q"
```

## Reminder

> Your training data has a cutoff date. Plugin APIs may have changed significantly since then. **Always verify with the local documentation before making changes.** This is the single most important rule for working with this Neovim configuration.
