# Repo Sync

## When to use

- At session start when working in a git repo
- Before pushing changes
- User says "sync", "pull", "am I up to date"
- Starting work in a repo that may have remote changes

Applicable to repos in `/var/lib/zeroclaw/repos/` and any delegated repos.

## Steps

### 1. Fetch and check remote

```sh
git fetch --quiet
```

```sh
git status -sb
```

- **Behind (no local changes):** auto-pull with `git pull --rebase --quiet`. Report: "Pulled N commits."
- **Behind (with local changes):** warn: "Remote has N new commits, but there are local changes."
- **Diverged:** warn: "Local and remote have diverged. Rebase or merge?"
- **Ahead:** note only — unpushed commits from a previous session.

### 2. Uncommitted changes

```sh
git status --short
```

Mention briefly but don't block — may be intentional work-in-progress.

### 3. Stale branches

```sh
git branch -vv
```

Look for `[gone]` branches (tracking deleted remotes). Mention if found.

## Notes

- If everything is clean, say nothing — proceed with the user's task
- Don't block the user's task — sync and move on
- Don't repeat checks within the same session unless asked
- Don't force-push, rebase published branches, or resolve conflicts automatically
- If `git fetch` fails: check `ssh-add -l` for loaded keys, try `gh auth status`
- If `git pull --rebase` causes conflicts: don't auto-resolve, warn the user

## Cross-references

- Claude Code counterpart: `/repo-sync`
