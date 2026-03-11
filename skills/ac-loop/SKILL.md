# AC Loop Orchestration

Orchestrate worker/verifier loops with typed acceptance criteria. Define ACs per task, dispatch verification, loop until all pass or escalate.

## When to use

- When Thomas says "implement this with AC loop", "use the verification loop", "run with acceptance criteria"
- When a Linear issue has an `acceptance_criteria:` YAML block in its body
- When delegating complex coding tasks where "tests pass" isn't sufficient
- When you want rigorous verification beyond a single agent pass

## AC schema

ACs are embedded in Linear issue bodies as a fenced YAML block:

```yaml
acceptance_criteria:
  - description: "All tests pass"
    verify: { type: "command", run: "make test" }
  - description: "No linting violations"
    verify: { type: "command", run: "make lint" }
  - description: "New code follows conventions"
    verify:
      {
        type: "agent_review",
        prompt: "Review the diff against CONVENTIONS.md. Check: conventional commits, no debug logging, sorted imports. Report pass/fail per item.",
      }
  - description: "Sort stability property holds"
    verify:
      {
        type: "property",
        run: "pytest tests/test_properties.py -k test_sort_stable",
      }
  - description: "sort_preserves_length theorem verified"
    verify: { type: "proof", prover: "lean4", theorem: "Sort.preserves_length" }
  - description: "Visual change looks correct"
    verify: { type: "human", instruction: "Open the page and check the layout" }
```

### Verification types

| Type           | How it verifies                                           | Isolation                            |
| -------------- | --------------------------------------------------------- | ------------------------------------ |
| `command`      | Run shell command, check exit code (0 = pass)             | Full — just exit code                |
| `agent_review` | Spawn independent verifier agent with diff + AC spec      | Sees diff only, not worker reasoning |
| `property`     | Run property-based tests (subset of command)              | Full — just exit code                |
| `proof`        | Run proof checker (future — TSK-137)                      | Full — proof kernel                  |
| `human`        | Ask Thomas to verify, wait for confirmation               | N/A                                  |
| `manual`       | Checked by the orchestrator (you) based on session output | N/A                                  |

## The loop

### Step 1: Parse ACs from Linear issue

````python
import yaml, re

def parse_acceptance_criteria(issue_body):
    """Extract acceptance_criteria YAML block from Linear issue body."""
    # Match fenced YAML block
    match = re.search(r'```ya?ml\s*\n(.*?)\n```', issue_body, re.DOTALL)
    if not match:
        return None
    try:
        data = yaml.safe_load(match.group(1))
        return data.get("acceptance_criteria", [])
    except yaml.YAMLError:
        return None
````

### Step 2: Spawn worker agent

Use the task-lifecycle skill to spawn a Claude Code session:

```bash
cd /var/lib/zeroclaw/repos/<repo>
claude -p "<worker prompt with full task context>" --output-format json
```

The worker prompt should include:

- The task description (from Linear issue)
- The repo context
- Instructions to commit and push when done
- **Do NOT include the AC list** — the worker works on the task, the verifier checks the output

### Step 3: Run verification

After the worker completes, run each AC:

```python
import subprocess, json, time

def verify_ac(ac, repo_path, diff_text=None):
    """Verify a single acceptance criterion. Returns (pass: bool, details: str)."""
    verify = ac.get("verify", {})
    ac_type = verify.get("type", "manual")

    if ac_type == "command":
        cmd = verify.get("run", "")
        result = subprocess.run(
            cmd, shell=True, capture_output=True, text=True,
            timeout=300, cwd=repo_path
        )
        passed = result.returncode == 0
        details = result.stdout[-500:] if passed else result.stderr[-500:]
        return passed, details

    elif ac_type == "property":
        # Same as command but semantically distinct
        cmd = verify.get("run", "")
        result = subprocess.run(
            cmd, shell=True, capture_output=True, text=True,
            timeout=600, cwd=repo_path
        )
        passed = result.returncode == 0
        details = result.stdout[-500:] if passed else result.stderr[-500:]
        return passed, details

    elif ac_type == "agent_review":
        # Spawn independent verifier — sees ONLY the diff + AC spec
        prompt = verify.get("prompt", "Review the changes")
        verifier_prompt = f"""You are an independent code verifier. Your job is to evaluate whether this diff meets the acceptance criterion.

ACCEPTANCE CRITERION: {ac['description']}

REVIEW INSTRUCTIONS: {prompt}

DIFF:
{diff_text or '(no diff available)'}

Respond with EXACTLY one of:
- PASS: <brief reason>
- FAIL: <specific issues found>

Be strict. Only pass if the criterion is clearly met."""

        result = subprocess.run(
            ["claude", "-p", verifier_prompt, "--output-format", "json",
             "--model", "claude-sonnet-4-6"],
            capture_output=True, text=True, timeout=300,
            cwd=repo_path
        )
        output = json.loads(result.stdout)
        result_text = output.get("result", "")
        passed = result_text.strip().upper().startswith("PASS")
        return passed, result_text

    elif ac_type == "proof":
        # Future — TSK-137
        return False, "Proof verification not yet implemented"

    elif ac_type == "human":
        # Cannot auto-verify — flag for Thomas
        instruction = verify.get("instruction", "Please verify manually")
        return None, f"NEEDS HUMAN VERIFICATION: {instruction}"

    elif ac_type == "manual":
        # Checked by orchestrator (you) based on session output
        return None, "Manual check — review session output"

    return False, f"Unknown verification type: {ac_type}"
```

### Step 4: Evaluate results and loop

