# AGENTS.md — eliza-config

Follow the code standards in [CONVENTIONS.md](CONVENTIONS.md).

## Overview

Configuration repository for Eliza (ZeroClaw AI assistant) running on the `miles` VPS. Contains skills (plaintext) and workspace files (agenix-encrypted). Deployed declaratively via `make deploy-miles` in nix-config.

## Structure

- `skills/<name>/SKILL.md` — Plaintext skill files (no sensitive data)
- `secrets/secrets.nix` — agenix recipient definitions (age public key)
- `secrets/workspace-<NAME>.age` — Encrypted workspace identity files (personal data)

### Naming conventions

- Skills: `skills/<kebab-case-name>/SKILL.md` (e.g., `skills/morning-briefing/SKILL.md`)
- Workspace: `secrets/workspace-<NAME>.age` (e.g., `workspace-USER.age`)

## Encryption

Workspace files contain personal data and are agenix-encrypted. Skills are plaintext — they contain only generic instructions without sensitive information.

### Reading a workspace file

```sh
age -d -i ~/.config/agenix/age-key.txt secrets/workspace-USER.age
```

### Editing a workspace file

```sh
agenix -e secrets/workspace-USER.age   # decrypts, opens $EDITOR, re-encrypts
```

### Adding a new skill

1. Create `skills/<name>/SKILL.md`
2. Commit, push, deploy with `make deploy-miles`

That's it — no encryption step needed for skills.

## Skill format

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

## Cross-references

- Claude Code counterpart: `/skill-name` (if one exists)
```

## Skill sync protocol

Skills are cross-referenced with Claude Code skills in nix-config-personal. When updating a skill here, check the cross-reference and consider whether the counterpart needs a corresponding update. The platforms are genuinely different (Telegram vs terminal, HTTP API vs MCP tools) so skills diverge in implementation but should stay in sync on domain knowledge (review standards, conventions, frameworks, etc.).

## Deployment

Skills are copied directly from `skills/` to `/var/lib/zeroclaw/.zeroclaw/workspace/skills/` on miles by the `zeroclaw-setup` service. Workspace files are decrypted by agenix.

The hot-reload path (`eliza-redeploy`) copies plaintext skills from the local clone and decrypts workspace `.age` files.

## Self-modification (ZeroClaw)

ZeroClaw can modify its own skills:

1. Edit `skills/<name>/SKILL.md` in the persistent clone
2. Commit and push
3. Touch redeploy trigger

The age key is still deployed for workspace file self-modification if needed.

## Commands

- `nix develop` — enter dev shell (taplo for TOML linting)
- Git hooks validate file structure on commit and push

## Style

- Skills should be concise and actionable — Eliza reads these as system prompt fragments
- Write for Telegram output: compact summaries, sparse emoji, phone-friendly formatting
- No filler text — every line should carry information
- Reference specific commands and paths (this runs on miles, not a generic environment)
