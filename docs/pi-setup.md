# π setup

Everything `pi.nvim` needs that does not live in this repository. The plugin spec is version controlled; the CLI, its credentials, its tools, and its permission rules are machine-local, so this guide exists to rebuild them from scratch.

Work through it in order. Every step is idempotent apart from the clone in step 5.

## 1. Install the CLI

```shell
npm install -g --ignore-scripts @earendil-works/pi-coding-agent
pi --version
```

Needs Node 22.19 or newer. `--ignore-scripts` is safe here: pi does not rely on dependency lifecycle scripts for a normal install.

`:PiPasteImage` pastes clipboard images through `img-clip.nvim`, which needs one more binary on macOS:

```shell
brew install pngpaste
```

## 2. Sign in

pi owns its own credentials. `pi.nvim` never sees them.

Sign in with the Claude subscription rather than an API key, so sessions do not bill per request. `/login` is interactive, so run it from a terminal:

```shell
pi
# /login, pick Anthropic, choose the subscription flow
```

The OAuth token lands in `~/.pi/agent/auth.json`, which stays out of version control. Confirm it took:

```shell
pi auth check --provider anthropic   # prints "ready"
```

`warnings.anthropicExtraUsage` stays on by default and warns when a subscription session is about to spend paid extra usage.

> [!NOTE]
> An `ANTHROPIC_API_KEY` in the environment also satisfies `pi auth check`, which makes a subscription look configured when it is not. It bills per token, and pi does not document which credential wins when both are present. Leave it unset unless API billing is what you want.

## 3. Settings

Write `~/.pi/agent/settings.json`:

```json
{
  "defaultProvider": "anthropic",
  "defaultModel": "claude-opus-5-5",
  "enabledModels": [
    "anthropic/claude-opus-*",
    "anthropic/claude-sonnet-*",
    "anthropic/claude-haiku-*"
  ],
  "defaultTools": [
    "+grep",
    "+find",
    "+ls"
  ],
  "packages": [
    "git:github.com/alex35mil/agentic-af"
  ]
}
```

`defaultModel` is an exact ID, so it needs bumping when a newer Opus ships. Globs in `enabledModels` are not ordered by recency, which is why the startup model is pinned rather than left to resolve: without the pin pi started on `claude-opus-4-5`.

`defaultTools` uses `+name` to add to pi's defaults rather than replace them. See the tool table below.

`packages` is written by `pi install` in step 5. It is listed here so a rebuild can skip ahead.

## 4. The todo tool

pi bundles a working todo extension in its own `examples/` directory. Copy it into the agent directory, where extensions load automatically:

```shell
mkdir -p ~/.pi/agent/extensions
cp "$(npm root -g)/@earendil-works/pi-coding-agent/examples/extensions/todo.ts" ~/.pi/agent/extensions/
```

All four of its imports are host-provided packages, so it needs no dependency install of its own.

## 5. The permission extension

> [!IMPORTANT]
> Without this step pi applies edits straight to disk and `pi.nvim` never shows a diff. `<leader>da` and `<leader>dr` have nothing to accept.

pi ships no permission system. It dispatches `edit` and `write` the moment it decides to. Diff review only happens when an extension intercepts those calls and routes them through `ctx.ui.select`.

```shell
pi install git:github.com/alex35mil/agentic-af
```

