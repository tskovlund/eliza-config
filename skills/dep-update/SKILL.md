# Update Dependencies

## When to use

- User says "update deps", "update dependencies", "bump dependencies"
- A dependency vulnerability is found
- repo-sync flags stale lockfiles
- Do NOT use for syncing repos (use skill-repo-sync)

## Steps

### 1. Detect project type

Check what dependency systems are in use:

```sh
ls flake.lock package-lock.json yarn.lock pnpm-lock.yaml Cargo.lock requirements.txt poetry.lock pyproject.toml 2>/dev/null
```

A project may use multiple systems.

### 2. Update by type

Run each command in a separate shell call.

**Python (pip/poetry/uv):**

```sh
# pip
pip install --upgrade -r requirements.txt
pip freeze > requirements.txt

# poetry
poetry update

# uv
uv lock --upgrade
```

**Node.js (npm/yarn/pnpm):**

```sh
# npm
npm update
# or for major versions:
npx npm-check-updates -u
npm install

# yarn
yarn upgrade

# pnpm
pnpm update
```

**Rust (cargo):**

```sh
cargo update
```

### 3. Run tests

Run the project's test suite to verify nothing broke:

```sh
# Python
pytest

# Node
npm test

# Rust
cargo test
```

### 4. Handle breakage

If tests fail after updating:

1. Identify which dependency caused the failure
2. Check the dependency's changelog for breaking changes
3. **If fixable:** apply the fix, include it in the commit
4. **If not easily fixable:** roll back that specific dependency and report: "Updated all dependencies except X — upgrading X from v1 to v2 breaks Y. See changelog: [link]"

### 5. Commit

Commit the lockfile and any adaptation changes:

```
chore(deps): update [scope] dependencies

Updated: package-a 1.0->2.0, package-b 3.1->3.2
[If applicable: adapted X to new API in package-a v2]
```

### 6. Selective updates

If the user specifies a dependency name, update only that package, run tests, and commit.

## Notes

- Shell policy: use a separate shell call for each step — no `&&`, no redirects, no subshells
- Do not force-update past pinned versions without asking
- Do not commit broken lockfiles — always run tests first
- Do not mix large dev-only and prod dependency updates in the same commit

## Cross-references

- Claude Code counterpart: `/dep-update`
