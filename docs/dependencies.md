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
- π: run `npm install -g --ignore-scripts @earendil-works/pi-coding-agent`. Needs Node 22.19 or newer.

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

pi ships no permission system. It dispatches `edit` and `write` the moment it decides to, so by default the agent writes straight to disk and `pi.nvim` never gets a chance to show a diff. Diff review only happens when an extension intercepts those tool calls and routes them through `ctx.ui.select`.

[`alex35mil/agentic-af`](https://github.com/alex35mil/agentic-af) is the reference implementation, installed with `pi install git:github.com/alex35mil/agentic-af`. Its `permission` extension imports shared helpers from the package, so it cannot be installed on its own; the package also carries five other extensions, skills, prompts, themes, and a workflow system. Review that source before installing it, since a permission extension sees every tool call the agent makes.

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
```

Plugins not represented above are implemented in Lua and need no separate system installation.
