# Plan: Provision homelab SSH key on the runner

## Problem
`setup-runner.yml` makes a Terraform-created VM a working GitHub Actions runner
(vault password, runner binary, service), but it never drops the private key the
runner needs to SSH into the other homelab hosts.

The inventory tells every host to authenticate with:

```
ansible_ssh_private_key_file=~/.ssh/homelab
```

So CI (`update.yml`, `clean.yml`) fails to reach the other hosts on a fresh runner.

## What already exists
- Terraform injects `~/.ssh/homelab.pub` into each VM's `authorized_keys`
  (`ssh_public_keys = [file("~/.ssh/homelab.pub")]`). Every host therefore already
  **trusts** the homelab key — the *inbound/trust* side is done.
- Only the *private* key on the runner (outbound auth) is missing.

## Decision
- Source the **existing** private key from the **Ansible vault**
  (new var `HOMELAB_SSH_PRIVATE_KEY`), mirroring the existing `.ansible_vault_pass`
  drop pattern in `tasks/other/github_runner.yml`.
- No host changes (authorized_keys already handled by Terraform).

## Changes
1. `tasks/other/github_runner.yml`
   - Ensure `/home/{{ username }}/.ssh` exists (0700, owned by `username`).
   - Write `HOMELAB_SSH_PRIVATE_KEY` to `/home/{{ username }}/.ssh/homelab`
     (0600, owned by `username`, `no_log: true`).
   - Place right after the vault-password drop (both are runner credentials).
2. `plays/setup-runner.yml`
   - Add `HOMELAB_SSH_PRIVATE_KEY is defined` to the validation assert.

## Manual step (out of band — secret, cannot edit encrypted vault here)
- `ansible-vault edit vault.yml` (or the secrets repo's `vault.yml`) and add:
  ```yaml
  HOMELAB_SSH_PRIVATE_KEY: |
    -----BEGIN OPENSSH PRIVATE KEY-----
    ...
    -----END OPENSSH PRIVATE KEY-----
  ```
  Store it with a trailing newline (block scalar `|` handles this).

## Verification
- Re-run `ansible-playbook plays/setup-runner.yml -K --ask-vault-pass`.
- On bumblebee: `ls -l ~/.ssh/homelab` → `0600`, owned by the runner user.
- From bumblebee: `ssh -i ~/.ssh/homelab <other-host-user>@192.168.0.101 true`.
- Trigger the Update workflow and confirm it reaches the other hosts.
