# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Ansible configuration for managing a homelab infrastructure with multiple servers running Docker containers. The setup uses Ansible Vault for secrets management and Renovate for automated Docker image updates.

## Common Commands

All playbooks require sudo password (`-K`) and vault password (`--ask-vault-pass`):

```bash
# Initial host setup (installs dependencies, docker, reboots)
ansible-playbook plays/setup.yml -K --ask-vault-pass

# Deploy containers to all hosts
ansible-playbook plays/deploy-containers.yml -K --ask-vault-pass

# Update packages and containers (runs automatically on push to main)
ansible-playbook plays/update.yml -K --ask-vault-pass

# Cleanup docker and system files
ansible-playbook plays/clean.yml -K --ask-vault-pass

# Edit vault secrets
ansible-vault edit vault.yml
```

For CI/CD, vault password is read from `~/.ansible_vault_pass` file.

## Architecture

### Inventory Structure
- `inventory` - Defines 4 host groups: `mediaserver`, `docker`, `development`, `monitor`
- `group_vars/all.yml` - Global variables (timezone, packages, static services)
- `group_vars/<group>.yml` - Per-host variables including `base_dir` and `containers` list

### Playbooks (`plays/`)
- `setup.yml` - One-time host initialization (base packages, Docker install)
- `deploy-containers.yml` - Deploys containers defined in each host's `containers` variable
- `update.yml` - Full update cycle (apt, containers, special services like traefik/gatus/homepage)
- `clean.yml` - System cleanup (apt cache, journal logs, docker prune)

### Task Organization
- `tasks/core/` - Base setup tasks (base.yml, docker.yml)
- `tasks/docker/` - One file per container (e.g., plex.yml, grafana.yml)
- `tasks/other/` - Misc tasks (firewall.yml, cloudflare_cnames.yml)

### Container Task Pattern

Each container task file in `tasks/docker/` follows a standard pattern:
1. Create directory with permissions
2. Create container using `community.docker.docker_container`
3. Define service entry with metadata (name, ip, port, scheme, etc.)
4. Append to `docker_services` list for Homepage integration

Example structure:
```yaml
- name: Create directory
- name: Create container
- name: Define service entry (set_fact with name, ip, port, etc.)
- name: Append to docker_services
```

### Service Discovery

The `docker_services` list is aggregated across all hosts and used to:
- Auto-generate Homepage entries via `config/homepage/services.yaml.j2`
- Configure Traefik routing (development host)
- Set up Gatus monitoring (monitor host)
- Update Prometheus scrape configs

### Docker Image Updates

Renovate monitors `tasks/docker/*.yml` for Docker image versions and creates PRs for updates. Images are pinned to specific versions (not `latest`).
