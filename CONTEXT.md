# Homelab Ansible Plays

Ansible-based configuration management for a self-hosted homelab: Docker containers spread across several hosts, a unified service-discovery mechanism that drives Homepage/Traefik/Gatus/Prometheus, and three independent Terraform roots for Proxmox, Cloudflare, and Tailscale.

## Language

### Hosts & Inventory

**Host Group**:
An Ansible inventory group (`mediaserver`, `docker`, `development`, `monitor`, `bumblebee`, `ai`) that maps to exactly one physical or virtual machine, with its own `group_vars/<group>.yml` defining that host's `base_dir` and `containers`.
_Avoid_: Server, node

**Friendly Name**:
The human-readable label for a host (e.g. "Media", "Docker", "Monitoring") used to group that host's services together on the Homepage dashboard. Set as `friendly_name` in the `inventory` file — distinct from the host's IP or Ansible user.
_Avoid_: Display name, label

**Base Dir**:
The root directory on a host (e.g. `/home/docker/server-docker`) under which every container on that host stores its config and data via bind mounts. Defined once per host in `group_vars/<group>.yml`.
_Avoid_: Data dir, install dir

**Domain**:
The DNS zone (`suskins.co.uk`) that all service hostnames are built under, e.g. `myapp.{{ domain }}`. Defined once in `group_vars/all.yml`.

### Service Definition

**Service Entry**:
The single `set_fact` object a Container Task defines to describe how that container is exposed. One Service Entry drives four systems at once — Homepage listing, Traefik routing, Gatus health monitoring, Prometheus scraping — with fields like `homepage`, `proxied`, `healthcheck`, and `metrics` opting into each independently.
_Avoid_: Service definition, service config

**Container Task**:
The standard task file in `tasks/docker/<name>.yml` that creates one container. Always follows the same shape: create directory, pre-pull the image, create the container with `pull: false`, define the container's Service Entry, append it to `docker_services`.
_Avoid_: Container role, container playbook

**`docker_services`**:
The list of every Service Entry across all hosts, aggregated by `tasks/core/aggregate_services.yml` and consumed by the Jinja templates that generate Homepage, Traefik, Gatus, and Prometheus config.
_Avoid_: Service list, service registry

**Secured**:
A Service Entry flag meaning the service's Traefik route requires Authelia authentication. Distinct from `proxied`, which only controls whether the service is routed through Traefik at all.

### Infrastructure as Code

**Terraform Root**:
One of three independent Terraform state trees (`terraform/proxmox`, `terraform/cloudflare`, `terraform/tailscale`), each with its own R2 state key and its own plan/apply stage in the `terraform.yml` workflow matrix. They are not layered or dependent on one another.
_Avoid_: Terraform module, stack

**Subnet Router**:
The Tailscale node running on the `docker` host that advertises the home LAN CIDR (`192.168.0.0/24`) to the tailnet, so any tailnet device can reach homelab services without inbound port forwarding.
_Avoid_: VPN gateway, relay
