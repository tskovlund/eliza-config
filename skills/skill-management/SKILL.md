# Skill Management

Create, update, and manage your own skill library. Skills live in the `eliza-config` repo and are deployed read-only to your workspace.

## When to use

- When you need to add a new skill
- When an existing skill needs updating
- When Thomas says "add a skill", "update skill", "manage skills"
- When self-improvement identifies a skill gap

## Understanding the architecture

- Skills live in `github.com/tskovlund/eliza-config` under `skills/<name>/SKILL.md`
- Deployed to `/var/lib/zeroclaw/.zeroclaw/workspace/skills/` via nix-config
- **Deployed files are READ-ONLY** — you cannot edit them in place
- To modify: clone the repo, edit, commit, push, then deploy

## Adding a new skill

### 1. Clone the repo (if not already)

```bash
cd /tmp
git clone https://github.com/tskovlund/eliza-config.git
cd eliza-config
```

### 2. Create the skill directory

```bash
mkdir -p skills/<skill-name>
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

```bash
git add skills/<skill-name>/
git commit -m "feat(skills): add <skill-name> skill"
git push origin main
```

### 5. Deploy

Tell Thomas to run `make deploy-miles` from nix-config, or if you have deployment access:
```bash
# Future: trigger deployment via webhook or SSH
```

## Updating an existing skill

1. Clone eliza-config (or pull latest)
2. Edit the skill's SKILL.md
3. Commit: `git commit -m "fix(skills): update <skill-name> — <what changed>"`
4. Push and deploy

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
1. Edit in eliza-config under `workspace/`
2. Commit, push, deploy

## Notes

- Don't try to edit deployed skill files — they're read-only for a reason
- The git workflow ensures all changes are tracked and reviewable
- If you're unsure whether a change is appropriate, propose it to Thomas first
- SKILL.toml is optional — ZeroClaw extracts metadata from SKILL.md headers
