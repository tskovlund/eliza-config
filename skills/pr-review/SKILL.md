# PR Review

Full pull request lifecycle: create a PR, review it, address feedback, iterate until clean, and merge.

## When to use

- When asked to "create a PR", "review a PR", "submit for review"
- After completing a feature branch that's ready for review
- When Thomas says "PR this" or "get this merged"

## PR Creation

1. **Prepare the branch**:
   - Verify all changes are committed
   - Ensure the branch is pushed: `git push -u origin <branch>`

2. **Create the PR**:

   ```
   gh pr create --title "<type>(<scope>): <description>" --body "## Summary\n\n<bullets>\n\n## Test plan\n\n<checkboxes>\n\n## Related issues\n\n<links>"
   ```

3. **Wait for CI**: `gh pr checks <number> --watch`

## Review Process

### 1. Gather PR context

```sh
gh pr view <number>
gh pr diff <number>
gh pr diff <number> --name-only
gh pr checks <number>
gh pr view <number> --comments
```

### 2. Understand the change

- Read PR description for intent
- Read linked issues for requirements
- Identify scope: which files, which subsystem
- Read surrounding code in modified files for context

### 3. Analyze the diff

For each changed file, assess:

- **Correctness** -- logic errors, off-by-one, race conditions, edge cases, error paths
- **Security** -- injection, path traversal, secrets, overly permissive permissions
- **Style/conventions** -- repo patterns, naming, structure (check CLAUDE.md and CONVENTIONS.md)
- **Completeness** -- docs updated, tests added, TODOs justified
- **Simplicity** -- over-engineering, unnecessary abstractions

### 4. Post review comments

Use severity levels to classify findings:

- **Bug:** -- correctness issue causing wrong behavior
- **Security:** -- potential vulnerability
- **Nit:** -- style/preference, non-blocking
- **Question:** -- need clarification
- **Suggestion:** -- improvement idea, non-blocking

Post as a **COMMENT review** (not APPROVE/REQUEST_CHANGES -- GitHub blocks these for self-review).

```sh
gh api repos/<owner>/<repo>/pulls/<number>/comments -f body="<comment>" -f path="<file>" -f line=<n> -f side="RIGHT" -f commit_id="$(gh pr view <number> --json headRefOid -q .headRefOid)"
```

### Review comment guidelines

- Be specific -- point to exact lines, explain consequences
- Distinguish blocking (Bug, Security) from non-blocking (Nit, Suggestion)
- Offer fixes -- use GitHub suggestion syntax where applicable
- One concern per comment
- Acknowledge good work when warranted

## Spawning Independent Reviewers

For significant PRs, delegate review to fresh-context sub-agents:

1. **Delegate a code review agent** -- give it the PR number, repo, and a focused review mandate
2. **Delegate a second reviewer** (for critical PRs) -- different focus: architecture, performance, or user impact
3. **Collect feedback**: `gh api repos/<owner>/<repo>/pulls/<number>/comments`

## Addressing Feedback (pr-fix)

**Every comment gets an explicit reply** -- an unaddressed comment looks identical to an ignored comment.

For each comment, do BOTH:

1. **Act on it**: Fix the code, or decline with an explanation
2. **Reply on GitHub**:
   ```sh
   gh api "repos/{owner}/{repo}/pulls/{number}/comments/{comment_id}/replies" \
     -f body="Fixed -- renamed to avoid shadowing"
   ```

Keep fix commits atomic -- one fix per comment where practical.

## Review Loop

### Record comment baseline

```sh
BASELINE_ID=$(gh api "repos/{owner}/{repo}/pulls/<number>/comments" \
  --jq '[.[].id] | max // 0')
```

### Assess and loop

After addressing comments and pushing fixes:

- **Another round** if: substantive bugs were fixed (fixes may introduce new issues), or significant new code was written
- **No further round** if: only nits/suggestions, review was clean, or fixes were trivial (renames, formatting)
- **Max rounds (5):** exit -- summarize remaining concerns

## Merge

Once all comments are resolved and CI passes:

1. Verify: `gh pr view <number> --json reviewDecision,statusCheckRollup`
2. Merge: `gh pr merge <number> --squash --delete-branch`
3. Reply to any remaining comments post-merge if needed

## Notes

- Always reply to review comments -- don't leave them hanging
- Use squash merge to keep main history clean
- Reviewer agents should be independent sessions (no shared context) for genuine second opinions
- For nix-config PRs: Copilot auto-reviews via the "Protect main" ruleset -- always read those comments too
- This skill handles the entire lifecycle. Don't split into separate create/review/merge steps.

## Cross-references

Claude Code counterparts: `/pr-review`, `/pr-review-loop`, `/pr-fix`
