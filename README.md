# eliza-config

Configuration for [Eliza](https://github.com/zeroclaw-labs/zeroclaw), a personal AI assistant running on the `miles` VPS.

## What's in here

Skills and workspace identity files, all [agenix](https://github.com/ryantm/agenix)-encrypted:

- **`secrets/skill-*.age`** — Skill library (instruction sets Eliza loads contextually)
- **`secrets/workspace-*.age`** — Identity and personality files (SOUL, IDENTITY, AGENTS, TOOLS, USER)
- **`secrets/secrets.nix`** — Age recipient definitions

## Deployment

This repo is a non-flake input to [nix-config](https://github.com/tskovlund/nix-config). Encrypted files are decrypted by the NixOS agenix module and deployed to miles via:

```sh
make deploy-miles
```

## Editing a secret

```sh
agenix -e secrets/skill-delegation.age   # opens in $EDITOR, re-encrypts on save
```

## Adding a skill

1. Add entry to `secrets/secrets.nix`
2. Encrypt: `agenix -e secrets/skill-<name>.age`
3. Declare `age.secrets` in nix-config's `hosts/miles/zeroclaw.nix`
4. Commit, push, deploy

## Development

```sh
nix develop   # or: direnv allow
```

## Author

Thomas Skovlund Hansen — [thomas@skovlund.dev](mailto:thomas@skovlund.dev)
