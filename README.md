# Homelab Ansible Plays

This repository automates the configuration and management of a self-hosted homelab environment using Ansible. My homelab is built on a Proxmox server and features multiple Docker hosts. Each playbook in this repository targets a specific part of the infrastructure, streamlining configuration, deployment and ongoing maintenance tasks.

---

## Features

- Automated setup and management of Docker containers across multiple hosts.
- Secure handling of secrets using Ansible Vault.
- Playbooks for:
  - Initializing hosts with dependencies.
  - Deploying and updating containers.
  - Regular maintenance

---

# Prerequisites

Ensure you have the following installed on your control machine:
- Ansible (minimum version 2.12)
- SSH access to all target hosts.
- Ansible Vault set up for secrets management.

## Ansible Vault set up for secrets management

Edit Vault:

```bash
ansible-vault edit vault.yml
```

Copy vault to secrets:

```bash
ansible-vault edit vault.yml
cp vault.yml ../secrets
```

## SSH access to all target hosts

Copy SSH key to host:

```bash
ssh-copy-id -i ~/.ssh/homelab.pub <user>@<host>
```
---

# Playbooks

## Setup

Initalises hosts with dependencies, docker, qemu, promtail, cadvisor then reboots.

```bash
ansible-playbook plays/setup.yml -K --ask-vault-pass
```

## Deploy Containers

Deploys the hosts containers.

```bash
ansible-playbook plays/deploy-containers.yml -K --ask-vault-pass
```


## Update Homepage

Updates Homepage config.

```bash
ansible-playbook plays/update-homepage.yml --ask-vault-pass
```


## Update

Updates / Upgrades all packages and docker containers.

```bash
ansible-playbook plays/update.yml -K --ask-vault-pass
```

## Cleanup system

Cleanup docker and system files.

```bash
ansible-playbook plays/clean.yml -K --ask-vault-pass
```

---

# Hosts
Details of the services running on each host.

## All

- cadvisor
- promtail

## Media Server

- plex
- sonarr
- radarr
- overseer
- prowlarr
- bazarr
- gluetun
- transmission
- metube

## Monitoring Server

- grafana
- prometheus
- loki
- uptime-kuma

## Docker Server

- pi-hole
- homepage
- nginx-proxy-manager
- grocy
- it-tools
- mealie

---

# Planned Improvements

These are tracked in [GitHub Issues](https://github.com/BenSuskins/homelab-ansible-plays/issues):

# Acknowledgments

This repo was inspired by and has drawn from the following repositories and resources:

- [Homelab Subreddit](http://reddit.com/r/homelab)
- [Selfhosted Subreddit](http://reddit.com/r/selfhosted)
- [Ansible Homelab](https://github.com/rishavnandi/ansible_homelab)