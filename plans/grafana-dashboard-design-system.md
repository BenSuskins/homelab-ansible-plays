# Grafana Dashboard Design System

Extract the design language of `Overview/homelab-overview.json` into a written
standard, then apply it to every dashboard in the repo.

Agreed in a grilling session; every decision below was chosen explicitly.

## Problem

The Overview dashboard has a coherent look — folder dropdowns in the top bar,
semantic row sections, a KPI strip over chart pairs, consistent panel tokens.
None of the other ten dashboards share it:

- `links: []` on all ten — no nav, no way home from a leaf dashboard
- three have no row sections at all (Containers, Proxmox, Logs)
- three have a single vanity row that just repeats the dashboard title
  (Home Assistant, Tailscale, Gatus SLO)
- panel tokens (`fillOpacity`, `lineWidth`, legend mode, tooltip mode) vary
- threshold ladders are ad hoc — a red tile means a different thing per page
- `traefik.json` is grafana.com dashboard #17346 (1,508 lines, `editable: false`,
  `schemaVersion: 37`, `graphTooltip: 0`, refresh off)
- `truenas.json` is a 6,304-line Netdata-derived import with 10 collapsed rows

## Decisions

| # | Decision | Chosen |
|---|---|---|
| 1 | Vendored dashboards (traefik, truenas) | **Rebuild from scratch** in the Overview idiom |
| 2 | How the system is encoded | **Style guide doc only** — no lint, no generator |
| 3 | Top bar | `[← Overview]` link + Infrastructure / Apps / Monitoring dropdowns, identical in all 11 |
| 4 | Section grammar | `Status → Topic… → Detail`, optional single trailing collapsed `Deep Dive` |
| 5 | Alert strip | Overview only — it stays the front door |
| 6 | Variables | `host` first where meaningful; Gatus `$group` → `$host` |
| 7 | Proxmox | keep `$node` / `$guest` as genuinely distinct concepts, document them |
| 8 | Dashboard defaults | uniform; default time range exempt where the subject has a natural window |
| 9 | Legends | two documented modes — bounded (table + mean/max), unbounded (list, no calcs) |
| 10 | KPI tiles | equal width within a strip, strip sums to exactly 24 columns |
| 11 | Thresholds | fixed ladder per semantic kind |
| 12 | Collapse | everything expanded; at most one trailing collapsed `Deep Dive` |
| 13 | KPI placement | a Topic section may lead with its own topic-scoped KPI strip |
| 14 | Delivery | one PR, everything |
| 15 | Verification | offline JSON + PromQL cross-check; user eyeballs in Grafana |

Rationale for each lives in `docs/grafana-dashboard-style.md`. The decision to
fork the two vendored dashboards is recorded in
`docs/adr/0002-hand-built-traefik-and-truenas-dashboards.md`.

## Deliverables

### Documentation
- `docs/grafana-dashboard-style.md` — the living spec
- `docs/adr/0002-hand-built-traefik-and-truenas-dashboards.md`
- `CONTEXT.md` — new terms: PVE Node, Guest, Status Strip, Topic Section,
  Detail Section, Deep Dive
- `CLAUDE.md` — pointer to the style guide

### Dashboards

| Dashboard | Change |
|---|---|
| Overview | nav self-link; close the `x=12` hole in Fleet Health (3 tiles → 8w); threshold ladders |
| Containers | add sections + Status strip; unbounded legends on the 36-series charts |
| Home Assistant | drop vanity row; fix mixed 6w/4w strip; sections |
| Proxmox | add sections + Status strip |
| Tailscale | drop vanity row; sections |
| Gatus SLO → **Health Checks** | drop vanity row; `$group` → `$host`; Status strip; renamed (uid `health-checks`) |
| Logs | add sections + Status strip |
| Health → **Observability** | Status strip promoted above the three existing rows; renamed (uid `observability`) |
| Pubgolf | nav; rename rows to the grammar |
| **Traefik** | **rebuild** — golden signals; `$interval` → `$__rate_interval` |
| **TrueNAS** | **rebuild** — NAS-first; 6,304 lines → ~450 |

Five dashboards need new stat panels invented for their Status strips
(Containers, Proxmox, Gatus SLO, Logs, Health) — query work, not just restyling.

## Verification

Offline, before the PR:

- every file is valid JSON
- no `gridPos` overlaps and no gaps within a Status strip
- every Status strip sums to exactly 24 columns
- the nav block is present and identical in all 11
- panel tokens match the style guide
- every PromQL metric name referenced exists in this repo's exporter config
  (`tasks/docker/graphite-exporter.yml`, `config/prometheus/config.yml.j2`,
  the alerting rules, or an existing committed dashboard)

Not verifiable offline, so the user checks in Grafana after merge: whether each
panel actually returns data, and whether the rendering looks right.

## Risk accepted

One PR means a ~7k-line diff — including two large deletions — goes live on
merge to `main` via `update.yml`, with no lint gate. A query that is wrong
renders as an empty panel rather than a failure.
