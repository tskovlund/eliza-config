# Delegation

Spawn and coordinate sub-agents for complex tasks. Two delegation mechanisms: ZeroClaw `delegate` for lightweight work, Claude Code headless for deep coding.

## When to use

- When a task involves writing, reviewing, or modifying code → Claude Code
- When a task is too complex for a single pass → either mechanism
- When parallelism would speed things up → spawn multiple
- When Thomas says "spawn agents", "delegate this", "break this down"

## Choosing the right mechanism

| Task                             | Use               | Why                                        |
| -------------------------------- | ----------------- | ------------------------------------------ |
| Write code, fix bugs, create PRs | Claude Code       | Deep repo understanding, file editing, git |
| Research, lookups, API calls     | ZeroClaw delegate | Lighter weight, faster startup             |
| Code review                      | Claude Code       | Needs full codebase context                |
| Summarize, format, translate     | ZeroClaw delegate | Simple text processing                     |
| Multi-file refactoring           | Claude Code       | Complex, needs persistence                 |
| System health, monitoring        | ZeroClaw delegate | Shell commands only                        |

## Claude Code headless

For coding tasks, spawn Claude Code in headless mode. Sessions run as Opus 4.6 with full permissions, MCP access (memory + grafana), and git signing.

### Basic invocation

```bash
cd /var/lib/zeroclaw/repos/<repo-name>
claude -p "<detailed task description>" --output-format json
```

### Key flags

- `-p "prompt"` — headless mode, prints result to stdout
- `--output-format json` — structured output (parse `result` field)
- `--output-format text` — plain text (default, good for simple tasks)
- `--resume <session-id>` — continue a previous session
- `--allowedTools "Bash,Read,Edit,Write"` — restrict tools (optional)
- `--model claude-sonnet-4-6` — override model for simpler tasks

### Coding task template

```bash
cd /var/lib/zeroclaw/repos/cambr
claude -p "Fix the failing test in tests/test_strategy.py. The error is: <paste error>. Run the test suite after fixing to verify. Commit with a conventional commit message and push." --output-format json
```

### Long-running task template

For tasks that may take hours (large refactors, multi-file changes):

```bash
cd /var/lib/zeroclaw/repos/nix-config
claude -p "Implement the changes described in GitHub issue #42. Read the issue and all comments first. Follow the PR workflow in CLAUDE.md. Create a feature branch, implement, run make check, create a PR, and run the review loop." --output-format json
```

No `--max-turns` needed — sessions handle context compression internally.

### Parallel coding tasks

Spawn multiple Claude Code sessions for independent work:

```bash
# Task 1: fix linting in cambr
cd /var/lib/zeroclaw/repos/cambr && claude -p "Fix all ruff T20 violations" --output-format json &

# Task 2: update deps in mcp-score
cd /var/lib/zeroclaw/repos/mcp-score && claude -p "Update all dependencies and fix any breaking changes" --output-format json &

# Wait for both
wait
```

### Parsing results

When using `--output-format json`, the output contains:

```json
{
  "result": "The task output text",
  "is_error": false,
  "session_id": "abc123",
  "cost_usd": 0,
  "duration_ms": 45000,
  "num_turns": 12
}
```

Use `session_id` with `--resume` to continue a session if follow-up is needed.

## ZeroClaw delegate (lightweight)

For non-coding tasks, use the built-in `delegate` tool:

```
delegate:
  task: "Review the diff in PR #42 for security issues. Post comments on GitHub for any findings."
  model: "claude-sonnet-4-6"
  system_prompt: "You are a security reviewer."
  tools: ["shell", "http_request", "git_operations"]
```

### Model routing

| Task type                       | Model             |
| ------------------------------- | ----------------- |
| Simple lookups, formatting      | claude-haiku-4-5  |
| Code review, writing, analysis  | claude-sonnet-4-6 |
| Architecture, complex reasoning | claude-opus-4-6   |

## Delegation principles

1. **Clear mandate**: Each delegate gets a specific, focused task with success criteria
2. **Fresh context**: Delegates start clean — give them all context they need
3. **Independence**: Delegates should complete their task without further input
4. **Verify results**: Review delegate output before reporting to Thomas
5. **Right tool**: Claude Code for coding, ZeroClaw delegate for everything else

## Orchestration patterns

### PR workflow (most common)

1. Spawn Claude Code in the target repo
2. Task: read issue → branch → implement → test → PR → review loop
3. Report PR URL back to Thomas via Telegram

### Parallel review

Spawn multiple delegates with different focuses:

- Delegate 1: correctness and logic
- Delegate 2: security and edge cases
- Delegate 3: style and maintainability

### Pipeline

Chain steps sequentially:

1. Research (ZeroClaw delegate) → gather context
2. Plan (ZeroClaw delegate) → design approach
3. Implement (Claude Code) → write code
4. Review (Claude Code) → validate

### Multi-repo coordination

For changes spanning repos:

1. Spawn Claude Code per repo (parallel)
2. Collect results
3. Coordinate cross-repo dependencies (e.g., deploy order)

## Reporting results

After a delegate completes:

- Summarize what was done (1-3 lines)
- Link to artifacts (PR URL, commit SHA)
- Flag anything that needs Thomas's attention
- If failed, explain what went wrong

## Notes

- Don't over-delegate simple tasks — sometimes just doing it is faster
- Claude Code sessions on miles use Max subscription — zero marginal cost
- Repos available at `/var/lib/zeroclaw/repos/` — clone others as needed
- Git identity is pre-configured (Eliza, SSH-signed commits)
- Delegates don't share your memory — give them all relevant context
