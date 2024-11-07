# Homelab Ansible Plays

# Ansible Vault

Edit Vault

```bash
ansible-vault edit vault.yml
````

# Ansible Plays

## Setup

```bash
ansible-playbook plays/setup.yml -K --ask-vault-pass
```

Initalises hosts with deps, docker, qemu, promtail, cadvisor then reboots.

## Deploy Containers

```bash
ansible-playbook plays/deploy-containers.yml -K --ask-vault-pass
```

Deploys the hosts containers as per group vars.

## Update Homepage

```bash
ansible-playbook plays/update-homepage.yml --ask-vault-pass
```

Updates Homepage config.

## Update

```bash
ansible-playbook plays/update.yml -K --ask-vault-pass
```

Updates / Upgrades all packages and docker containers as per group vars.

## Cleanup system

```bash
ansible-playbook plays/clean.yml -K --ask-vault-pass
```

# Hosts

## All Servers

### Containers

- cadvisor
- promtail

## Media Server

### Containers

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

### Containers

- grafana
- prometheus
- loki
- uptime-kuma

## Docker Server

### Containers

- pi-hole
- homepage
- nginx-proxy-manager
- grocy
- it-tools
- mealie
- ghost

# Todo

- Every docker task should create a homepage entry
- Automate Uptime Kuma configuration
- Automate Pi Hole Local DNS
- Add pushgateway to monitor
    - Create a Java Template that pushes metrics to it
- Add CI/CD
- Pi Hole Exporter https://github.com/eko/pihole-exporter
- Truenas exporter https://www.truenas.com/community/threads/how-to-expose-data-for-prometheus.98532/
- SSO
