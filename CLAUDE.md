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

### Service Entry Variables

Each service entry is a unified definition that controls Homepage, Traefik, Gatus, Prometheus, and Cloudflare. Variables are defined in the `set_fact` task for each container.

#### Required Fields

| Variable | Type | Description |
|----------|------|-------------|
| `name` | string | Service identifier, used for container name |
| `host` | string | Full hostname for Traefik routing (e.g., `myapp.suskins.co.uk`) |
| `ip` | string | Host IP address, typically `{{ inventory_hostname }}` |
| `friendly_name` | string | Group name for Homepage display, typically `{{ friendly_name }}` |
| `port` | integer | Primary service port |
| `scheme` | string | Protocol: `http` or `https` |
| `secured` | boolean | Requires Authentik authentication via Traefik middleware |

#### Optional Fields

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `homepage` | boolean | `false` | Show on Homepage dashboard |
| `proxied` | boolean | `true` | Include in Traefik routing (set `false` for internal/metrics-only services) |
| `middleware` | string | none | Additional Traefik middleware (e.g., `unifi-headers`) |

#### Cloudflare DNS

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `exposed` | boolean | `false` | Create Cloudflare CNAME record for external access |

#### Gatus Health Monitoring

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `healthcheck_path` | string | none | Custom health endpoint path (e.g., `/health`, `/api/status`) |

#### Prometheus Metrics

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `metrics_enabled` | boolean | `false` | Enable Prometheus scraping for this service |
| `metrics_port` | integer | `port` | Port exposing metrics (if different from service port) |
| `metrics_path` | string | `/metrics` | Metrics endpoint path |

#### Example Service Entry

```yaml
- name: MYAPP - Define service entry
  ansible.builtin.set_fact:
    myapp_entry:
      name: myapp
      host: myapp.suskins.co.uk
      ip: "{{ inventory_hostname }}"
      friendly_name: "{{ friendly_name }}"
      port: 8080
      scheme: http
      secured: true
      homepage: true                     # Optional: show on Homepage
      exposed: true                      # Optional: create DNS record
      healthcheck_path: /health          # Optional: Gatus health check
      metrics_enabled: true              # Optional: Prometheus scraping
      metrics_port: 9090                 # Optional: if metrics on different port
      metrics_path: /actuator/prometheus # Optional: custom metrics path

- name: MYAPP - Append to docker_services
  ansible.builtin.set_fact:
    docker_services: "{{ docker_services + [myapp_entry] }}"
```

### Service Discovery

The `docker_services` list is aggregated across all hosts via `tasks/core/aggregate_services.yml` and used to:
- Auto-generate Homepage entries via `config/homepage/services.yaml.j2`
- Configure Traefik routing via `config/traefik/dynamic/http.yml.j2`
- Set up Gatus monitoring via `config/gatus/config.yaml.j2`
- Generate Prometheus scrape configs via `config/prometheus/config.yml.j2`
- Create Cloudflare DNS records via `tasks/other/cloudflare_cnames.yml`

### Docker Image Updates

Renovate monitors `tasks/docker/*.yml` for Docker image versions and creates PRs for updates. Images are pinned to specific versions (not `latest`).
