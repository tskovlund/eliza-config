# Linear Operations

Create, update, query, and manage issues in Thomas's Linear workspace (tskovlund).

## When to use

- When Thomas says "create an issue", "track this", "update Linear"
- When triaging, prioritizing, or reviewing the backlog
- When cross-referencing Linear issues with GitHub work
- As part of morning briefing (issues in progress, blocked, triage)

## Workspace details

- **Workspace:** tskovlund
- **Team ID:** 4931919c-2b49-4bd0-b316-005f8bd66554
- **User ID (Thomas):** 70e4eb71-4f27-4465-99fa-8dd02ec6816b
- **Prefix:** TSK-
- **URL:** linear.app/tskovlund

## API access

Use `http_request` to call Linear's GraphQL API:

```
POST https://api.linear.app/graphql
Authorization: Bearer <LINEAR_API_KEY>
Content-Type: application/json

{
  "query": "{ issues(filter: { state: { name: { in: [\"In Progress\"] } } }) { nodes { identifier title state { name } priority assignee { name } } } }"
}
```

## Common operations

### List issues by status

```graphql
{
  issues(
    filter: {
      team: { id: { eq: "4931919c-2b49-4bd0-b316-005f8bd66554" } }
      state: { name: { in: ["In Progress", "Todo"] } }
    }
  ) {
    nodes {
      identifier
      title
      state {
        name
      }
      priority
    }
  }
}
```

### Create an issue

```graphql
mutation {
  issueCreate(
    input: {
      teamId: "4931919c-2b49-4bd0-b316-005f8bd66554"
      title: "Issue title"
      description: "Description"
      priority: 2
      stateId: "<state-id>"
    }
  ) {
    success
    issue {
      identifier
      url
    }
  }
}
```

### Update issue status

```graphql
mutation {
  issueUpdate(id: "<issue-id>", input: { stateId: "<new-state-id>" }) {
    success
  }
}
```

### Add a comment

```graphql
mutation {
  commentCreate(input: { issueId: "<issue-id>", body: "Comment text" }) {
    success
  }
}
```

## Track

Capture ideas and tasks for later. Route to the right tracker.

### Routing: GitHub Issues vs Linear

**GitHub Issues** -- repo-specific implementation work:

- Bugs, features, or tasks scoped to a single repo
- Anything resolved by a PR in that repo
- Create with: `gh issue create -R <owner>/<repo> --title "..." --body "..."`

**Linear** -- everything else:

- Cross-project planning, personal backlog, ideas not scoped to a repo
- When both apply: create Linear issue, note that GitHub issue should be created when implementation starts

### When to auto-trigger

**Create silently** -- intent to track is clear:

- Explicit: "track this", "add to Linear", "create an issue", "defer this"
- Contextual: "note to research X", "we should have X for Y"
- Mid-conversation: Thomas names a concrete task to do later

**Ask first** -- genuinely ambiguous:

- Vague musings: "it would be nice if..."
- Unsure which tracker is appropriate

### Triage vs shaped issue

**Triage** (Triage status, Low priority) -- rough idea, needs scoping:

```markdown
## Idea

[Core idea in 1-3 sentences]

## Context

[What prompted this, relevant constraints]
```

**Shaped** (Backlog status) -- clear scope, actionable:

```markdown
## Summary

[What and why]

## Requirements

- [ ] [Specific requirement]

## Acceptance criteria

- [ ] [How to verify done]
```

## Triage

Shape triage issues into actionable backlog items.

### Triage workflow

1. Read the full issue body
2. Read ALL comments -- they contain scope changes, decisions, and corrections
3. Assess: Clear enough to act on? Standalone or part of a project? Actionable now?
4. Set metadata (priority per CLAUDE.md, labels, project if applicable)
5. Promote status: Triage -> Backlog (shaped, not scheduled) or Triage -> Todo (ready now)

### Edit rules

- **Triage bodies CAN be edited freely** -- raw ideas being shaped
- **Non-triage bodies get comments only** -- the body is the original spec
- Exception: typos, missing sections before work starts, ticking checkboxes

## Hygiene

Sync issues with reality across both trackers.

### Audit workflow

1. Gather all active issues (NOT in Done or Canceled)
2. Check each against reality:
   - Actually In Progress, or has work stalled?
   - Done but not marked? (Check for merged PRs)
   - Should be Blocked? Still relevant, or cancel?
3. Cross-reference GitHub -- check for merged PRs that close Linear work

### Stale detection

- **In Progress, no activity in 2+ weeks** -> flag or move to Blocked
- **Todo, no activity in 4+ weeks** -> consider moving to Backlog
- **Urgent/High sitting untouched** -> flag for priority review

### Label and priority accuracy

- Every issue should have at least one label
- Priority still matches reality?

## Planning

Prioritize the backlog through the lens of Thomas's strategic goals.

### Evaluation framework

For each item, assess:

**Does it compound?** Creates reusable infrastructure? Makes future work faster? Reduces manual toil?

**Does it ship?** Produces something people can use? Moves a product closer to launch?

**Does it unblock?** Anything waiting on this? Removes a bottleneck?

**Is it time-sensitive?** External deadlines? Decaying opportunities?

### Output

Prioritized list grouped by time horizon:

- **Today (Urgent)** -- external deadlines, blocking issues
- **This week (High)** -- compounding infrastructure, active momentum
- **This month (Medium)** -- planned features, quality improvements
- **Backlog (Low)** -- future exploration, nice-to-haves

## Conventions

- **Projects** for multi-phase efforts, standalone issues for bounded tasks
- **Labels:** migration, nix, infra, research, exploration, work, web
- **Priority:** Urgent=today, High=this week, Medium=this month, Low=no timeline
- **Statuses:** Triage -> Backlog -> Todo -> In Progress / Blocked -> Done / Canceled
- **No estimates.** Due dates used sparingly.
- Always read issue comments before working on an issue.

## Strategic context

Thomas's goal is personal freedom. Prioritize:

1. Things that **compound** (infrastructure, automation, reusable systems)
2. Things that **ship** (products, visible output)
3. Things that **unblock** other work
4. Things that are **time-sensitive**

## Notes

- Linear API key needs to be configured in config.toml or available as env var
- If API key isn't available, inform Thomas and skip Linear operations
- Cross-reference GitHub issues when Linear issues map to repo work
- Second workspace `selfdeprecated` exists but requires separate auth
- **Safety:** Always run `list_teams` before any mutation to confirm workspace (tskovlund)

## Cross-references

Claude Code counterparts: `/issue-track`, `/issue-triage`, `/issue-hygiene`, `/planning`
