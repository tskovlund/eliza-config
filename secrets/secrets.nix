# Agenix recipients — defines which public keys can decrypt each secret.
#
# The age key is portable: the same key is copied to every machine.
# All secrets are encrypted to this single key.
#
# How to add a new secret:
#   1. Add an entry below mapping the .age file to its recipients
#   2. Encrypt: age -r <pubkey> -o secrets/<name>.age <plaintext-file>
#      Or interactively: cd secrets && agenix -e <name>.age
#   3. Declare age.secrets.<name> in nix-config's hosts/miles/zeroclaw.nix
#
# How to re-encrypt after changing recipients:
#   cd secrets && agenix -r

let
  thomas = "age15j2yd89h8ahm93g2um8206atnfcl90hk7q062nt63xqrz57lspmsvmyzle";
in
{
  # Skills are plaintext in skills/<name>/SKILL.md — no encryption needed.
  # Only workspace files (personal data) remain encrypted.

  # Workspace
  "workspace-AGENTS.age".publicKeys = [ thomas ];
  "workspace-IDENTITY.age".publicKeys = [ thomas ];
  "workspace-SOUL.age".publicKeys = [ thomas ];
  "workspace-TOOLS.age".publicKeys = [ thomas ];
  "workspace-USER.age".publicKeys = [ thomas ];
}
