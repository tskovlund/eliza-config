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
  issues(filter: {
    team: { id: { eq: "4931919c-2b49-4bd0-b316-005f8bd66554" } }
    state: { name: { in: ["In Progress", "Todo"] } }
  }) {
    nodes { identifier title state { name } priority }
  }
}
```

### Create an issue

```graphql
mutation {
  issueCreate(input: {
    teamId: "4931919c-2b49-4bd0-b316-005f8bd66554"
    title: "Issue title"
    description: "Description"
    priority: 2
    stateId: "<state-id>"
  }) {
    success
    issue { identifier url }
  }
}
```

### Update issue status

```graphql
mutation {
  issueUpdate(id: "<issue-id>", input: {
    stateId: "<new-state-id>"
  }) {
    success
  }
}
```

### Add a comment

```graphql
mutation {
  commentCreate(input: {
    issueId: "<issue-id>"
    body: "Comment text"
  }) {
    success
  }
}
```

## Conventions

- **Projects** for multi-phase efforts, standalone issues for bounded tasks
- **Labels:** migration, nix, infra, research, exploration, work, web
- **Priority:** Urgent=today, High=this week, Medium=this month, Low=no timeline
- **Statuses:** Triage -> Backlog -> Todo -> In Progress / Blocked -> Done / Canceled
- **No estimates.** Due dates used sparingly.
- **Triage issues** are raw ideas — can be shaped and promoted
- **Non-triage issue bodies** are the original spec. Add context via comments, not body edits.
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
