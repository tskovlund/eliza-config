# Skill Management

Create, update, and manage your own skill library. Skills live in the `eliza-config` repo and are deployed to your workspace.

## When to use

- When you need to add a new skill
- When an existing skill needs updating
- When Thomas says "add a skill", "update skill", "manage skills"
- When self-improvement identifies a skill gap

## Understanding the architecture

- Skills live in the `eliza-config` repo under `skills/<name>/SKILL.md`
- Deployed to `/var/lib/zeroclaw/.zeroclaw/workspace/skills/` via nix-config
- **Deployed files are READ-ONLY** (Nix store symlinks) -- you cannot edit them in place
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

### Naming convention

Follow `skill-<topic>-<action>` or `skill-<topic>` pattern. Group related skills by topic prefix:

- `skill-linear-operations` (topic: linear)
- `skill-memory-management` (topic: memory)
- `skill-pr-review` (topic: pr)
- `skill-self-improvement` (topic: self)
- `skill-skill-management` (topic: skill)
- `skill-docs` (topic: docs)

### Quality checklist

Before committing, verify:
- [ ] SKILL.md exists and is non-empty
- [ ] Has clear "When to use" section with trigger phrases
- [ ] Steps are concrete (actual commands, not hand-wavy instructions)
- [ ] Output format is defined (Telegram-friendly)
- [ ] No secrets or sensitive data in the skill file
- [ ] Notes section covers edge cases and known limitations
- [ ] Instructions are specific and actionable (commands, not vibes)
- [ ] At least 1-2 worked examples or concrete scenarios
- [ ] Error handling for known failure modes
- [ ] Cross-references to related skills where natural

### 4. Commit and push

Your git identity is pre-configured. Commits sign automatically.

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
3. `git commit -m "fix(skills): update <skill-name> -- <what changed>"`
4. `git push origin main`
5. `touch /var/lib/zeroclaw/.zeroclaw/redeploy-trigger`

## When to consider new skills

**After completing a task:** Did I follow a repeatable workflow that isn't yet a skill?
- Multi-step process I'd do the same way next time
- Specific tools in a specific order

**After struggling with a task:** Would a skill have helped?
- Had to search for conventions that should be readily available
- Made a mistake that instructions would have prevented

## Direct corrections vs proposals

**Direct corrections -- apply immediately:**
When Thomas corrects behavior ("you should have done X"), this is implicit approval. Update the skill and briefly confirm what changed.

**New skills and major redesigns -- propose first:**
For speculative new skills or architectural changes, propose: name, purpose, outline. Create after approval.

**Edge case fixes -- use judgment:**
Obvious, low-risk fixes: apply and mention. Behavior-changing fixes: propose first.

## Workspace files

Workspace files (SOUL.md, IDENTITY.md, etc.) follow the same workflow:
1. Edit in the clone under `workspace/`
2. Commit, push, trigger reload

## Notes

- Don't try to edit deployed skill files -- they're read-only Nix store symlinks
- The git workflow ensures all changes are tracked and reviewable
- If you're unsure whether a change is appropriate, propose it to Thomas first
- SKILL.toml is optional -- ZeroClaw extracts metadata from SKILL.md headers
- The hot reload replaces Nix store symlinks with real files -- the next `make deploy-miles` reconciles them back to symlinks

## Cross-references

Claude Code counterparts: `/skill-add`, `/skill-update`, `/skill-write`
