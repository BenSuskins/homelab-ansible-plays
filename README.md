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
| authentik | 192.168.0.105 | 9000 | [192.168.0.105:9000](http://192.168.0.105:9000) | [authentik.suskins.co.uk](https://authentik.suskins.co.uk) | True |
| authentik-postgres | 192.168.0.105 | 5432 | [192.168.0.105:5432](http://192.168.0.105:5432) | - | False |
| authentik-redis | 192.168.0.105 | 6379 | [192.168.0.105:6379](http://192.168.0.105:6379) | - | False |
| traefik | 192.168.0.105 | 8080 | [192.168.0.105:8080](http://192.168.0.105:8080) | [traefik.suskins.co.uk](https://traefik.suskins.co.uk) | False |

## Docker

| Service | Host | Port | Direct URL | URL | Exposed |
|---------|------|------|--------------|-----|---------|
| adguard-home | 192.168.0.102 | 80 | [192.168.0.102:80](http://192.168.0.102:80) | [adguard-home.suskins.co.uk](https://adguard-home.suskins.co.uk) | False |
| alloy | 192.168.0.102 | - | - | - | False |
| cloudflare-ddns | 192.168.0.102 | - | - | - | False |
| grocy | 192.168.0.102 | 9283 | [192.168.0.102:9283](http://192.168.0.102:9283) | [grocy.suskins.co.uk](https://grocy.suskins.co.uk) | False |
| mealie | 192.168.0.102 | 9925 | [192.168.0.102:9925](http://192.168.0.102:9925) | [mealie.suskins.co.uk](https://mealie.suskins.co.uk) | False |
| pubgolf | 192.168.0.102 | 3003 | [192.168.0.102:3003](http://192.168.0.102:3003) | [pubgolf.me](https://pubgolf.me) | False |
| pubgolf-backend | 192.168.0.102 | 8080 | [192.168.0.102:8080](http://192.168.0.102:8080) | [api.pubgolf.me](https://api.pubgolf.me) | False |
| pubgolf-postgres | 192.168.0.102 | 5433 | [192.168.0.102:5433](http://192.168.0.102:5433) | - | False |

## Docker Server

| Service | Host | Port | Direct URL | URL | Exposed |
|---------|------|------|--------------|-----|---------|
| home | 192.168.0.102 | 3000 | [192.168.0.102:3000](http://192.168.0.102:3000) | [home.suskins.co.uk](https://home.suskins.co.uk) | False |

## Games

| Service | Host | Port | Direct URL | URL | Exposed |
|---------|------|------|--------------|-----|---------|
| games | 192.168.0.202 | 80 | [192.168.0.202:80](http://192.168.0.202:80) | [games.suskins.co.uk](https://games.suskins.co.uk) | False |
| minecraft | 192.168.0.125 | 25566 | [192.168.0.125:25566](http://192.168.0.125:25566) | [minecraft.suskins.co.uk](https://minecraft.suskins.co.uk) | False |
| starscream | 192.168.0.125 | 8080 | [192.168.0.125:8080](http://192.168.0.125:8080) | [starscream.suskins.co.uk](https://starscream.suskins.co.uk) | False |

## General

| Service | Host | Port | Direct URL | URL | Exposed |
|---------|------|------|--------------|-----|---------|
| homeassistant | 192.168.0.65 | 8123 | [192.168.0.65:8123](http://192.168.0.65:8123) | [homeassistant.suskins.co.uk](https://homeassistant.suskins.co.uk) | False |
| proxmox | 192.168.0.253 | 8006 | [192.168.0.253:8006](http://192.168.0.253:8006) | [pve.suskins.co.uk](https://pve.suskins.co.uk) | False |
| truenas | 192.168.0.100 | 443 | [192.168.0.100:443](http://192.168.0.100:443) | [nas.suskins.co.uk](https://nas.suskins.co.uk) | False |
| unifi | 192.168.0.1 | 443 | [192.168.0.1:443](http://192.168.0.1:443) | [unifi.suskins.co.uk](https://unifi.suskins.co.uk) | False |

## Media

| Service | Host | Port | Direct URL | URL | Exposed |
|---------|------|------|--------------|-----|---------|
| alloy | 192.168.0.101 | - | - | - | False |
| bazarr | 192.168.0.101 | 6767 | [192.168.0.101:6767](http://192.168.0.101:6767) | [bazarr.suskins.co.uk](https://bazarr.suskins.co.uk) | False |
| doplarr | 192.168.0.101 | - | - | - | False |
| gluetun | 192.168.0.101 | 8888 | [192.168.0.101:8888](http://192.168.0.101:8888) | - | False |
| metube | 192.168.0.101 | 8081 | [192.168.0.101:8081](http://192.168.0.101:8081) | [metube.suskins.co.uk](https://metube.suskins.co.uk) | False |
| openbooks | 192.168.0.101 | 8080 | [192.168.0.101:8080](http://192.168.0.101:8080) | [openbooks.suskins.co.uk](https://openbooks.suskins.co.uk) | False |
| overseerr | 192.168.0.101 | 5055 | [192.168.0.101:5055](http://192.168.0.101:5055) | [overseerr.suskins.co.uk](https://overseerr.suskins.co.uk) | False |
| plex | 192.168.0.101 | 32400 | [192.168.0.101:32400](http://192.168.0.101:32400) | [plex.suskins.co.uk](https://plex.suskins.co.uk) | False |
| profilarr | 192.168.0.101 | 6868 | [192.168.0.101:6868](http://192.168.0.101:6868) | [profilarr.suskins.co.uk](https://profilarr.suskins.co.uk) | False |
| prowlarr | 192.168.0.101 | 9696 | [192.168.0.101:9696](http://192.168.0.101:9696) | [prowlarr.suskins.co.uk](https://prowlarr.suskins.co.uk) | False |
| qbittorrent | 192.168.0.101 | 9091 | [192.168.0.101:9091](http://192.168.0.101:9091) | [qbittorrent.suskins.co.uk](https://qbittorrent.suskins.co.uk) | False |
| radarr | 192.168.0.101 | 7878 | [192.168.0.101:7878](http://192.168.0.101:7878) | [radarr.suskins.co.uk](https://radarr.suskins.co.uk) | False |
| sonarr | 192.168.0.101 | 8989 | [192.168.0.101:8989](http://192.168.0.101:8989) | [sonarr.suskins.co.uk](https://sonarr.suskins.co.uk) | False |

## Monitoring

| Service | Host | Port | Direct URL | URL | Exposed |
|---------|------|------|--------------|-----|---------|
| alloy | 192.168.0.104 | - | - | - | False |
| grafana | 192.168.0.104 | 3000 | [192.168.0.104:3000](http://192.168.0.104:3000) | [grafana.suskins.co.uk](https://grafana.suskins.co.uk) | False |
| graphite-exporter | 192.168.0.104 | 9108 | [192.168.0.104:9108](http://192.168.0.104:9108) | - | False |
| loki | 192.168.0.104 | 3100 | [192.168.0.104:3100](http://192.168.0.104:3100) | - | False |
| prometheus | 192.168.0.104 | 9090 | [192.168.0.104:9090](http://192.168.0.104:9090) | [prometheus.suskins.co.uk](https://prometheus.suskins.co.uk) | False |

## Monitoring Server

| Service | Host | Port | Direct URL | URL | Exposed |
|---------|------|------|--------------|-----|---------|
| gatus | 192.168.0.104 | 8080 | [192.168.0.104:8080](http://192.168.0.104:8080) | [gatus.suskins.co.uk](https://gatus.suskins.co.uk) | False |

---

# 🙏 Acknowledgments

- [Homelab Subreddit](http://reddit.com/r/homelab)
- [Selfhosted Subreddit](http://reddit.com/r/selfhosted)
- [rishavnandi - Ansible Homelab](https://github.com/rishavnandi/ansible_homelab)
- [mazay - Truenas Grafana](https://github.com/mazay/truenas-grafana)

---

*Generated by Ansible on 2025-12-25T16:08:46Z*
