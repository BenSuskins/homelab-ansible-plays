# homelab-ansible-plays

> Ansible-driven infrastructure-as-code for a multi-host homelab.


## Diagram

![Diagram](diagram.png?raw=true "Diagram")


## Overview

Declarative homelab management: containers are defined once per host group
and the playbooks automatically configure Traefik routes, Gatus health
checks, Prometheus scraping, Homepage dashboard entries, and Cloudflare DNS
records. Secrets live in Ansible Vault; Docker image versions are tracked by
Renovate.

## Features

- **Unified service definition** — one YAML block per container drives Traefik, Gatus, Prometheus, Homepage, and DNS
- **Per-group hosts** — `mediaserver`, `docker`, `development`, `monitor`
- **Vault-encrypted secrets** committed alongside the playbooks
- **Renovate-tracked image versions** (pinned, never `:latest`)
- **Generated config templates** for Traefik, Gatus, Prometheus, and Homepage

## Tech Stack

- Ansible 2.12+
- `community.docker.docker_container` for container lifecycle
- Ansible Vault for secrets
- Renovate for image updates
- Terraform (in `terraform/`) for Cloudflare DNS

## Project Structure

```
.
├── inventory                # Host inventory (4 groups)
├── group_vars/              # Global + per-group variables (incl. `containers` lists)
├── plays/                   # Ansible playbooks (setup, deploy-containers, update, clean)
├── tasks/
│   ├── core/                # base.yml, docker.yml
│   ├── docker/              # one file per container (plex.yml, grafana.yml, ...)
│   └── other/               # firewall.yml, etc.
├── config/                  # Traefik, Gatus, Prometheus, Homepage templates
├── terraform/               # Cloudflare DNS records
└── vault.yml                # Encrypted secrets
```

## Getting Started

### Prerequisites

- Ansible 2.12 or newer (control node)
- SSH key access to every target host (`ssh-copy-id`)
- Ansible Vault password (interactive or `~/.ansible_vault_pass` for CI)

### Setup

```bash
git clone git@github.com:bensuskins/homelab-ansible-plays.git
cd homelab-ansible-plays

# Update inventory and group_vars/ to match your hosts and domain
vim inventory group_vars/all.yml

# Provision base packages and Docker
ansible-playbook plays/setup.yml -K --ask-vault-pass

# Deploy all containers + generate Traefik/Gatus/Prometheus/Homepage configs
ansible-playbook plays/deploy-containers.yml -K --ask-vault-pass
```

Verify: visit the Homepage dashboard hostname configured in `group_vars/all.yml` — every container with `homepage: true` should appear.

## Commands

All playbooks require sudo (`-K`) and vault (`--ask-vault-pass`).

| Command | Purpose |
|---------|---------|
| `ansible-playbook plays/setup.yml -K --ask-vault-pass` | One-time host initialisation (base packages, Docker) |
| `ansible-playbook plays/deploy-containers.yml -K --ask-vault-pass` | Deploy/refresh all containers |
| `ansible-playbook plays/update.yml -K --ask-vault-pass` | Full update cycle (apt + containers + Traefik/Gatus/Homepage configs); runs on push to `main` |
| `ansible-playbook plays/clean.yml -K --ask-vault-pass` | apt cache, journal logs, Docker prune |
| `ansible-vault edit vault.yml` | Edit encrypted secrets |

CI reads the vault password from `~/.ansible_vault_pass`.

## Architecture

See [ARCHITECTURE.md](ARCHITECTURE.md) for the system diagram, the unified
service-entry schema, and the full list of deployed services.

## Acknowledgments

- [r/homelab](https://reddit.com/r/homelab) and [r/selfhosted](https://reddit.com/r/selfhosted) communities
- [rishavnandi/ansible_homelab](https://github.com/rishavnandi/ansible_homelab)
- [mazay/truenas-grafana](https://github.com/mazay/truenas-grafana)

## Security

See [SECURITY.md](SECURITY.md) for vulnerability reporting.

## License

[MIT](../LICENSE)
