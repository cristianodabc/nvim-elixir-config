# Neovim dependencies

External tools used by this configuration. Lazy.nvim installs the Neovim plugins themselves.

## 1. Prerequisites

Install [Homebrew](https://brew.sh), then install the Xcode command-line tools:

```shell
xcode-select --install
```

This supplies Git, Make, and a C compiler. Lazy.nvim needs Git to download plugins, while Tree-sitter needs the build tools to compile parsers.

## 2. Required tools

```shell
brew install neovim ripgrep fd tree-sitter-cli lazygit stylua lua-language-server
brew install --cask font-fira-code-nerd-font
```

| Tool | Why it is needed | Used by |
| --- | --- | --- |
| `neovim` 0.12 or newer | Runs this configuration | The editor and nvim-treesitter |
| `ripgrep` (`rg`) | Fast project text search | Telescope, Grug Far, Obsidian |
| `fd` | Fast file discovery | Telescope |
| `tree-sitter-cli` | Installs and updates syntax parsers | nvim-treesitter |
| `lazygit` | Interactive Git interface | Snacks |
| `stylua` | Formats Lua files | conform.nvim |
| `lua-language-server` | Lua diagnostics, navigation, and completion | Neovim LSP and nvim-cmp |
| Nerd Font | Supplies the icons used by the interface | Bufferline, Lualine, nvim-tree, devicons |

Tree-sitter also uses the compiler, `curl`, and `tar` supplied by macOS and the command-line tools. Use Tree-sitter CLI 0.26.1 or newer and ripgrep 14 or newer.

## 3. Dexter

Dexter provides Elixir language-server features when `dexter` is available. Install it only if needed:

```shell
brew install asdf
asdf plugin add dexter https://github.com/remoteoss/dexter.git
asdf install dexter 0.7.1
asdf set --home dexter 0.7.1
dexter version
```

Elixir and Erlang installation is intentionally not covered here.

## 4. Local AI

OpenCode and Ollama are required only for the local AI integrations:

```shell
brew install --cask ollama-app
brew install anomalyco/tap/opencode
```

Follow [OpenCode with Ollama](opencode-ollama.md) to install the models, configure their short
aliases, and point OpenCode at them.

Codex, Claude, and π are separate, optional integrations:

- Codex: follow the [Codex CLI installation guide](https://learn.chatgpt.com/docs/codex/cli).
- Claude: run `npm install -g @anthropic-ai/claude-code`.
- π: run `npm install -g --ignore-scripts @earendil-works/pi-coding-agent`. Needs Node 22.19 or newer. `:PiPasteImage` also needs `brew install pngpaste`.

### π on Claude models

`pi.nvim` does not manage credentials or providers; both live in pi itself. Point pi at Anthropic in `~/.pi/agent/settings.json`:

```json
{
  "defaultProvider": "anthropic",
  "defaultModel": "claude-opus-5-5",
  "enabledModels": ["anthropic/claude-opus-*", "anthropic/claude-sonnet-*", "anthropic/claude-haiku-*"]
}
```

`defaultModel` is an exact ID and needs bumping when a newer Opus ships; `enabledModels` bounds what the pickers offer. Authenticate with `ANTHROPIC_API_KEY` in the environment, or run `/login` inside `pi` to attach a subscription. Verify both with:

```shell
pi auth check --provider anthropic
pi --list-models anthropic
```

`:PiSelectModel` in Neovim narrows to the newest Opus, Sonnet, and Haiku; `:PiSelectModelAll` reaches everything pi can see.

### π diff review needs a permission extension

pi ships no permission system. It dispatches `edit` and `write` the moment it decides to, so nothing stands between the agent and your files and `pi.nvim` never gets a chance to show a diff. Diff review only happens when an extension intercepts those tool calls and routes them through `ctx.ui.select`.

[`alex35mil/agentic-af`](https://github.com/alex35mil/agentic-af) is the reference implementation:

```shell
pi install git:github.com/alex35mil/agentic-af
```

Its `permission` extension imports shared helpers from the package, so it cannot be installed alone. The package also carries `context`, `fetch`, `mcp`, `rules`, and `web-search` extensions plus skills, prompt templates, themes, and a workflow system, and its MCP dependency tree currently reports several high-severity npm advisories. A permission extension sees every tool call the agent makes, so read that source before installing it and prune what you do not want with `pi config`.

Rules live in `~/.pi/agent/permission.settings.json`, with per-project overrides in `<repo>/.agents/permission.settings.json`:

```json
{
  "defaultMode": "ask",
  "allow": ["read", "grep", "find", "ls", "bash(git status*)", "bash(mix test*)"],
  "deny": ["bash(rm -rf *)", "bash(git push*)"],
  "ask": ["edit", "write"]
}
```

Keeping `edit` and `write` on `ask` is what produces the diff review, so leave them there. Anything left to `defaultMode` prompts, which makes a bare install prompt on every read. Evaluation runs session override, then `deny`, then `ask`, then `allow`, then `defaultMode`, and writable shell redirects escalate an otherwise-allowed `bash` call to a prompt. Invalid settings fail closed and block every agent tool, so validate a change by reading a file and editing one in a scratch directory.

`/permission-settings` inside π prints the resolved rules, and `/permission-toggle-auto-accept` skips review for a session.

## 5. Optional integrations

Install only what you use.

| Feature | Installation | Why it is needed |
| --- | --- | --- |
| Gleam | `brew install gleam` | Enables the configured Gleam language server |
| Obsidian | Obsidian app, `ripgrep`, and `OBSIDIAN_VAULT` | Opens the vault, searches notes, and launches the desktop app |
| Tests | The current project's test runner | Allows vim-test to execute tests |

Set the Obsidian vault without committing a machine-specific path:

```shell
export OBSIDIAN_VAULT="/path/to/vault"
```

Keep database credentials in environment variables, not in this repository.

## 6. Inline images and Mermaid diagrams

`snacks.image` draws images and `mermaid` code blocks inline in the buffer. It needs a terminal that
speaks the Kitty graphics protocol: Ghostty, Kitty, or WezTerm.

```shell
brew install imagemagick mermaid-cli
```

| Tool | Why it is needed | Used by |
| --- | --- | --- |
| `imagemagick` (`magick`) | Converts SVG, PDF, and raster sources to PNG and reads their dimensions | snacks.image |
| `mermaid-cli` (`mmdc`) | Renders Mermaid diagrams to PNG | snacks.image |
| `tectonic` | Renders LaTeX math expressions. Only needed when `image.math` stays enabled | snacks.image |

`mmdc` drives a headless Chrome through Puppeteer and does not ship one. Install the build it asks
for, then confirm the whole chain works:

```shell
npx --yes puppeteer@latest browsers install chrome-headless-shell
printf 'graph TD\n  A[Start] --> B[End]\n' > /tmp/t.mmd
mmdc -i /tmp/t.mmd -o /tmp/t.png && magick identify /tmp/t.png
```

If `mmdc` reports a version of `chrome-headless-shell` it cannot find, rerun the install command
with that exact version appended, such as `chrome-headless-shell@152.0.7977.75`.

## 7. Install and verify Neovim plugins

Start Neovim and run:

```vim
:Lazy sync
:checkhealth
```

Useful feature checks:

```vim
:ConformInfo
:checkhealth snacks
:Obsidian check
:Lazy load pi.nvim | checkhealth pi
```

π is lazy-loaded, so its health check reports `No healthcheck found` until the plugin is loaded. It warns when the installed `pi` is newer than the version `pi.nvim` last validated against, which is expected rather than broken.

Plugins not represented above are implemented in Lua and need no separate system installation.
