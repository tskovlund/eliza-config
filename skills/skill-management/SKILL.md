# Skill Management

Create, update, and manage your own skill library. Skills live in the `eliza-config` repo and are deployed to your workspace.

## When to use

- When you need to add a new skill
- When an existing skill needs updating
- When Thomas says "add a skill", "update skill", "manage skills"
- When self-improvement identifies a skill gap

## Understanding the architecture

- Skills live in `github.com/tskovlund/eliza-config` under `skills/<name>/SKILL.md`
- Deployed to `/var/lib/zeroclaw/.zeroclaw/workspace/skills/` via nix-config
- **Deployed files are READ-ONLY** (Nix store symlinks) — you cannot edit them in place
- To modify: use the persistent clone, edit, commit, push, then trigger a hot reload

## Self-modification workflow

### 1. Work in the persistent clone

```bash
cd /var/lib/zeroclaw/repos/eliza-config
git pull origin main
```

This clone persists across restarts and is your working directory for all skill changes.

### 2. Create or edit a skill

```bash
# New skill
mkdir -p skills/<skill-name>
# Write SKILL.md (use file_write tool or shell)
```

### 3. Write SKILL.md

Follow this structure:

```markdown
# Skill Name

One-line description.

## When to use
- Trigger conditions

## Steps
1. Concrete instructions

## Output format
How to present results

## Notes
- Context details
```

Key principles:
- Be specific and actionable — this is loaded into your system prompt
- Reference actual commands and paths (you run on miles)
- Keep it concise — every token counts
- Include output format for Telegram readability

### 4. Commit and push

Your git identity is pre-configured (Eliza <eliza@skovlund.dev>).

```bash
cd /var/lib/zeroclaw/repos/eliza-config
git add skills/<skill-name>/
git commit -m "feat(skills): add <skill-name> skill"
git push origin main
```

### 5. Trigger hot reload

```bash
touch /var/lib/zeroclaw/.zeroclaw/redeploy-trigger
```

A systemd path unit watches for this file. When created, it:
1. Pulls the latest from your local clone
2. Copies skills and workspace files to the workspace (replacing Nix store symlinks)
3. Restarts ZeroClaw to pick up changes

Wait ~5 seconds, then verify the change is live by reading the deployed skill file.

## Updating an existing skill

1. `cd /var/lib/zeroclaw/repos/eliza-config && git pull origin main`
2. Edit the skill's SKILL.md
3. `git commit -m "fix(skills): update <skill-name> — <what changed>"`
4. `git push origin main`
5. `touch /var/lib/zeroclaw/.zeroclaw/redeploy-trigger`

## Skill quality checklist

Before committing, verify:
- [ ] SKILL.md exists and is non-empty
- [ ] Has clear "When to use" section with trigger phrases
- [ ] Steps are concrete (actual commands, not hand-wavy instructions)
- [ ] Output format is defined (Telegram-friendly)
- [ ] No secrets or sensitive data in the skill file
- [ ] Notes section covers edge cases and known limitations

## Workspace files

Workspace files (SOUL.md, IDENTITY.md, etc.) follow the same workflow:
1. Edit in the clone under `workspace/`
2. Commit, push, trigger reload

## Notes

- Don't try to edit deployed skill files — they're read-only Nix store symlinks
- The git workflow ensures all changes are tracked and reviewable
- If you're unsure whether a change is appropriate, propose it to Thomas first
- SKILL.toml is optional — ZeroClaw extracts metadata from SKILL.md headers
- The hot reload replaces Nix store symlinks with real files — the next `make deploy-miles` reconciles them back to symlinks
