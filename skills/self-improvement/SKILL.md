# Self-Improvement

Reflect on interactions, identify patterns, and continuously improve skills, config, and behavior.

## When to use

- Periodically (weekly self-review)
- After a notable failure or success
- When Thomas says "reflect", "improve", "what have you learned"
- After completing a complex multi-step task

## Skill-Evolve Triggers

Stay alert for improvement opportunities during normal work:

**After completing a task:** Did I follow a repeatable workflow that isn't yet a skill?

- Multi-step process I'd do the same way next time
- Conventions from config that could be loaded on demand
- Specific tools in a specific order

**After struggling with a task:** Would a skill have helped?

- Had to search for conventions that should be readily available
- Made a mistake that instructions would have prevented

**When updating config:** Should this be a skill instead?

- Config = always loaded (every token counts)
- Skills = loaded on demand (better for reference material and workflows)

**When a skill's instructions didn't match reality:**

- A command, tool, or API changed behavior
- A step failed in a real scenario
- A better approach was discovered

## Reflection Process

### 1. Review recent interactions

- Read recent daily memory files: `memory/YYYY-MM-DD.md`
- Check `MEMORY.md` for accumulated patterns
- Look for: repeated mistakes, workarounds, things that took too long

### 2. Identify improvement areas

**Skill gaps**: Did I lack a skill for something Thomas asked?

- If yes: draft a new skill and propose it
- Use the skill-management skill for the creation workflow

**Config issues**: Was I blocked by a config limitation?

- Autonomy restrictions that caused friction
- Missing tools in PATH
- Missing integrations

**Communication**: Did I over-explain, under-explain, or miss the tone?

- Check SOUL.md preferences
- Adjust behavior, update AGENTS.md if the lesson is durable

**Efficiency**: Could I have done something faster?

- Tasks that could be parallelized via delegation
- Repeated manual steps that should be automated (cron jobs)

### 3. Infrastructure healing

Watch for and fix:

- Stale symlinks after skill renames (hot reload handles this)
- Missing skills after deploy -- check that the skill exists in the repo
- Skills that reference removed files, renamed commands, or outdated conventions

### 4. Skill sync awareness

When updating a skill, check if the counterpart on the other platform needs updating too:

- Eliza skills live in `eliza-config/skills/`
- Claude Code skills live in `nix-config-personal/skills/`
- They cover the same workflows but with platform-specific details
- If you update an Eliza skill, note that the Claude Code counterpart may need a matching update (and vice versa)

### 5. Take action

For each improvement identified:

1. **If it's a skill change**: Clone eliza-config, edit the skill, commit, push. Document what changed and why.
2. **If it's a memory**: Write it to MEMORY.md or a daily note
3. **If it's a config change**: Note it in TOOLS.md and inform Thomas
4. **If it's a new skill**: Follow the skill-management workflow

### 6. Report

Summarize findings to Thomas:

```
Self-improvement review -- [date]

IMPROVEMENTS MADE:
- Updated system-health skill: added Grafana alert check
- Added memory: "Thomas prefers squash merges"

PROPOSED:
- New skill: git-operations (common git workflows)
- Config: add `docker` to PATH for container work

SKILL SYNC:
- Updated skill-docs on Eliza -- Claude Code /docs may need matching update

NO ACTION NEEDED:
- Communication style is calibrated well
- Delegation patterns working as expected
```

## Weekly Self-Review Cron

```
zeroclaw cron add self-review --cron "0 20 * * 0" --timezone "Europe/Berlin" --message "Run a self-improvement review for the past week"
```

## Notes

- Be honest in self-assessment -- the point is to get better, not to look good
- Small, frequent improvements compound. Don't wait for big overhauls.
- Always propose changes to Thomas before making behavioral shifts
- Update SOUL.md or AGENTS.md only for durable lessons, not one-off adjustments

## Cross-references

Claude Code counterpart: `/skill-evolve`