[`alex35mil/agentic-af`](https://github.com/alex35mil/agentic-af) is the reference implementation, written against `pi.nvim`. Its `permission` extension imports shared helpers from the package, so it cannot be installed alone.

What else that package brings, all enabled on install:

| Extension | What it adds |
| --- | --- |
| `permission` | Tool interception, and so the diff review |
| `fetch` | `fetch` tool, URL to markdown |
| `web_search` | `web_search` tool, Brave-backed, inert without a key |
| `mcp` | MCP server integration |
| `context` | `/context` session introspection |
| `rules` | Rule files injected into the system prompt |

It also carries skills, prompt templates, themes, and a workflow system. Prune what you do not want with `pi config`.

> [!WARNING]
> A permission extension sees every tool call the agent makes. Read that source before installing it. Its MCP dependency tree currently reports several high-severity npm advisories, reachable through `mcp` rather than `permission`.

## 6. Permission rules

Write `~/.pi/agent/permission.settings.json`:

```json
{
  "defaultMode": "ask",
  "allow": [
    "read",
    "grep",
    "find",
    "ls",
    "todo",
    "bash(ls *)",
    "bash(rg *)",
    "bash(fd *)",
    "bash(git status*)",
    "bash(git diff*)",
    "bash(git log*)",
    "bash(git show*)",
    "bash(git branch*)",
    "bash(mix compile*)",
    "bash(mix test*)",
    "bash(mix format*)"
  ],
  "deny": [
    "bash(rm -rf *)",
    "bash(git push*)",
    "bash(git reset --hard*)"
  ],
  "ask": [
    "edit",
    "write"
  ]
}
```

Per-project overrides go in `<repo>/.agents/permission.settings.json`.

Things worth knowing before editing it:

- Keeping `edit` and `write` on `ask` is what produces the diff review. Moving them to `allow` silently turns it off.
- Anything not listed falls to `defaultMode`, which prompts. A bare install therefore prompts on every read, which is why the allowlist exists at all.
- Evaluation order is session override, `deny`, `ask`, `allow`, `defaultMode`. The strictest result across Bash command nodes wins.
- Writable shell redirects escalate an otherwise-allowed `bash` call to a prompt.
- Invalid settings fail closed and block every agent tool. Slash commands still work, so `/permission-settings` can diagnose it.

`/permission-toggle-auto-accept` skips review for one session.

## 7. Tool inventory

What a session has after following this guide.

| Tool | Source | State | Notes |
| --- | --- | --- | --- |
| `read` | built-in | on | |
| `bash` | built-in | on | Parsed with tree-sitter for permission matching |
| `edit` | built-in | on | Routed to diff review |
| `write` | built-in | on | Routed to diff review |
| `grep` | built-in | on via `defaultTools` | Off in a default install |
| `find` | built-in | on via `defaultTools` | Glob based, respects `.gitignore` |
| `ls` | built-in | on via `defaultTools` | |
| `todo` | `examples/`, step 4 | on | Also adds a `/todos` command |
| `fetch` | agentic-af | on | Needs no key |
| `web_search` | agentic-af | needs a key | Set `BRAVE_SEARCH_API_KEY`, or drop it for an MCP search server in `~/.pi/agent/mcp.json` |
| `codemode` | built-in extension | off | Deliberate, see below |
| `tool_search` | built-in extension | off | Deliberate, see below |
| `powershell` | built-in | n/a | Windows only |

`codemode` runs JavaScript that calls the other tools, and only the script's output reaches the model. That blunts per-edit diff review, so it stays off. `tool_search` exists to surface undeclared tools and is only useful alongside it. Enable either by naming it in `defaultTools`.

pi has no subagent primitive, so there is no equivalent of a spawned task runner. That would mean writing an extension.

## 8. Not wired up

- **Web search.** Either a `BRAVE_SEARCH_API_KEY`, or an MCP search server in `~/.pi/agent/mcp.json`. The MCP route avoids another API key.
- **Local models.** pi reaches Ollama through a compatible endpoint in `~/.pi/agent/models.json`, the same models described in [OpenCode with Ollama](opencode-ollama.md). That needs Ollama installed and its models pulled.

## 9. Verify

```shell
pi auth check --provider anthropic
pi --list-models anthropic
pi list                                    # installed packages
```

In Neovim:

```vim
:Lazy load pi.nvim | checkhealth pi
:Pi
```

The health check warns when the installed `pi` is newer than the version `pi.nvim` last validated against. That is expected rather than broken.

To confirm the permission extension is doing its job, ask π to write a file. It should open a diff for review rather than creating it. Running the same prompt through `pi -p` outside Neovim should refuse, because headless mode blocks everything set to `ask`.

## 10. Files this creates

None of these are in this repository.

| Path | Holds |
| --- | --- |
| `~/.pi/agent/settings.json` | Provider, model, tools, packages |
| `~/.pi/agent/permission.settings.json` | Allow, ask, and deny rules |
| `~/.pi/agent/extensions/todo.ts` | The todo tool |
| `~/.pi/agent/auth.json` | Credentials, keep private |
| `~/.pi/agent/git/github.com/alex35mil/agentic-af` | The package clone |
| `~/.pi/agent/models-store.json` | Cached model catalog |
| `~/.pi/agent/sessions/` | Session history, per working directory |
