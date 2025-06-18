# 🏡 Homelab Ansible Plays

My [Ansible](https://github.com/ansible/ansible) configuration to setup / manage my homelab.

---

## ✨ Features

- 🚀 Automated setup of hosts.
- 🔐 Secrets managed by Ansible Vault.
- 🐳 Deploying and updating containers.
- 📦 Automated docker updates via [Renovate](https://github.com/renovatebot/renovate).
- 🔄 Regular maintenance.

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

Initialises hosts with dependencies, docker, qemu, promtail, cadvisor then reboots.

```bash
ansible-playbook plays/setup.yml -K --ask-vault-pass
```

## 🐳 Deploy Containers

Deploys the hosts containers.

```bash
ansible-playbook plays/deploy-containers.yml -K --ask-vault-pass
```

## 🏠 Update Homepage

Updates Homepage config.

```bash
ansible-playbook plays/update-homepage.yml --ask-vault-pass
```

## ⬆️ Update

Updates / Upgrades all packages and docker containers.

```bash
ansible-playbook plays/update.yml -K --ask-vault-pass
```

## 🧹 Cleanup system

Cleanup docker and system files.

```bash
ansible-playbook plays/clean.yml -K --ask-vault-pass
```

---

# 🖥️ Hosts
Details of the services running on each host.

## 🌐 All Hosts

- 📊 cadvisor
- 🧬 alloy

## 🎬 Media Server (`mediaserver`)

- 🎥 plex
- 📺 sonarr
- 🎞️ radarr
- 👀 overseerr
- 📡 prowlarr
- 📝 bazarr
- 🌐 gluetun
- 📹 metube
- 💾 qbittorrent
- 🗣️ doplarr

## 📈 Monitoring Server (`monitor`)

- 📊 grafana
- 🗃️ loki
- ⏱️ uptime-kuma
- 📈 graphite-exporter
- 📉 prometheus

## 🐳 Docker Server (`docker`)

- 🕳️ pi-hole
- 📦 pi-hole-exporter
- 🏠 homepage
- 🛒 grocy
- 🍲 mealie
- 🐘 postgres
- 🪞 magic-mirror
- ⛳ pubgolf_postgres
- 🏌️ pubgolf_backend
- 🏌️‍♂️ pubgolf_frontend
- ☁️ cloudflare-ddns

## 💻 Development Server (`development`)

- 🔐 authentik_server
- 🛠️ authentik_worker
- 🐘 authentik_postgres
- 🧠 authentik_redis
- 🚦 traefik
- 🛡️ crowdsec
---

# 🙏 Acknowledgments

- [Homelab Subreddit](http://reddit.com/r/homelab)
- [Selfhosted Subreddit](http://reddit.com/r/selfhosted)
- [rishavnandi - Ansible Homelab](https://github.com/rishavnandi/ansible_homelab)
- [mazay - Truenas Grafana](https://github.com/mazay/truenas-grafana)