```python
def run_ac_loop(task_id, repo, worker_prompt, acceptance_criteria, max_iterations=10):
    """Run the full AC loop. Returns final results."""
    repo_path = f"/var/lib/zeroclaw/repos/{repo}"
    results_history = []
    session_id = None

    for iteration in range(1, max_iterations + 1):
        # --- Worker phase ---
        if iteration == 1:
            # First iteration: fresh session
            worker_result = subprocess.run(
                ["claude", "-p", worker_prompt, "--output-format", "json"],
                capture_output=True, text=True, timeout=3600,
                cwd=repo_path
            )
        else:
            # Subsequent iterations: resume with failure context
            failure_summary = format_failures(results_history[-1])
            resume_prompt = f"""The following acceptance criteria FAILED in iteration {iteration - 1}:

{failure_summary}

Fix these issues. Do not break anything that was previously passing. Commit and push when done."""

            resume_args = ["claude", "-p", resume_prompt, "--output-format", "json"]
            if session_id:
                resume_args.extend(["--resume", session_id])
            worker_result = subprocess.run(
                resume_args, capture_output=True, text=True, timeout=3600,
                cwd=repo_path
            )

        worker_output = json.loads(worker_result.stdout)
        session_id = worker_output.get("session_id")

        # --- Verification phase ---
        # Get the diff for agent_review type ACs
        diff_result = subprocess.run(
            ["git", "diff", "HEAD~1"], capture_output=True, text=True, cwd=repo_path
        )
        diff_text = diff_result.stdout[:10000]  # cap at 10k chars

        iteration_results = []
        for ac in acceptance_criteria:
            passed, details = verify_ac(ac, repo_path, diff_text)
            iteration_results.append({
                "description": ac["description"],
                "type": ac["verify"]["type"],
                "passed": passed,
                "details": details
            })

        results_history.append(iteration_results)

        # --- Check completion ---
        auto_results = [r for r in iteration_results if r["passed"] is not None]
        all_auto_pass = all(r["passed"] for r in auto_results)
        human_needed = [r for r in iteration_results if r["passed"] is None]

        if all_auto_pass:
            return {
                "status": "passed" if not human_needed else "needs_human",
                "iterations": iteration,
                "results": iteration_results,
                "session_id": session_id,
                "human_checks": human_needed
            }

        # --- Stuck detection ---
        if len(results_history) >= 3:
            recent_failures = [
                set(r["description"] for r in res if r["passed"] is False)
                for res in results_history[-3:]
            ]
            if recent_failures[0] == recent_failures[1] == recent_failures[2]:
                return {
                    "status": "stuck",
                    "iterations": iteration,
                    "results": iteration_results,
                    "session_id": session_id,
                    "stuck_on": list(recent_failures[0])
                }

    return {
        "status": "max_iterations",
        "iterations": max_iterations,
        "results": results_history[-1],
        "session_id": session_id
    }


def format_failures(iteration_results):
    """Format failed ACs for the worker prompt."""
    lines = []
    for r in iteration_results:
        if r["passed"] is False:
            lines.append(f"- FAILED: {r['description']}")
            lines.append(f"  Type: {r['type']}")
            lines.append(f"  Details: {r['details'][:300]}")
    return "\n".join(lines)
```

## Loop control

- **Hard cap**: 10 iterations (adjustable per task)
- **Stuck detection**: same failures for 3 consecutive iterations
- **Escalation**: on stuck or max iterations, post results to Linear and notify Thomas

## Reporting

### Per-iteration update (Linear comment)

After each verification round, post a comment on the Linear issue:

```
### AC Loop — Iteration 3

| AC | Type | Result |
|----|------|--------|
| All tests pass | command | PASS |
| No lint violations | command | PASS |
| Follows conventions | agent_review | FAIL: missing sorted imports in src/main.py |

Resuming worker with failure details...
```

### Final report

On completion, update the Linear issue:

**If all pass**: move to In Review (or Done if no human checks needed). Comment with summary.

**If stuck**: move to Blocked. Comment with stuck details + session ID for manual investigation.

**If max iterations**: move to Blocked. Comment with final state + what's still failing.

Always notify Thomas via Telegram with the final status.

## Worker-verifier isolation

The worker and verifier must be independent:

- **Worker** sees: task description, repo, full codebase context
- **Verifier** (`agent_review`) sees: diff + AC description + review prompt
- The verifier does NOT see: the worker's reasoning, internal notes, or implementation strategy
- This prevents the verifier from rationalizing away issues because it saw the worker's intent

For `command`/`property` verification, isolation is inherent — it's just exit codes.

## Workflow

1. Thomas says "implement TSK-X with the AC loop" (or issue has `acceptance_criteria:` block)
2. Read the Linear issue, parse ACs
3. Construct worker prompt from issue description
4. Run `run_ac_loop()`
5. Post updates after each iteration
6. Report final status to Thomas

## Connecting to existing skills

- **task-lifecycle**: provides spawn/track/resume primitives
- **delegation**: provides the worker prompt patterns and model routing
- **notification-routing**: for Telegram escalation
- **linear-operations**: for reading/updating issues

## Future: formal verification (TSK-137)

The `proof` verification type is a placeholder. When Lean/Rocq tooling is available on miles:

1. Worker writes code + spec (theorem statement)
2. Proof verifier runs `lean4` against the theorem
3. If proof fails → specific error fed back to worker
4. Worker fixes either the code or the proof

This gives mathematical guarantees about behavioral properties — the highest tier of the verification spectrum.

## Notes

- PyYAML must be available on miles (`python3 -c "import yaml"`) — install via nix if needed
- Claude Code sessions on miles use Max subscription — zero marginal cost per iteration
- The verifier agent uses Sonnet (cheaper, fast) — Opus is overkill for diff review
- Don't use AC loops for simple tasks — overhead isn't worth it for "fix this typo"
