# Host Label is canonical for dashboard host identification, never `up`

Two Grafana dashboards (`homelab-overview.json`, `docker-containers.json`) had independently drifted onto different conventions for "which host" — one filtering/displaying by the `host` label (Friendly Name), the other by `instance` (raw IP) — with nothing written down about which was correct. Separately, `homelab-overview.json`'s "Hosts Reporting" panel queried `up{host=~"$host"}`, which silently counts Prometheus scrape jobs, not real hosts, because host-level metrics (`node_*`, `container_*`) arrive via Alloy's `remote_write` and never produce an `up` series (see **Remote-Written Metric** in `CONTEXT.md`).

Decided: every dashboard filters and displays hosts using the **Host Label** (`host`, = Friendly Name), never `instance`. Panels that need to know "is this host alive" query a real remote-written signal (e.g. `node_boot_time_seconds`) rather than `up`. Rejected introducing actual OS hostnames as a new label — Friendly Name already uniquely identifies each host and is the existing convention across Homepage/Gatus/Traefik.

Without this written down, the next dashboard is as likely to copy the `instance`-based pattern as the `host`-based one, since both exist in the codebase today.
