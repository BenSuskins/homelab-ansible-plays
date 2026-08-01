# Traefik and TrueNAS dashboards are hand-built, not imported

`Infrastructure/traefik.json` was grafana.com dashboard **17346** ("Official
dashboard for Standalone Traefik", `gnetId: 17346`, `editable: false`, 1,508
lines) and `Infrastructure/truenas.json` was a 6,304-line dashboard derived from
a Netdata/node-exporter community import with ten collapsed rows and a
repeat-by-disk section. Between them they were roughly 85% of all dashboard JSON
in the repo, and neither followed any convention used by the dashboards written
here: `traefik.json` sat on `schemaVersion` 37 with `graphTooltip: 0` and
auto-refresh disabled, `truenas.json` on 40 with a 30-minute default window.
Both hid nearly everything behind collapsed rows, and neither carried the folder
navigation links.

Decided: both are **rebuilt from scratch** as small hand-authored dashboards
following `docs/grafana-dashboard-style.md`, covering only the panels actually
worth looking at. Traefik is restructured around golden signals (rate, errors,
latency, saturation) so it reads as a sibling of the HTTP section on the Pubgolf
dashboard, and drops its custom `$interval` variable in favour of the
`$__rate_interval` every other dashboard uses. TrueNAS is restructured around
what a NAS is for — pool health, capacity, disk temperature, throughput — with
host resources demoted to a supporting section and ZFS/NFS internals confined to
a single collapsed `Deep Dive`.

The alternatives were to apply only a cosmetic layer (nav links and defaults) and
leave their internals foreign, or to fork them wholesale and restyle 7,800 lines
of someone else's JSON by hand. The first leaves two dashboards that visibly do
not belong; the second costs the same maintenance as a rebuild while keeping
panels nobody reads.

The cost is real and one-way: **there is no upstream to pull from any more.**
A fix or a new panel in grafana.com #17346 will not reach us, and re-importing
it would silently discard this work. If a future Traefik release changes metric
names, that is now our problem to find and fix. This was judged worth it because
the imports had already diverged — `truenas.json` had to be rewritten once
already when TrueNAS SCALE moved from collectd to Netdata graphite naming
(commit `c89b987`), so the "free upstream maintenance" the imports appeared to
offer was not actually being delivered.
