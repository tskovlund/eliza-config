# CLAUDE.md — eliza-config

Follow the code standards in [CONVENTIONS.md](CONVENTIONS.md).

## Overview

Configuration repository for Eliza (ZeroClaw AI assistant) running on the `miles` VPS. Contains skills, workspace files, and personality configuration — all agenix-encrypted. Deployed declaratively via `make deploy-miles` in nix-config.

## Structure

- `secrets/secrets.nix` — agenix recipient definitions (age public key)
- `secrets/skill-<name>.age` — Encrypted skill files
- `secrets/workspace-<NAME>.age` — Encrypted workspace identity files

### Naming conventions

- Skills: `secrets/skill-<kebab-case-name>.age` (e.g., `skill-morning-briefing.age`)
- Workspace: `secrets/workspace-<NAME>.age` (e.g., `workspace-USER.age`)

## Encryption

All skills and workspace files are agenix-encrypted (age). The same portable age key decrypts everything.

### Reading a file

```sh
age -d -i ~/.config/agenix/age-key.txt secrets/skill-delegation.age
```

### Editing a file

```sh
agenix -e secrets/skill-delegation.age   # decrypts, opens $EDITOR, re-encrypts
```

### Adding a new skill

1. Add entry to `secrets/secrets.nix`
2. Write the SKILL.md content and encrypt:
   ```sh
   age -r "$(nix eval --raw -f secrets/secrets.nix --apply 'x: builtins.head x."skill-new-name.age".publicKeys')" \
     -o secrets/skill-new-name.age /path/to/SKILL.md
   ```
   Or: `agenix -e secrets/skill-new-name.age`
3. Declare `age.secrets` in nix-config's `hosts/miles/zeroclaw.nix`
4. Commit, push, deploy with `make deploy-miles`

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
```

## Deployment

Secrets are decrypted by agenix (NixOS module) and placed at `/var/lib/zeroclaw/.zeroclaw/workspace/` on miles. nix-config's `zeroclaw.nix` declares `age.secrets` for each file.

The hot-reload path (`eliza-redeploy`) decrypts `.age` files from the local clone using the age key.

## Self-modification (ZeroClaw)

ZeroClaw can modify its own skills:

1. Decrypt: `age -d -i <key> secrets/skill-foo.age > /tmp/skill-foo.md`
2. Edit the plaintext
3. Re-encrypt: `age -r <pubkey> -o secrets/skill-foo.age /tmp/skill-foo.md`
4. Commit and push
5. Touch redeploy trigger

The age key and binary are deployed to `/var/lib/zeroclaw/` by the `zeroclaw-setup` service.

## Commands

- `nix develop` — enter dev shell (taplo for TOML linting)
- Git hooks validate encrypted file structure on commit and push

## Git workflow

- Direct to main for content tweaks
- Branch + PR for new skills or structural changes
- Conventional commits: `feat(secrets): add morning-briefing skill`

## Style

- Skills should be concise and actionable — Eliza reads these as system prompt fragments
- Write for Telegram output: compact summaries, sparse emoji, phone-friendly formatting
- No filler text — every line should carry information
- Reference specific commands and paths (this runs on miles, not a generic environment)
