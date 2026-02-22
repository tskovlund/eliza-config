# eliza-config

Configuration for [Eliza](https://github.com/zeroclaw-labs/zeroclaw), a personal AI assistant running on the `miles` VPS.

## What's in here

- **`workspace/`** — Identity and personality files (SOUL.md, IDENTITY.md, etc.)
- **`skills/`** — Skill library (instruction sets Eliza loads contextually)

## Deployment

This repo is a non-flake input to [nix-config](https://github.com/tskovlund/nix-config). Skills and workspace files are deployed to miles via:

```sh
make deploy-miles
```

Deployed files are **read-only** on the VPS. To modify, edit here and redeploy.

## Adding a skill

1. Create `skills/<skill-name>/SKILL.md`
2. Follow the format in [CLAUDE.md](CLAUDE.md)
3. Commit and push
4. Deploy with `make deploy-miles`

## Development

```sh
nix develop   # or: direnv allow
```
