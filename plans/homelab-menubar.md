# Homelab Menu Bar App

**Status:** v1 built and passing (2026-08-09)
**Location:** `apps/homelab-menubar/`

A macOS menu bar app for driving this repository's CI/CD: workflow state,
triggers, open PRs, and three quick links.

## Scope

v1 is **GitHub only** — no Gatus, no Prometheus, no tailnet dependency, so it
works away from the LAN. Service health and host vitals were considered and
deliberately deferred; Grafana and Gatus already answer those questions better
than a 320px popover can.

## Decisions

| Decision | Choice | Why |
|---|---|---|
| Scope | GitHub CI/CD only | Works anywhere; no network dependency on the homelab |
| Stack | SwiftUI `MenuBarExtra(.window)` | One flat panel for one repo; no AppKit menu machinery needed |
| Auth | Shell out to `gh` | Existing keyring login already has `repo` scope; no token code at all |
| Repo | `apps/` in this repo | See ADR 0003 — requires `paths-ignore` on two workflows |
| Build | SwiftPM + `Makefile` | `swift test` is a sub-second TDD loop; all text in git |
| Trigger guard | None — fires immediately | Disabled-while-open + workflow `concurrency` covers the real hazard |
| Terraform gate | Surface + deep link | Approving a plan you cannot see is a slower auto-apply |
| Polling | Adaptive 300s / 10s | Nothing changes for hours, then everything changes for four minutes |
| Glyph | Worst-of failure > running > ok | Answers one question: "do I need to open this?" |
| PRs | List, click to open, squash merge | Merge is deploy: one commit on main = one Update run |
| Quick links | Homepage, Actions, Repo | Homepage is already the link dashboard for the other ~25 services |
| Notifications | Failure only | Silence carries meaning |
| Errors | Typed throws | Same exhaustiveness as `Result`, composes with `async`/`await` |
| Test seam | Fake `CommandRunner` + contract tests | Decoding — the layer most likely to break — stays under test |

Rejected: Tauri/Electron/xbar (wrong weight), `NSStatusItem`+`NSMenu` (RepoBar
needs it for nested per-repo submenus; this app has one flat panel), Bazel
(~80 lines of config and a new toolchain for one target), a separate repo,
generating links from Service Entries (a YAML+Jinja parser in Swift to rebuild
Homepage), local checkout state (different question from "what is the homelab
doing").

## Repository changes this required

These are the point of ADR 0003 and must not be reverted casually:

1. `paths-ignore: ['apps/**']` on `update.yml` **and** `build-mcp-arr.yml` —
   both trigger on every push to `main` with no path filter, so without this a
   commit to Swift code runs Ansible against all six hosts.
2. `concurrency` groups on `clean.yml` and `terraform.yml`. `update.yml` already
   had one; the other two did not.
3. `use_lockfile = true` on all three `backend "s3"` blocks. R2 has no DynamoDB
   table, so Terraform state was entirely unlocked — two concurrent applies
   could corrupt it.

## Architecture

```
GitHubCommandLineRunner   ← the only impure thing; spawns `gh`
      ↓ Data
GitHubClient              ← decodes, maps onto domain types
      ↓ WorkflowRunSummary / PullRequestSummary
AppState                  ← @Observable, owns the polling loop
      ↓ MenuSnapshot      ← immutable; also what gets cached to disk
MenuView
```

`MenuSnapshot` is the seam, borrowed from
[RepoBar](https://github.com/steipete/RepoBar)'s `MenuSnapshot.swift`. It
answers every question the view can ask, so the view holds no logic and the
logic needs no view to test. Also borrowed: splitting `AppState` by concern
across files, and caching the last snapshot so the menu paints instantly.

## Test coverage

42 unit tests against a fake `CommandRunner` (decoding, status mapping, glyph
collapse, polling cadence, failure detection, trigger/merge guards, cache round
trip) and 4 read-only contract tests against real `gh`.

```bash
swift test --skip Contract    # fakes only
swift test --filter Contract  # real gh, read-only
```

## Known gaps

- **A run parked at the approval gate is invisible from the closed menu.** The
  glyph stays `ok` and no notification fires. This follows from choosing
  "notify on failure only" over "failure + awaiting approval" — a parked plan
  waits quietly. Revisit if a plan ever sits forgotten for days.
- **The popover UI has not been visually verified** — screen recording
  permission was unavailable during the build.
- **Launch at login is manual** (System Settings → Login Items) rather than an
  in-app `SMAppService` toggle.

## Possible v2

Gatus service health (needs LAN/tailnet), per-host vitals from Prometheus,
approve-with-plan-summary for Terraform, local checkout state, a settings pane
for the link list.
