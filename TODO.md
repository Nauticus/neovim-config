# Neovim Config — TODO & Review

Generated from config review. Each item has a `Status` and `Decision` field — fill them in.

---

## P0 — Bugs / Breakage

### 1. Duplicate `<leader>sw` mapping in `telescope.lua`

**File:** `lua/plugins/telescope.lua`

Two entries bind `<leader>sw` — one normal mode (`grep_string`), one visual mode (`grep visual selection`). They live in the same `keys` table so the visual mode entry overwrites the normal mode one. The normal-mode `<leader>sw` is dead.

- **Status:** open
- **Decision:**

---

### 2. `stylua.toml` syntax set to `"Lua51"` instead of `"LuaJIT"`

**File:** `stylua.toml`

Neovim uses LuaJIT, not Lua 5.1. While mostly compatible, the correct Stylua setting is `syntax = "LuaJIT"` (or omit for `"All"`).

- **Status:** open
- **Decision:**

---

## P1 — Configuration Issues

### 3. sidekick.nvim pinned to hardcoded commit `6b69c42`

**File:** `lua/plugins/sidekick.lua`

Pinning to a raw commit means lazy.nvim will never update it. Pin to a tag/version or remove the pin.

- **Status:** open
- **Decision:**

---

### 4. `lua_ls` missing `workspace.library` / lazydev→cmp bridge broken

**File:** `lsp/lua_ls.lua`, `lua/plugins/lazydev.lua`

`lazydev.nvim` has `integrations.cmp = false`, so cmp won't get LSP completions from lazydev. And `lua_ls` doesn't set `settings.Lua.workspace.library` to point at Neovim's runtime. Neither LSP can auto-complete Neovim API types into cmp.

- **Status:** open
- **Decision:**

---

### 5. LSP folding set globally instead of scoped to `LspAttach`

**File:** `lua/config/lsp.lua`

`vim.o.foldmethod = "expr"` and `vim.o.foldexpr = "v:lua.vim.lsp.foldexpr()"` are set unconditionally. If LSP isn't attached yet or doesn't support folding, this degrades the fold experience.

- **Status:** open
- **Decision:**

---

## P2 — Missing Features

### 6. No indent guides / blankline plugin

**File:** `lua/plugins/init.lua` (catppuccin integrations)

Catppuccin has `indent_blankline = false` in integrations. No `indent-blankline.nvim` or `mini.indentscope` is installed. The `fillchars.fold = "⋅"` suggests interest in visual polish but indentation is invisible.

- **Status:** open
- **Decision:**

---

### 7. `:` cmdline completion missing `cmdline`/`command` source

**File:** `lua/plugins/completion.lua`

`cmp.setup.cmdline(":", ...)` only has `{ name = "path" }`. No `cmp-cmdline` source, so command name completion in `:` is missing.

- **Status:** open
- **Decision:**

---

## P3 — Design Decisions / Cleanup

### 8. nvim-tree and oil both installed — overlapping roles

**Files:** `lua/plugins/nvim-tree.lua`, `lua/plugins/oil.lua`

Both provide file browsing. nvim-tree is a sidebar file explorer; oil replaces the netrw buffer with a directory editor. They work differently but compete for the "navigate files" workflow. Decide if both are needed or if one should be disabled.

- **Status:** open
- **Decision:**

---

### 9. Catppuccin `notify = true` but no notify plugin installed

**File:** `lua/plugins/init.lua` (catppuccin integrations)

`integrations.notify = true` is set but no `nvim-notify` (or similar) plugin is loaded. Catppuccin will silently skip the integration and vim.notify uses the basic built-in with no UI.

- **Status:** open
- **Decision:**

---

### 10. `.luarc.json.temp` exists — commit or ignore

**File:** `.luarc.json.temp`

A temp file sits in the repo. Either rename to `.luarc.json` and commit, or add `*.json.temp` to `.gitignore`.

- **Status:** open
- **Decision:**

---

## P4 — Nice to Have

### 11. `hlsearch = false` with no toggle

**File:** `lua/config/core/opts.lua`

`vim.opt.hlsearch = false` is set and there's no mapping to toggle it on. Fine with telescope+fzf workflow, but `/` searches leave no visual trail.

- **Status:** open
- **Decision:**

---

### 12. No filetype detection for config files

**File:** `lua/config/core/autocmd.lua`

Custom autocmds cover `.keymap` → `dts` and ansible yaml, but no detection for `stylua.toml` (toml), `.luarc.json` (json), `.editorconfig` (editorconfig), or `*.toml` generally.

- **Status:** open
- **Decision:**

---

### 13. `block_newline_gaps` in stylua.toml — verify version support

**File:** `stylua.toml`

`block_newline_gaps` was added very recently to Stylua. If the installed version is older, Stylua may error on parse.

- **Status:** open
- **Decision:**
