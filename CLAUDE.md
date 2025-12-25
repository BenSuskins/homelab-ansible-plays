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
- `group_vars/all.yml` - Global variables (timezone, packages, static services, core_container_definitions)
- `group_vars/<group>.yml` - Per-host variables including `base_dir`, `containers` list, and `container_definitions`

### Playbooks (`plays/`)
- `setup.yml` - One-time host initialization (uses common, docker, firewall roles)
- `deploy-containers.yml` - Deploys containers using the container role
- `update.yml` - Full update cycle (apt, containers, special services)
- `clean.yml` - System cleanup (apt cache, journal logs, docker prune)

### Role Organization (`roles/`)

#### Infrastructure Roles
- `common/` - Base system setup (packages, directories, NAS mount)
- `docker/` - Docker installation and network setup
- `firewall/` - UFW firewall configuration

#### Container Roles
- `container/` - Generic container deployment role (replaces individual task files)
- `service_discovery/` - Aggregates docker_services across all hosts

#### Special Container Roles (require aggregated services)
- `traefik/` - Reverse proxy with dynamic routing config
- `prometheus/` - Metrics collection with dynamic scrape config
- `gatus/` - Health monitoring with dynamic endpoints
- `homepage/` - Dashboard with dynamic service list
- `cloudflare_dns/` - DNS CNAME management

### Container Definition Pattern

Containers are defined as data in `group_vars/<host>.yml` using `container_definitions`:

```yaml
container_definitions:
  myapp:
    container_name: myapp
    container_image: org/image:version
    container_dirs:
      - "{{ base_dir }}/myapp"
    container_ports:
      - "8080:8080"
    container_volumes:
      - "{{ base_dir }}/myapp:/config"
    container_env:
      PUID: "{{ puid | string }}"
      TZ: "{{ timezone }}"
    service_entry:
      name: myapp
      host: "myapp.{{ domain }}"
      ip: "{{ inventory_hostname }}"
      friendly_name: "{{ friendly_name }}"
      port: 8080
      scheme: http
      # ... other service metadata
```

The `container` role handles:
1. Creating directories with permissions
2. Creating config files (if `container_config_files` is defined)
3. Creating the Docker container
4. Registering the service to `docker_services` list

### Service Entry Variables

Each service entry is a unified definition that controls Homepage, Traefik, Gatus, Prometheus, and Cloudflare. Variables are defined in the `set_fact` task for each container.

#### Required Fields

| Variable | Type | Description |
|----------|------|-------------|
| `name` | string | Service identifier, used for container name |
| `ip` | string | Host IP address, typically `{{ inventory_hostname }}` |
| `friendly_name` | string | Group name for Homepage display, typically `{{ friendly_name }}` |

#### Optional Fields

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `host` | string | none | Full hostname for Traefik routing (e.g., `myapp.suskins.co.uk`) |
| `port` | integer | none | Primary service port |
| `scheme` | string | none | Protocol: `http` or `https` |
| `secured` | boolean | `false` | Requires Authentik authentication via Traefik middleware |
| `homepage` | boolean | `false` | Show on Homepage dashboard |
| `proxied` | boolean | `false` | Include in Traefik routing |
| `middleware` | string | none | Additional Traefik middleware (e.g., `unifi-headers`) |

#### Cloudflare DNS

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `exposed` | boolean | `false` | Create Cloudflare CNAME record for external access |

#### Gatus Health Monitoring

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `healthcheck` | boolean | `false` | Enable Gatus health monitoring for this service |
| `healthcheck_path` | string | none | Custom health endpoint path (e.g., `/health`, `/api/status`) |

#### Prometheus Metrics

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `metrics` | boolean | `false` | Enable Prometheus scraping for this service |
| `metrics_port` | integer | `port` | Port exposing metrics (if different from service port) |
| `metrics_path` | string | none | Metrics endpoint path (Prometheus assumes `/metrics` if not specified) |

#### Example Service Entry

```yaml
- name: MYAPP - Define service entry
  ansible.builtin.set_fact:
    myapp_entry:
      name: myapp
      host: "myapp.{{ domain }}"
      ip: "{{ inventory_hostname }}"
      friendly_name: "{{ friendly_name }}"
      port: 8080
      scheme: http
      secured: true
      healthcheck: true                  # Optional: enable Gatus monitoring
      healthcheck_path: /health          # Optional: custom health endpoint
      homepage: true                     # Optional: show on Homepage
      proxied: true                      # Optional: include in Traefik routing
      exposed: true                      # Optional: create DNS record
      metrics: true              # Optional: Prometheus scraping
      metrics_port: 9090                 # Optional: if metrics on different port
      metrics_path: /actuator/prometheus # Optional: custom metrics path

- name: MYAPP - Append to docker_services
  ansible.builtin.set_fact:
    docker_services: "{{ docker_services + [myapp_entry] }}"
```

### Service Discovery

The `docker_services` list is aggregated across all hosts via the `service_discovery` role and used by special container roles to:
- Auto-generate Homepage entries via `roles/homepage/templates/services.yaml.j2`
- Configure Traefik routing via `roles/traefik/templates/http.yml.j2`
- Set up Gatus monitoring via `roles/gatus/templates/config.yaml.j2`
- Generate Prometheus scrape configs via `roles/prometheus/templates/config.yml.j2`
- Create Cloudflare DNS records via the `cloudflare_dns` role

### Docker Image Updates

Renovate monitors `group_vars/*.yml` for Docker image versions in `container_definitions` and creates PRs for updates. Images are pinned to specific versions (not `latest`).

### Adding a New Container

1. Add the container name to the `containers` list in the appropriate `group_vars/<host>.yml`
2. Add the container definition to `container_definitions` in the same file
3. Run `ansible-playbook plays/deploy-containers.yml -K --ask-vault-pass`

Example:
```yaml
containers:
  - myapp  # Add to list

container_definitions:
  myapp:
    container_name: myapp
    container_image: org/image:1.0.0
    container_dirs:
      - "{{ base_dir }}/myapp"
    container_ports:
      - "8080:8080"
    container_volumes:
      - "{{ base_dir }}/myapp:/config"
    container_env:
      TZ: "{{ timezone }}"
    service_entry:
      name: myapp
      host: "myapp.{{ domain }}"
      ip: "{{ inventory_hostname }}"
      friendly_name: "{{ friendly_name }}"
      port: 8080
      scheme: http
      homepage: true
      proxied: true
```
