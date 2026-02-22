# CLAUDE.md — eliza-config

## Overview

Configuration repository for Eliza (ZeroClaw AI assistant) running on the `miles` VPS. Contains skills, workspace files, and personality configuration. Deployed declaratively via `make deploy-miles` in nix-config.

## Structure

- `workspace/` — Core identity files (SOUL.md, IDENTITY.md, AGENTS.md, TOOLS.md, USER.md)
- `skills/<name>/SKILL.md` — Individual skill instructions

## Skill format

Each skill lives in `skills/<name>/` with at minimum a `SKILL.md` file. Optional `SKILL.toml` for structured metadata.

### SKILL.md structure

```markdown
# Skill Name

One-line description of what this skill does.

## When to use
- Trigger conditions (user says X, scheduled at Y, after Z happens)

## Steps
1. Concrete, actionable instructions
2. With specific commands and expected outputs

## Output format
How to present results (compact for Telegram, emoji for scanning, etc.)

## Notes
- Context-specific details (runs on miles, Telegram delivery, etc.)
```

### Naming conventions
- Directory names: kebab-case (`morning-briefing`, `pr-review`)
- Keep names descriptive and searchable

## Deployment

Files in this repo are deployed read-only to `/var/lib/zeroclaw/.zeroclaw/workspace/` on miles via nix-config's `zeroclaw.nix` module. The rsync runs in the systemd service's `preStart`.

**Deployed files are read-only.** To modify skills or workspace files, edit them in this repo, commit, push, and run `make deploy-miles` from nix-config.

## Commands

- `nix develop` — enter dev shell (taplo for TOML linting)
- Git hooks validate skill structure on commit and push

## Git workflow

- Direct to main for content tweaks
- Branch + PR for new skills or structural changes
- Conventional commits: `feat(skills): add morning-briefing skill`

## Style

- Skills should be concise and actionable — Eliza reads these as system prompt fragments
- Write for Telegram output: compact summaries, sparse emoji, phone-friendly formatting
- No filler text — every line should carry information
- Reference specific commands and paths (this runs on miles, not a generic environment)
