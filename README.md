# 🏡 Homelab Ansible Plays

My [Ansible](https://github.com/ansible/ansible) configuration to setup / manage my homelab.

---

## ✨ Features

- 🚀 Automated setup of hosts.
- 🔐 Secrets managed by Ansible Vault.
- 🐳 Deploying and updating containers.
- 📦 Automated docker updates via [Renovate](https://github.com/renovatebot/renovate).
- 🔄 Regular maintenance.
- 🏡 Generate Homepage, Gatus, Prometheus, Traefik and Cloudflare records.

---

# 📦 Prerequisites

Ensure you have the following installed on your control machine:

- Ansible (minimum version 2.12)
- SSH access to all target hosts.
- Ansible Vault set up for secrets management.

## 🔒 Ansible Vault set up for secrets management

Edit Vault:

```bash
ansible-vault edit vault.yml
```

Copy vault to secrets:

```bash
ansible-vault edit vault.yml
cp vault.yml ../secrets
```

## 🔑 SSH access to all target hosts

Copy SSH key to host:

```bash
ssh-copy-id -i ~/.ssh/homelab.pub <user>@<host>
```

---

# 📚 Playbooks

## ⚙️ Setup

Initialises hosts with dependencies, docker, qemu, alloy, cadvisor then reboots.

```bash
ansible-playbook plays/setup.yml -K --ask-vault-pass
```

## 🐳 Deploy Containers

Deploys the hosts containers.

```bash
ansible-playbook plays/deploy-containers.yml -K --ask-vault-pass
```

## ⬆️ Update

Update hosts and redeploy containers.

```bash
ansible-playbook plays/update.yml -K --ask-vault-pass
```

## 🧹 Cleanup system

Cleanup docker and system files.

```bash
ansible-playbook plays/clean.yml -K --ask-vault-pass
```

---

# Services

## Development

| Service | Host | Port | Direct URL | URL | Exposed |
|---------|------|------|--------------|-----|---------|
| alloy | 192.168.0.105 | - | - | - | False |
| authentik | 192.168.0.105 | 9000 | [authentik.suskins.co.uk:9000](http://authentik.suskins.co.uk:9000) | [authentik.suskins.co.uk](https://authentik.suskins.co.uk) | True |
| authentik-postgres | 192.168.0.105 | 5432 | [authentik-postgres.suskins.co.uk:5432](http://authentik-postgres.suskins.co.uk:5432) | - | False |
| authentik-redis | 192.168.0.105 | 6379 | [authentik-redis.suskins.co.uk:6379](http://authentik-redis.suskins.co.uk:6379) | - | False |
| traefik | 192.168.0.105 | 8080 | [traefik.suskins.co.uk:8080](http://traefik.suskins.co.uk:8080) | [traefik.suskins.co.uk](https://traefik.suskins.co.uk) | False |

## Docker

| Service | Host | Port | Direct URL | URL | Exposed |
|---------|------|------|--------------|-----|---------|
| adguard-home | 192.168.0.102 | 80 | [adguard-home.suskins.co.uk:80](http://adguard-home.suskins.co.uk:80) | [adguard-home.suskins.co.uk](https://adguard-home.suskins.co.uk) | False |
| alloy | 192.168.0.102 | - | - | - | False |
| cloudflare-ddns | 192.168.0.102 | - | - | - | False |
| grocy | 192.168.0.102 | 9283 | [grocy.suskins.co.uk:9283](http://grocy.suskins.co.uk:9283) | [grocy.suskins.co.uk](https://grocy.suskins.co.uk) | False |
| mealie | 192.168.0.102 | 9925 | [mealie.suskins.co.uk:9925](http://mealie.suskins.co.uk:9925) | [mealie.suskins.co.uk](https://mealie.suskins.co.uk) | False |
| pubgolf | 192.168.0.102 | 3003 | [pubgolf.me:3003](http://pubgolf.me:3003) | [pubgolf.me](https://pubgolf.me) | False |
| pubgolf-backend | 192.168.0.102 | 8080 | [api.pubgolf.me:8080](http://api.pubgolf.me:8080) | [api.pubgolf.me](https://api.pubgolf.me) | False |
| pubgolf-postgres | 192.168.0.102 | 5433 | [pubgolf-postgres.suskins.co.uk:5433](http://pubgolf-postgres.suskins.co.uk:5433) | - | False |

## Docker Server

| Service | Host | Port | Direct URL | URL | Exposed |
|---------|------|------|--------------|-----|---------|
| home | 192.168.0.102 | 3000 | [home.suskins.co.uk:3000](http://home.suskins.co.uk:3000) | [home.suskins.co.uk](https://home.suskins.co.uk) | False |

## Games

| Service | Host | Port | Direct URL | URL | Exposed |
|---------|------|------|--------------|-----|---------|
| games | 192.168.0.202 | 80 | [games.suskins.co.uk:80](http://games.suskins.co.uk:80) | [games.suskins.co.uk](https://games.suskins.co.uk) | False |
| minecraft | 192.168.0.125 | 25566 | [minecraft.suskins.co.uk:25566](http://minecraft.suskins.co.uk:25566) | [minecraft.suskins.co.uk](https://minecraft.suskins.co.uk) | False |
| starscream | 192.168.0.125 | 8080 | [starscream.suskins.co.uk:8080](http://starscream.suskins.co.uk:8080) | [starscream.suskins.co.uk](https://starscream.suskins.co.uk) | False |

## General

| Service | Host | Port | Direct URL | URL | Exposed |
|---------|------|------|--------------|-----|---------|
| homeassistant | 192.168.0.65 | 8123 | [homeassistant.suskins.co.uk:8123](http://homeassistant.suskins.co.uk:8123) | [homeassistant.suskins.co.uk](https://homeassistant.suskins.co.uk) | False |
| proxmox | 192.168.0.253 | 8006 | [pve.suskins.co.uk:8006](http://pve.suskins.co.uk:8006) | [pve.suskins.co.uk](https://pve.suskins.co.uk) | False |
| truenas | 192.168.0.100 | 443 | [nas.suskins.co.uk:443](http://nas.suskins.co.uk:443) | [nas.suskins.co.uk](https://nas.suskins.co.uk) | False |
| unifi | 192.168.0.1 | 443 | [unifi.suskins.co.uk:443](http://unifi.suskins.co.uk:443) | [unifi.suskins.co.uk](https://unifi.suskins.co.uk) | False |

## Media

| Service | Host | Port | Direct URL | URL | Exposed |
|---------|------|------|--------------|-----|---------|
| alloy | 192.168.0.101 | - | - | - | False |
| bazarr | 192.168.0.101 | 6767 | [bazarr.suskins.co.uk:6767](http://bazarr.suskins.co.uk:6767) | [bazarr.suskins.co.uk](https://bazarr.suskins.co.uk) | False |
| doplarr | 192.168.0.101 | - | - | - | False |
| gluetun | 192.168.0.101 | 8888 | [gluetun.suskins.co.uk:8888](http://gluetun.suskins.co.uk:8888) | - | False |
| metube | 192.168.0.101 | 8081 | [metube.suskins.co.uk:8081](http://metube.suskins.co.uk:8081) | [metube.suskins.co.uk](https://metube.suskins.co.uk) | False |
| openbooks | 192.168.0.101 | 8080 | [openbooks.suskins.co.uk:8080](http://openbooks.suskins.co.uk:8080) | [openbooks.suskins.co.uk](https://openbooks.suskins.co.uk) | False |
| overseerr | 192.168.0.101 | 5055 | [overseerr.suskins.co.uk:5055](http://overseerr.suskins.co.uk:5055) | [overseerr.suskins.co.uk](https://overseerr.suskins.co.uk) | False |
| plex | 192.168.0.101 | 32400 | [plex.suskins.co.uk:32400](http://plex.suskins.co.uk:32400) | [plex.suskins.co.uk](https://plex.suskins.co.uk) | False |
| profilarr | 192.168.0.101 | 6868 | [profilarr.suskins.co.uk:6868](http://profilarr.suskins.co.uk:6868) | [profilarr.suskins.co.uk](https://profilarr.suskins.co.uk) | False |
| prowlarr | 192.168.0.101 | 9696 | [prowlarr.suskins.co.uk:9696](http://prowlarr.suskins.co.uk:9696) | [prowlarr.suskins.co.uk](https://prowlarr.suskins.co.uk) | False |
| qbittorrent | 192.168.0.101 | 9091 | [qbittorrent.suskins.co.uk:9091](http://qbittorrent.suskins.co.uk:9091) | [qbittorrent.suskins.co.uk](https://qbittorrent.suskins.co.uk) | False |
| radarr | 192.168.0.101 | 7878 | [radarr.suskins.co.uk:7878](http://radarr.suskins.co.uk:7878) | [radarr.suskins.co.uk](https://radarr.suskins.co.uk) | False |
| sonarr | 192.168.0.101 | 8989 | [sonarr.suskins.co.uk:8989](http://sonarr.suskins.co.uk:8989) | [sonarr.suskins.co.uk](https://sonarr.suskins.co.uk) | False |

## Monitoring

| Service | Host | Port | Direct URL | URL | Exposed |
|---------|------|------|--------------|-----|---------|
| alloy | 192.168.0.104 | - | - | - | False |
| grafana | 192.168.0.104 | 3000 | [grafana.suskins.co.uk:3000](http://grafana.suskins.co.uk:3000) | [grafana.suskins.co.uk](https://grafana.suskins.co.uk) | False |
| graphite-exporter | 192.168.0.104 | 9108 | [graphite-exporter.suskins.co.uk:9108](http://graphite-exporter.suskins.co.uk:9108) | - | False |
| loki | 192.168.0.104 | 3100 | [loki.suskins.co.uk:3100](http://loki.suskins.co.uk:3100) | - | False |
| prometheus | 192.168.0.104 | 9090 | [prometheus.suskins.co.uk:9090](http://prometheus.suskins.co.uk:9090) | [prometheus.suskins.co.uk](https://prometheus.suskins.co.uk) | False |

## Monitoring Server

| Service | Host | Port | Direct URL | URL | Exposed |
|---------|------|------|--------------|-----|---------|
| gatus | 192.168.0.104 | 8080 | [gatus.suskins.co.uk:8080](http://gatus.suskins.co.uk:8080) | [gatus.suskins.co.uk](https://gatus.suskins.co.uk) | False |

---

# 🙏 Acknowledgments

- [Homelab Subreddit](http://reddit.com/r/homelab)
- [Selfhosted Subreddit](http://reddit.com/r/selfhosted)
- [rishavnandi - Ansible Homelab](https://github.com/rishavnandi/ansible_homelab)
- [mazay - Truenas Grafana](https://github.com/mazay/truenas-grafana)

---

*Generated by Ansible on 2025-12-25T16:05:13Z*
