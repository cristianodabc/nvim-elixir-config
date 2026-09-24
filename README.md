# Neovim configuration

An opinionated Neovim setup for Elixir-focused development on macOS. It also includes Lua and Gleam language support, Git and worktree workflows, Obsidian integration, and optional AI assistants.

This is a personal configuration rather than a general-purpose Neovim distribution. Machine-specific integrations are isolated behind environment variables or documented conventions where practical.

## Highlights

- Native Neovim LSP configuration for Dexter, Gleam, and Lua, with floating previews for definitions and references.
- Tree-sitter syntax highlighting and indentation.
- Completion, diagnostics, formatting, and test navigation.
- Telescope search, nvim-tree file browsing, and project-wide replacement.
- Gitsigns, LazyGit, permalinks, and tab-local worktree switching.
- Optional Codex, Claude Code, OpenCode, Ollama, and Obsidian integrations.

## Requirements

- macOS with the Xcode command-line tools.
- Neovim 0.12 or newer. The configured nvim-treesitter branch requires Neovim 0.12.
- Git and the required command-line tools listed in [docs/dependencies.md](docs/dependencies.md).
- A Nerd Font configured in the terminal.

AI assistants, language servers other than Lua, and Obsidian are optional. Their plugin specifications can remain installed when the corresponding executable or environment variable is unavailable.

## Installation

1. Install the external tools in [docs/dependencies.md](docs/dependencies.md).
2. Check out this repository at `~/.config/nvim`.
3. Start Neovim. The configuration bootstraps lazy.nvim automatically.
4. Run `:Lazy sync`, restart Neovim, and run `:checkhealth`.

Back up an existing `~/.config/nvim` directory before replacing it.

## Keymaps

The leader key is `Space`; the local leader is `,`. Press `Space` and pause to open which-key and discover the available mappings.

| Prefix | Area |
| --- | --- |
| `<leader>a` | AI assistants |
| `<leader>b` | Buffers |
| `<leader>c` | Code and LSP actions |
| `<leader>f` | File and project discovery |
| `<leader>g` | Git, diffs, links, and worktrees |
| `<leader>n` | News feeds |
| `<leader>o` | Obsidian notes |
| `<leader>s` | Search and replacement |
| `<leader>t` | Tests |
| `<leader>u` | UI and utility toggles |
| `<leader>x` | Diagnostics |

Mappings are defined close to the behavior they invoke and include descriptions consumed by which-key. General mappings live in `lua/config/keymaps.lua`; plugin mappings live with their plugin specifications.

### LSP previews

| Mapping | Action |
| --- | --- |
| `gpd` | Preview definition |
| `gpt` | Preview type definition |
| `gpi` | Preview implementation |
| `gpD` | Preview declaration |
| `gpr` | Preview references |
| `gpc` | Close all preview windows |

## Organization

```text
.
├── init.lua                 ordered startup entry point
├── lua/
│   ├── config/              editor-wide configuration and custom behavior
│   └── plugins/             lazy.nvim specifications grouped by capability
├── docs/                    focused setup guides
└── lazy-lock.json           pinned plugin revisions
```

`init.lua` loads compatibility helpers, options, diagnostics, lazy.nvim, LSP configuration, worktree commands, and general keymaps in that order. Every module under `lua/plugins` is imported automatically by lazy.nvim.

Plugin specifications are grouped by user-facing capability rather than one file per plugin. A plugin such as Snacks may therefore appear in several files; lazy.nvim merges those specifications into one configuration.

## Local conventions

- Telescope discovers projects below `~/Projects` and excludes `~/Projects/.worktrees` from its project history.
- `OBSIDIAN_VAULT` must point to an existing vault before the Obsidian integration is used.
- `<leader>ta` follows the conventional Elixir `lib/` and `test/` layout. When no matching test exists, it creates a basic ExUnit test file.

Keep credentials and machine-specific paths out of the repository. Prefer environment variables for local overrides.

## Maintenance

- Run `:Lazy check` to inspect available plugin updates and `:Lazy sync` after changing plugin specifications or the lockfile.
- Run `:TSUpdate` after updating nvim-treesitter.
- Format Lua with `stylua init.lua lua` and verify it with `stylua --check init.lua lua`.
- Run `:checkhealth` after dependency, plugin, or Neovim upgrades.

## Guides

- [System dependencies](docs/dependencies.md)
- [OpenCode with local Ollama models](docs/opencode-ollama.md)
