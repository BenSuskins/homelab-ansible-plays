# Homelab Ansible Configuration

A comprehensive Ansible-based infrastructure-as-code solution for managing a multi-host homelab environment with automated container deployment, service discovery, and integrated monitoring.

## Overview

This project provides a declarative approach to homelab infrastructure management, featuring unified service definitions that automatically configure reverse proxying (Traefik), health monitoring (Gatus), metrics collection (Prometheus), service dashboards (Homepage), and DNS records (Cloudflare).

### Key Features

- **Declarative Service Management** - Define services once, automatically generate Traefik routes, health checks, metrics scraping, and dashboard entries
- **Automated Container Deployment** - Deploy and update Docker containers across multiple hosts with consistent configuration
- **Integrated Monitoring Stack** - Prometheus metrics, Loki logging, Grafana dashboards, and Gatus health checks
- **Secrets Management** - Ansible Vault for encrypted credential storage
- **Automated Updates** - Renovate integration for tracking and updating container image versions
- **Service Discovery** - Automatic aggregation of services across all hosts for centralized configuration

## Architecture

### Inventory Structure

The inventory organizes hosts into functional groups:
- `mediaserver` - Media streaming and management services
- `docker` - General-purpose containerized applications
- `development` - Development tools and infrastructure
- `monitor` - Observability and monitoring stack

### Service Definition Pattern

Each service is defined using a unified schema in `tasks/docker/*.yml`:

```yaml
- name: Create service entry
  ansible.builtin.set_fact:
    service_entry:
      name: myapp                        # Service identifier
      host: "myapp.example.com"          # Hostname for Traefik routing
      ip: "192.168.0.101"     # Host IP address
      port: 8080                         # Service port
      scheme: http                       # http or https
      secured: true                      # Require authentication
      proxied: true                      # Enable Traefik routing
      exposed: true                      # Create Cloudflare DNS record
      healthcheck: true                  # Enable Gatus monitoring
      healthcheck_path: /health          # Health endpoint
      metrics: true                      # Enable Prometheus scraping
      metrics_path: /metrics             # Metrics endpoint
      homepage: true                     # Show on Homepage dashboard
```

This single definition automatically:
- Configures Traefik reverse proxy routes and middleware
- Sets up Gatus health monitoring with custom endpoints
- Configures Prometheus scrape targets
- Generates Homepage dashboard entries
- Creates Cloudflare CNAME records for external access

### Playbook Workflow

**`setup.yml`** - Initial host provisioning
- Installs base packages and dependencies
- Configures Docker and container runtime
- Sets up monitoring agents (Alloy, cAdvisor)
- Performs system configuration and reboot

**`deploy-containers.yml`** - Container deployment
- Deploys all containers defined in host group variables
- Aggregates service definitions across all hosts
- Generates unified configuration for Traefik, Gatus, Prometheus, and Homepage

**`update.yml`** - Maintenance and updates
- Updates system packages
- Pulls latest container images and restarts services
- Regenerates infrastructure configuration

**`clean.yml`** - System cleanup
- Cleans apt cache and journal logs
- Prunes unused Docker images and volumes

## Getting Started

### Prerequisites

- Ansible 2.12 or higher
- SSH access to target hosts
- Ansible Vault password for secrets

### Initial Setup

1. **Configure SSH Access**

   Copy your SSH key to each host:
   ```bash
   ssh-copy-id -i ~/.ssh/homelab.pub user@host
   ```

2. **Configure Secrets**

   Edit the Ansible Vault to add your credentials:
   ```bash
   ansible-vault edit vault.yml
   ```

3. **Customize Inventory**

   Update `inventory` and `group_vars/` to match your environment:
   - Host IP addresses and groups
   - Domain names and networking
   - Container definitions and configurations

4. **Provision Hosts**

   Run initial setup on all hosts:
   ```bash
   ansible-playbook plays/setup.yml -K --ask-vault-pass
   ```

5. **Deploy Services**

   Deploy containers and generate configuration:
   ```bash
   ansible-playbook plays/deploy-containers.yml -K --ask-vault-pass
   ```

### Common Operations

**Update all systems and containers:**
```bash
ansible-playbook plays/update.yml -K --ask-vault-pass
```

**Clean up disk space:**
```bash
ansible-playbook plays/clean.yml -K --ask-vault-pass
```

**Edit encrypted secrets:**
```bash
ansible-vault edit vault.yml
```

## Adapting for Your Homelab

This project is designed to be forked and customized:

1. **Fork the repository** and update host-specific values
2. **Modify inventory and group_vars** to match your network topology
3. **Select containers** from `tasks/docker/` or add your own following the service definition pattern
4. **Update domain names** in group variables and Traefik configuration
5. **Configure secrets** in `vault.yml` for your services

The modular task structure allows you to enable/disable services by including/excluding them from host group variables.

## Project Structure

