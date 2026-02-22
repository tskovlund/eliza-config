# Memory Management

Store and recall decisions, preferences, findings, and lessons learned. Maintain the knowledge that persists between sessions.

## When to use

- After completing tasks with decisions worth preserving
- After debugging sessions with reusable insights
- When Thomas confirms a preference or convention
- When recalling prior context before making decisions
- When Thomas says "remember this", "what did we decide about..."

## Memory architecture

### Files
- **MEMORY.md** — Curated long-term memories (auto-injected into system prompt)
- **memory/YYYY-MM-DD.md** — Daily raw logs (accessed via memory tools)

### Built-in tools
- `memory_store` — Save to the knowledge base
- `memory_recall` — Search for prior context
- `memory_forget` — Delete a memory entry

## What to store

- **Decisions + rationale** — the choice AND why (alternatives considered, trade-offs)
- **Preferences** — confirmed patterns Thomas wants to follow
- **Investigation findings** — results of debugging, research, exploration
- **Debugging insights** — root cause + solution for non-obvious problems
- **Convention discoveries** — "this repo uses X pattern" type findings

## What NOT to store

- **Session-specific context** — current task details, temporary state
- **Unverified conclusions** — verify before writing
- **Trivial facts** — obvious from reading the code
- **Duplicates** — check existing memories first

## Storing workflow

1. **Check for existing memories** on the same topic: `memory_recall "<topic>"`
2. **If found**: add to existing entry rather than creating a duplicate
3. **If new**: use `memory_store` with a descriptive, searchable key
4. **If superseding**: note that the old info is replaced

### MEMORY.md updates

MEMORY.md is special — it's in your system prompt every session. Only put things there that are:
- Referenced frequently across sessions
- Core facts about Thomas, projects, or infrastructure
- Durable decisions that affect daily behavior

For everything else, use `memory_store` (searchable on demand).

## Recall workflow

1. **Before making decisions**: search for prior context
2. **Search is literal** — try multiple phrasings:
   - Specific term: "nix-config", "cambr", "skovlund.dev"
   - Related concepts: "home-manager module", "deployment"
   - Decision area: "git workflow", "styling convention"
3. **If found**: follow prior decisions unless there's a clear reason to diverge
4. **If nothing found**: proceed normally

## Housekeeping

Periodically (during self-improvement reviews):
- Prune outdated memories
- Consolidate related entries
- Move frequently-accessed memories to MEMORY.md
- Remove session-specific entries that leaked into long-term storage

## Notes

- Always announce memory writes: what was stored and why
- MEMORY.md changes require the eliza-config repo workflow (read-only on disk)
- Daily notes (memory/YYYY-MM-DD.md) are writable at runtime
- `memory_store`/`memory_recall` are the built-in tools — separate from file-based memory
