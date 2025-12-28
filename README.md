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
      ip: "{{ inventory_hostname }}"     # Host IP address
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

## Documentation

See [CLAUDE.md](CLAUDE.md) for detailed documentation on:
- Service definition variables
- Container task patterns
- Configuration template system
- Automated update workflow

## Acknowledgments

- [r/homelab](http://reddit.com/r/homelab) and [r/selfhosted](http://reddit.com/r/selfhosted) communities
- [rishavnandi/ansible_homelab](https://github.com/rishavnandi/ansible_homelab)
- [mazay/truenas-grafana](https://github.com/mazay/truenas-grafana)

---

*Infrastructure managed with Ansible*
