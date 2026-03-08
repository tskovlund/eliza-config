# Memory Management

Store and recall decisions, preferences, findings, and lessons learned. Maintain the knowledge that persists between sessions.

## When to use

- After completing tasks with decisions worth preserving
- After debugging sessions with reusable insights
- When Thomas confirms a preference or convention
- When recalling prior context before making decisions
- When Thomas says "remember this", "what did we decide about..."

## Memory architecture

### Two-tier system

1. **Built-in memory** (brain.db) -- conversation history, short-term context
   - `memory_store` / `memory_recall` / `memory_forget`
   - Auto-saved from conversations, 30-day retention
   - Good for: "what did we talk about yesterday"

2. **Shared semantic memory** (mcp-memory-service) -- long-term knowledge
   - HTTP API at `http://localhost:8765/mcp`
   - SQLite-vec + ONNX embeddings, semantic search
   - Shared with Claude Code -- single source of truth
   - Good for: decisions, preferences, findings, architecture knowledge
   - **Always use this for durable knowledge** -- don't duplicate in brain.db

### Files
- **MEMORY.md** -- Curated highlights (auto-injected into system prompt)
- **memory/YYYY-MM-DD.md** -- Daily raw logs

## Shared memory API

All requests go to `http://localhost:8765/mcp` via MCP JSON-RPC protocol.
No auth needed from localhost.

### Store a memory

```bash
curl -s -X POST http://localhost:8765/mcp \
  -H "Content-Type: application/json" \
  -H "Accept: application/json, text/event-stream" \
  -d '{"jsonrpc":"2.0","id":1,"method":"tools/call","params":{"name":"memory_store","arguments":{"content":"<memory content>","metadata":{"tags":"<comma-separated tags>","type":"<note|decision|reference>"}}}}'
```

### Search memories (semantic)

```bash
curl -s -X POST http://localhost:8765/mcp \
  -H "Content-Type: application/json" \
  -H "Accept: application/json, text/event-stream" \
  -d '{"jsonrpc":"2.0","id":1,"method":"tools/call","params":{"name":"memory_search","arguments":{"query":"<search query>","limit":10}}}'
```

### List memories

```bash
curl -s -X POST http://localhost:8765/mcp \
  -H "Content-Type: application/json" \
  -H "Accept: application/json, text/event-stream" \
  -d '{"jsonrpc":"2.0","id":1,"method":"tools/call","params":{"name":"memory_list","arguments":{"page_size":20}}}'
```

### Update a memory

```bash
curl -s -X POST http://localhost:8765/mcp \
  -H "Content-Type: application/json" \
  -H "Accept: application/json, text/event-stream" \
  -d '{"jsonrpc":"2.0","id":1,"method":"tools/call","params":{"name":"memory_update","arguments":{"hash":"<content_hash>","content":"<updated content>","metadata":{"tags":"<tags>"}}}}'
```

### Delete a memory

```bash
curl -s -X POST http://localhost:8765/mcp \
  -H "Content-Type: application/json" \
  -H "Accept: application/json, text/event-stream" \
  -d '{"jsonrpc":"2.0","id":1,"method":"tools/call","params":{"name":"memory_delete","arguments":{"content_hash":"<hash>"}}}}'
```

## What to store (in shared memory)

- **Decisions + rationale** -- the choice AND why (alternatives considered, trade-offs)
- **Preferences** -- confirmed patterns Thomas wants to follow
- **Investigation findings** -- results of debugging, research, exploration
- **Debugging insights** -- root cause + solution for non-obvious problems
- **Convention discoveries** -- "this repo uses X pattern" type findings
- **Personal context** -- facts about Thomas, his life, relationships, taste, goals

## What NOT to store

- **Instructions** -- belong in CLAUDE.md (loaded every session)
- **Session-specific context** -- current task details, temporary state
- **Unverified conclusions** -- verify before writing
- **CLAUDE.md duplicates** -- memory supplements, doesn't replace
- **Trivial facts** -- obvious from reading the code
- **Duplicates** -- check existing memories first
- **Conversation history** -- that stays in brain.db (built-in tools)

## Tag taxonomy

- **Topic tags:** `nix`, `cambr`, `skovlund.dev`, `mcp-score`, `eliza`, `vps`
- **Type tags:** `decision`, `preference`, `debugging`, `gotcha`, `convention`, `finding`, `personal`, `reference`
- **Domain tags:** `infrastructure`, `ci`, `git`, `deployment`, `taste`

## Storing workflow (update-before-create)

1. **Search shared memory first**: `memory_search` via HTTP for the topic
2. **If found**: update the existing entry (`memory_update`) rather than creating a duplicate
3. **If new**: store via HTTP with descriptive content and relevant tags
4. **Tags**: use lowercase, comma-separated. Examples: `decision,nix`, `preference,workflow`, `thomas,personal`

## Recall workflow

1. **Before making decisions**: search shared memory for prior context
2. **Semantic search** finds conceptually similar content -- exact wording isn't required
3. **If found**: follow prior decisions unless clear reason to diverge
4. **If nothing found**: proceed normally, consider storing the outcome

### What to do with results

- **Prior decision found** -> follow it unless clear reason to diverge (flag if diverging)
- **Preference found** -> apply it without re-confirming
- **Personal context found** -> use naturally in conversation
- **Outdated info found** -> note it, update or delete via memory_update/memory_delete
- **Nothing found** -> proceed normally

## MEMORY.md updates

MEMORY.md is special -- it's in your system prompt every session. Only put things there that are:
- Referenced frequently across sessions
- Core facts about Thomas, projects, or infrastructure
- Durable decisions that affect daily behavior

For everything else, use the shared memory API (searchable on demand).

## Notes

- Always announce memory writes: what was stored and why
- Shared memory is the single source of truth -- Claude Code uses the same store
- Don't store conflicting information in brain.db vs shared memory
- MEMORY.md changes require the eliza-config repo workflow (read-only on disk)

## Cross-references

Claude Code counterparts: `/memory-recall`, `/memory-store`
