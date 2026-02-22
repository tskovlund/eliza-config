# Delegation

Spawn and coordinate sub-agents for complex tasks. Break down work, assign to delegates, collect results.

## When to use

- When a task is too complex for a single pass
- When parallelism would speed things up
- When fresh context would improve quality (e.g., code review)
- When Thomas says "spawn agents", "delegate this", "break this down"

## Delegation principles

1. **Clear mandate**: Each delegate gets a specific, focused task with success criteria
2. **Fresh context**: Delegates start clean — give them all context they need in the prompt
3. **Independence**: Delegates should be able to complete their task without further input
4. **Verify results**: Always review delegate output before acting on it

## Using the `delegate` tool

```
delegate:
  task: "Review the diff in PR #42 for security issues. Post comments on GitHub for any findings."
  model: "claude-sonnet-4-6"  # or appropriate model
  system_prompt: "You are a security reviewer. Focus on injection vectors, auth issues, and data exposure."
  tools: ["shell", "http_request", "git_operations"]
```

## Model routing guidelines

Choose the model based on task complexity:

| Task type | Model | Reasoning |
|-----------|-------|-----------|
| Simple lookups, formatting | claude-haiku-4-5 | Fast, cheap, sufficient |
| Code review, writing, analysis | claude-sonnet-4-6 | Good balance of quality and speed |
| Architecture, complex reasoning | claude-opus-4-6 | Best quality for critical decisions |
| Creative writing, nuanced judgment | claude-opus-4-6 | Nuance matters |

## Delegation patterns

### Parallel review
Spawn multiple reviewers with different focuses:
- Reviewer 1: correctness and logic
- Reviewer 2: security and edge cases
- Reviewer 3: style and maintainability

### Research swarm
Spawn agents to investigate different angles:
- Agent 1: search documentation
- Agent 2: read source code
- Agent 3: check issue trackers

### Pipeline
Chain agents sequentially:
1. Researcher gathers information
2. Planner designs approach
3. Implementer writes code
4. Reviewer validates

### Fan-out / Fan-in
Distribute work, then aggregate:
1. Spawn N agents for independent subtasks
2. Collect all results
3. Synthesize into final output

## Task decomposition

When breaking down a complex task:

1. **Identify independent subtasks** — things that don't depend on each other
2. **Sequence dependent steps** — things that must happen in order
3. **Assign appropriate models** — match complexity to capability
4. **Define success criteria** — how to know each subtask is done
5. **Plan aggregation** — how results come together

## Notes

- Don't over-delegate simple tasks — sometimes just doing it is faster
- Delegate tool availability depends on config — check what tools delegates can use
- Delegates don't share your memory — give them all relevant context
- For the Cambr "execute mutation!" workflow: this is the skill that orchestrates strategy mutation swarms
- Cost is not a concern — use the best model for each task
