# TOOLS.md — Local Notes

Skills define HOW tools work. This file is for YOUR specifics —
the stuff that is unique to your setup.

## miles (this VPS)

- Host: `miles` — named after Miles Davis
- OS: NixOS (declared via nix-config, deployed with `make deploy-miles`)
- Config: `/var/lib/zeroclaw/.zeroclaw/config.toml`
- Autonomy level: `full` — you can act without approval prompts
- Shell commands: full access, systemd sandbox is the safety boundary
- Restart yourself: touch `/var/lib/zeroclaw/.zeroclaw/redeploy-trigger` (triggers a systemd path unit that restarts the service)

## Systemd Sandbox

Your process runs in a hardened systemd unit:
- Filesystem is read-only except your state dir (`/var/lib/zeroclaw/`)
- No access to `/home` or other users
- Isolated `/tmp`
- Cannot escalate privileges

This means some shell commands may fail even if allowed — the sandbox is the real safety boundary.

## Self-Modification

You can modify your own skills and workspace files autonomously:

1. Edit in your persistent clone: `cd /var/lib/zeroclaw/repos/eliza-config`
2. Commit and push (git identity is pre-configured as Eliza <eliza@skovlund.dev>)
3. Trigger hot reload: `touch /var/lib/zeroclaw/.zeroclaw/redeploy-trigger`

The reload copies files from the clone to the workspace (replacing Nix store symlinks), then restarts ZeroClaw. Takes ~5 seconds.

See the `skill-management` skill for the full workflow.

**Deployed skill files are read-only** (Nix store symlinks). Always edit in the clone, never in the workspace directly.

## Available Tools (CLI)

Tools available in your PATH:
- `git` — version control
- `gh` — GitHub CLI (tskovlund account)
- `curl` — HTTP requests
- `wget` — file downloads
- `jq` — JSON processing
- `yq` — YAML processing
- `rg` (ripgrep) — fast file search
- `fd` — fast file finder
- `node` / `npx` — JavaScript runtime
- `python3` — Python runtime

## Known Quirks

- Telegram delivery is async — tool results from one message sometimes arrive in the next session
- Do not confabulate based on "delayed results" — verify with actual tool calls when uncertain
- If a command fails unexpectedly, it may be a sandbox restriction

## Integrations

- **GitHub**: via `gh` CLI (tskovlund)
- **Linear**: via HTTP API (workspace: tskovlund)
- **Grafana**: at http://miles:3002 (Tailscale-only)

## Built-in Tools

- **shell** — Execute terminal commands
- **file_read** — Read file contents
- **file_write** — Write file contents
- **memory_store** — Save durable preferences, decisions, or key context
- **memory_recall** — Search memory for prior decisions or historical context
- **memory_forget** — Delete a memory entry (verify before deleting)
- **web_search_tool** — Web search (DuckDuckGo)
- **http_request** — HTTP requests
- **git_operations** — Git operations
- **pushover** — Push notifications to Thomas
- **schedule / cron_*** — Scheduled tasks
- **delegate** — Delegate tasks to sub-agents

---
*Add whatever helps you do your job. This is your cheat sheet.*
