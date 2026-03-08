# Task Lifecycle

Manage Claude Code session lifecycles: spawn, track, wait, resume, and report. Foundation for AC loop orchestration.

## When to use

- When spawning Claude Code sessions for coding tasks
- When tracking multiple concurrent sessions
- When a session needs follow-up (resume)
- When reporting results back to Thomas
- Before any AC loop verification (Phase 3B depends on this)

## Session registry

Track active sessions in `/var/lib/zeroclaw/sessions/`. One JSON file per session.

### Create registry entry

After spawning a session, write the tracking file:

```python
import json, time, os

os.makedirs("/var/lib/zeroclaw/sessions", exist_ok=True)

session = {
    "task_id": "TSK-42",           # Linear issue (if applicable)
    "repo": "cambr",
    "prompt_summary": "Fix ruff T20 violations",
    "started_at": time.time(),
    "status": "running",           # running | completed | failed | timed_out | stuck
    "session_id": None,            # populated after completion
    "result": None,
    "artifacts": [],               # PR URLs, commit SHAs
    "iteration": 1,                # for AC loops
    "pid": None                    # process ID for monitoring
}

filepath = f"/var/lib/zeroclaw/sessions/{session['task_id']}-{int(session['started_at'])}.json"
with open(filepath, "w") as f:
    json.dump(session, f, indent=2)
```

### Update on completion

```python
import json, glob

def update_session(task_id, updates):
    files = sorted(glob.glob(f"/var/lib/zeroclaw/sessions/{task_id}-*.json"))
    if not files:
        return None
    filepath = files[-1]  # latest
    with open(filepath) as f:
        session = json.load(f)
    session.update(updates)
    with open(filepath, "w") as f:
        json.dump(session, f, indent=2)
    return session
```

## Spawning sessions

### Single session

```bash
cd /var/lib/zeroclaw/repos/<repo>
claude -p "<prompt>" --output-format json
```

Always use `--output-format json` for structured results. Parse the output:

```python
import json, subprocess

result = subprocess.run(
    ["claude", "-p", prompt, "--output-format", "json"],
    capture_output=True, text=True, timeout=3600,
    cwd=f"/var/lib/zeroclaw/repos/{repo}"
)

output = json.loads(result.stdout)
session_id = output.get("session_id")
is_error = output.get("is_error", False)
task_result = output.get("result", "")
duration_ms = output.get("duration_ms", 0)
```

### Parallel sessions

For independent tasks across repos, spawn concurrently:

```python
import subprocess, json, concurrent.futures

tasks = [
    {"repo": "cambr", "prompt": "Fix ruff T20 violations"},
    {"repo": "mcp-score", "prompt": "Update dependencies"},
]

def run_session(task):
    result = subprocess.run(
        ["claude", "-p", task["prompt"], "--output-format", "json"],
        capture_output=True, text=True, timeout=3600,
        cwd=f"/var/lib/zeroclaw/repos/{task['repo']}"
    )
    return {"repo": task["repo"], "output": json.loads(result.stdout)}

with concurrent.futures.ThreadPoolExecutor(max_workers=4) as executor:
    results = list(executor.map(run_session, tasks))
```

## Resuming sessions

When a session needs follow-up (e.g., AC failures to fix):

```bash
cd /var/lib/zeroclaw/repos/<repo>
claude -p "<follow-up prompt>" --resume <session-id> --output-format json
```

The resumed session has full context from the previous run. Use this for:
- Feeding back AC verification failures
- Requesting additional changes after review
- Continuing work after a timeout

## Timeout and stuck detection

### Timeouts

Default timeout: 1 hour (3600s) for normal tasks. For large refactors, extend to 2 hours.

If a session times out:
1. Update registry: `status: "timed_out"`
2. Check if the session made partial progress (commits, PR created)
3. If partial progress: resume with a focused prompt on remaining work
4. If no progress: escalate to Thomas

### Stuck detection

A session is stuck when it produces the same error across multiple AC loop iterations. Tracked by the AC loop orchestrator (Phase 3B), not by this skill directly. This skill provides the primitives; the orchestrator applies the policy.

## Reporting results

After a session completes, report to Thomas via Telegram:

### Success template

```
Task: <task summary>
Repo: <repo>
Duration: <X>m
Result: <1-2 line summary>
Artifacts: <PR URL or commit SHA>
```

### Failure template

```
Task: <task summary>
Repo: <repo>
Duration: <X>m
Error: <what went wrong>
Session ID: <id> (can resume)
```

### Extracting artifacts from results

Parse the result text for common patterns:

```python
import re

def extract_artifacts(result_text):
    artifacts = []
    # PR URLs
    for match in re.finditer(r'https://github\.com/[^\s]+/pull/\d+', result_text):
        artifacts.append({"type": "pr", "url": match.group()})
    # Commit SHAs
    for match in re.finditer(r'\b[0-9a-f]{7,40}\b', result_text):
        artifacts.append({"type": "commit", "sha": match.group()})
    return artifacts
```

## Cleanup

Prune old session files periodically. Keep last 50 sessions, delete older:

```python
import glob, os

files = sorted(glob.glob("/var/lib/zeroclaw/sessions/*.json"), key=os.path.getmtime)
for f in files[:-50]:
    os.remove(f)
```

## Cross-references

- **Delegation skill**: covers WHEN to delegate (Claude Code vs ZeroClaw). This skill covers HOW to manage the lifecycle.
- **Phase 3B (AC loop)**: uses this skill's spawn/track/resume primitives for the worker agent.
- **Phase 3D (observability)**: structured logging hooks into registry updates.
