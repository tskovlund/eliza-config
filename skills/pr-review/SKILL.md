# PR Review

Full pull request lifecycle: create a PR, spawn independent reviewer agents, address feedback, iterate until clean, and merge.

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

## Self-Review Process

After creating the PR, review it yourself first:

1. **Read the full diff**: `gh pr diff <number>`

2. **Check for**:
   - Dead code, debug prints, TODOs
   - Missing error handling at system boundaries
   - Naming consistency with the repo's conventions
   - Security issues (hardcoded secrets, injection vectors)
   - Missing tests for new functionality

3. **Post review comments** on specific lines if issues found:
   ```
   gh api repos/<owner>/<repo>/pulls/<number>/comments -f body="<comment>" -f path="<file>" -f line=<n> -f side="RIGHT" -f commit_id="$(gh pr view <number> --json headRefOid -q .headRefOid)"
   ```

## Spawning Independent Reviewers

For significant PRs, delegate review to fresh-context sub-agents:

1. **Delegate a code review agent**:
   - Use the `delegate` tool to spawn a sub-agent
   - Give it the PR number, repo, and a focused review mandate
   - Example: "Review PR #42 in tskovlund/nix-config for correctness, style, and security. Post comments on GitHub."

2. **Delegate a second reviewer** (for critical PRs):
   - Different focus: architecture, performance, or user impact
   - Fresh context prevents groupthink

3. **Collect feedback**:
   - Read all review comments: `gh api repos/<owner>/<repo>/pulls/<number>/comments`
   - Read PR review summaries: `gh pr review list <number>`

## Addressing Feedback

1. **For each comment**:
   - If valid: fix the code, push the commit, reply confirming the fix
   - If disagree: reply with reasoning

2. **Push fixes**: `git add <files> && git commit -m "fix(<scope>): address review feedback" && git push`

3. **Re-check CI**: `gh pr checks <number> --watch`

4. **If further review needed**: spawn fresh reviewer agents for round 2

## Merge

Once all comments are resolved and CI passes:

1. Verify: `gh pr view <number> --json reviewDecision,statusCheckRollup`
2. Merge: `gh pr merge <number> --squash --delete-branch`
3. Reply to any remaining comments post-merge if needed

## Notes

- Always reply to review comments — don't leave them hanging
- Use squash merge to keep main history clean
- Reviewer agents should be independent sessions (no shared context) to get genuine second opinions
- For nix-config PRs: Copilot auto-reviews via the "Protect main" ruleset — always read those comments too
- This skill handles the entire lifecycle. Don't split into separate create/review/merge steps.
