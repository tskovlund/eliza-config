# Onboard to a Repository

## When to use

- First time working in a repo (no MCP memory entries for it)
- User says "onboard", "learn this repo", "explore this codebase", "get familiar"
- Starting a task in a repo you haven't worked in recently
- Do NOT use for syncing repos (use skill-repo-sync) or writing documentation

## Steps

### 0. Check shared memory first

Search MCP memory for the repo name, project name, and architecture via HTTP:

```sh
curl -s http://localhost:8765/mcp -d '{"method":"memory_search","params":{"query":"<repo-name> architecture"}}'
```

If recent findings exist, skip to step 5 (quick refresh) only.

### 1. Repo overview

```sh
basename $(git rev-parse --show-toplevel)
git remote get-url origin 2>/dev/null
```

```sh
fd --type f --exclude .git | wc -l
```

```sh
fd --type f --extension py --extension ts --extension tsx --extension js --extension rs --extension go | head -50
```

### 2. Read key files

Read in order (skip if missing): README.md, CLAUDE.md, CONVENTIONS.md, CONTRIBUTING.md.

```sh
ls README.md CLAUDE.md CONVENTIONS.md CONTRIBUTING.md 2>/dev/null
```

### 3. Understand project structure

```sh
ls -la
```

```sh
fd --type d --max-depth 2 --exclude .git --exclude node_modules --exclude __pycache__ --exclude .next --exclude dist --exclude build | sort
```

Identify:
- **Source layout:** src/, lib/, app/, flat, or domain-driven
- **Test layout:** tests/, co-located .test. files, or both
- **Config:** package.json, pyproject.toml, Cargo.toml, etc.
- **CI/CD:** .github/workflows/, Makefile, deploy scripts
- **Infra:** Dockerfile, docker-compose.yml

### 4. Identify patterns and conventions

```sh
git log --oneline -10
```

```sh
ls .githooks/ .husky/ 2>/dev/null
```

```sh
ls .eslintrc* .prettierrc* pyproject.toml rustfmt.toml .editorconfig 2>/dev/null
```

Note commit message convention, branch strategy, and dev tooling.

### 5. Check recent activity

```sh
git log --oneline --since="2 weeks ago" -20
git branch -a --sort=-committerdate | head -10
```

```sh
gh pr list --limit 5 2>/dev/null
gh issue list --limit 5 2>/dev/null
```

### 6. Present summary

```
## [repo-name] — onboarding summary

**Purpose:** One-line description
**Stack:** Language, framework, key dependencies
**Structure:** Brief layout description
**Dev workflow:** How to build, test, lint
**Conventions:** Commit style, branch strategy, key rules
**Recent focus:** What's actively being worked on
**Notes:** Anything unusual or important to remember
```

### 7. Store findings in shared MCP memory

Store durable facts via HTTP to the shared memory service:

```sh
curl -s http://localhost:8765/mcp -d '{"method":"memory_store","params":{"content":"<repo-name>: <architecture, conventions, key paths, tooling>"}}'
```

Only store durable facts — not session-specific details.

## Notes

- Don't read every file — focus on key files and structure
- Don't store session-specific or speculative information in memory
- Don't block the user's task with lengthy exploration — be efficient
- Don't re-onboard if recent MCP memory entries exist — just refresh

## Cross-references

- Claude Code counterpart: `/onboard`