```
.
├── inventory                          # Host inventory
├── group_vars/                        # Group-specific variables
│   ├── all.yml                        # Global configuration
│   └── <group>.yml                    # Per-group containers and settings
├── plays/                             # Ansible playbooks
│   ├── setup.yml
│   ├── deploy-containers.yml
│   ├── update.yml
│   └── clean.yml
├── tasks/
│   ├── core/                          # Core setup tasks
│   ├── docker/                        # One file per container service
│   └── other/                         # Utility tasks
├── config/                            # Generated configuration templates
│   ├── traefik/
│   ├── gatus/
│   ├── prometheus/
│   └── homepage/
└── vault.yml                          # Encrypted secrets (Ansible Vault)
```

## Deployed Services

### Bumblebee

| Service | Host | Port | Direct URL | URL | Exposed |
|---------|------|------|------------|-----|---------|
| alloy | 192.168.0.106 | - | - | - | False |

### Development

| Service | Host | Port | Direct URL | URL | Exposed |
|---------|------|------|------------|-----|---------|
| alloy | 192.168.0.105 | - | - | - | False |
| authelia | authelia | 9091 | [authelia:9091](http://authelia:9091) | [authelia.suskins.co.uk](https://authelia.suskins.co.uk) | True |
| authentik | 192.168.0.105 | 9000 | [192.168.0.105:9000](http://192.168.0.105:9000) | [authentik.suskins.co.uk](https://authentik.suskins.co.uk) | True |
| authentik-postgres | 192.168.0.105 | 5432 | [192.168.0.105:5432](http://192.168.0.105:5432) | - | False |
| authentik-redis | 192.168.0.105 | 6379 | [192.168.0.105:6379](http://192.168.0.105:6379) | - | False |
| traefik | 192.168.0.105 | 8080 | [192.168.0.105:8080](http://192.168.0.105:8080) | [traefik.suskins.co.uk](https://traefik.suskins.co.uk) | False |

### Docker

| Service | Host | Port | Direct URL | URL | Exposed |
|---------|------|------|------------|-----|---------|
| adguard-home | 192.168.0.102 | 80 | [192.168.0.102:80](http://192.168.0.102:80) | [adguard-home.suskins.co.uk](https://adguard-home.suskins.co.uk) | False |
| alloy | 192.168.0.102 | - | - | - | False |
| cloudflare-ddns | 192.168.0.102 | - | - | - | False |
| family-hub | 192.168.0.102 | 8081 | [192.168.0.102:8081](http://192.168.0.102:8081) | [hub.suskins.co.uk](https://hub.suskins.co.uk) | False |
| grocy | 192.168.0.102 | 9283 | [192.168.0.102:9283](http://192.168.0.102:9283) | [grocy.suskins.co.uk](https://grocy.suskins.co.uk) | False |
| home | 192.168.0.102 | 3000 | [192.168.0.102:3000](http://192.168.0.102:3000) | [home.suskins.co.uk](https://home.suskins.co.uk) | False |
| mealie | 192.168.0.102 | 9925 | [192.168.0.102:9925](http://192.168.0.102:9925) | [mealie.suskins.co.uk](https://mealie.suskins.co.uk) | False |
| pubgolf | 192.168.0.102 | 3003 | [192.168.0.102:3003](http://192.168.0.102:3003) | [pubgolf.me](https://pubgolf.me) | False |
| pubgolf-backend | 192.168.0.102 | 8080 | [192.168.0.102:8080](http://192.168.0.102:8080) | [api.pubgolf.me](https://api.pubgolf.me) | False |

### Games

| Service | Host | Port | Direct URL | URL | Exposed |
|---------|------|------|------------|-----|---------|
| games | 192.168.0.202 | 80 | [192.168.0.202:80](http://192.168.0.202:80) | [games.suskins.co.uk](https://games.suskins.co.uk) | False |
| minecraft | 192.168.0.125 | 25566 | [192.168.0.125:25566](http://192.168.0.125:25566) | [minecraft.suskins.co.uk](https://minecraft.suskins.co.uk) | False |
| starscream | 192.168.0.125 | 8080 | [192.168.0.125:8080](http://192.168.0.125:8080) | [starscream.suskins.co.uk](https://starscream.suskins.co.uk) | False |

### General

| Service | Host | Port | Direct URL | URL | Exposed |
|---------|------|------|------------|-----|---------|
| homeassistant | 192.168.0.65 | 8123 | [192.168.0.65:8123](http://192.168.0.65:8123) | [homeassistant.suskins.co.uk](https://homeassistant.suskins.co.uk) | False |
| proxmox | 192.168.0.253 | 8006 | [192.168.0.253:8006](http://192.168.0.253:8006) | [pve.suskins.co.uk](https://pve.suskins.co.uk) | False |
| truenas | 192.168.0.100 | 443 | [192.168.0.100:443](http://192.168.0.100:443) | [nas.suskins.co.uk](https://nas.suskins.co.uk) | False |
| unifi | 192.168.0.1 | 443 | [192.168.0.1:443](http://192.168.0.1:443) | [unifi.suskins.co.uk](https://unifi.suskins.co.uk) | False |

### Media

| Service | Host | Port | Direct URL | URL | Exposed |
|---------|------|------|------------|-----|---------|
| alloy | 192.168.0.101 | - | - | - | False |
| bazarr | 192.168.0.101 | 6767 | [192.168.0.101:6767](http://192.168.0.101:6767) | [bazarr.suskins.co.uk](https://bazarr.suskins.co.uk) | False |
| cleanuparr | 192.168.0.101 | 11011 | [192.168.0.101:11011](http://192.168.0.101:11011) | [cleanuparr.suskins.co.uk](https://cleanuparr.suskins.co.uk) | False |
| doplarr | 192.168.0.101 | - | - | - | False |
| flaresolverr | 192.168.0.101 | 8191 | [192.168.0.101:8191](http://192.168.0.101:8191) | - | False |
| gluetun | 192.168.0.101 | 8888 | [192.168.0.101:8888](http://192.168.0.101:8888) | - | False |
| huntarr | 192.168.0.101 | 9705 | [192.168.0.101:9705](http://192.168.0.101:9705) | [huntarr.suskins.co.uk](https://huntarr.suskins.co.uk) | False |
| metube | 192.168.0.101 | 8081 | [192.168.0.101:8081](http://192.168.0.101:8081) | [metube.suskins.co.uk](https://metube.suskins.co.uk) | False |
| openbooks | 192.168.0.101 | 8080 | [192.168.0.101:8080](http://192.168.0.101:8080) | [openbooks.suskins.co.uk](https://openbooks.suskins.co.uk) | False |
| overseerr | 192.168.0.101 | 5055 | [192.168.0.101:5055](http://192.168.0.101:5055) | [overseerr.suskins.co.uk](https://overseerr.suskins.co.uk) | False |
| plex | 192.168.0.101 | 32400 | [192.168.0.101:32400](http://192.168.0.101:32400) | [plex.suskins.co.uk](https://plex.suskins.co.uk) | False |
| profilarr | 192.168.0.101 | 6868 | [192.168.0.101:6868](http://192.168.0.101:6868) | [profilarr.suskins.co.uk](https://profilarr.suskins.co.uk) | False |
| prowlarr | 192.168.0.101 | 9696 | [192.168.0.101:9696](http://192.168.0.101:9696) | [prowlarr.suskins.co.uk](https://prowlarr.suskins.co.uk) | False |
| qbittorrent | 192.168.0.101 | 9091 | [192.168.0.101:9091](http://192.168.0.101:9091) | [qbittorrent.suskins.co.uk](https://qbittorrent.suskins.co.uk) | False |
| radarr | 192.168.0.101 | 7878 | [192.168.0.101:7878](http://192.168.0.101:7878) | [radarr.suskins.co.uk](https://radarr.suskins.co.uk) | False |
| shelfmark | 192.168.0.101 | 8084 | [192.168.0.101:8084](http://192.168.0.101:8084) | [shelfmark.suskins.co.uk](https://shelfmark.suskins.co.uk) | False |
| sonarr | 192.168.0.101 | 8989 | [192.168.0.101:8989](http://192.168.0.101:8989) | [sonarr.suskins.co.uk](https://sonarr.suskins.co.uk) | False |

### Monitoring

| Service | Host | Port | Direct URL | URL | Exposed |
|---------|------|------|------------|-----|---------|
| alloy | 192.168.0.104 | - | - | - | False |
| gatus | 192.168.0.104 | 8080 | [192.168.0.104:8080](http://192.168.0.104:8080) | [gatus.suskins.co.uk](https://gatus.suskins.co.uk) | False |
| grafana | 192.168.0.104 | 3000 | [192.168.0.104:3000](http://192.168.0.104:3000) | [grafana.suskins.co.uk](https://grafana.suskins.co.uk) | False |
| graphite-exporter | 192.168.0.104 | 9108 | [192.168.0.104:9108](http://192.168.0.104:9108) | - | False |
| loki | 192.168.0.104 | 3100 | [192.168.0.104:3100](http://192.168.0.104:3100) | - | False |
| prometheus | 192.168.0.104 | 9090 | [192.168.0.104:9090](http://192.168.0.104:9090) | [prometheus.suskins.co.uk](https://prometheus.suskins.co.uk) | False |

## Acknowledgments

- [r/homelab](http://reddit.com/r/homelab) and [r/selfhosted](http://reddit.com/r/selfhosted) communities
- [rishavnandi/ansible_homelab](https://github.com/rishavnandi/ansible_homelab)
- [mazay/truenas-grafana](https://github.com/mazay/truenas-grafana)

---

*Infrastructure managed with Ansible - Generated 2026-02-12T11:51:27Z*
