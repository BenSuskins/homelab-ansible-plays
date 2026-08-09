# Homelab Menu Bar

A macOS menu bar app for this repository: see the state of the three
dispatchable workflows, start or cancel them, see and squash-merge open pull
requests, and jump to Homepage / Actions / the repo.

```
⚙  ← glyph: worst-of (⚠ failed > ◐ running > ⚙ ok)
┌──────────────────────────────┐
│ Update      ✓ passed · 2h ago│  [▶]
│ Terraform   ⏸ awaiting appr… │
│ Clean       ◐ running · 3m 12s  [■]
│ ──────────────────────────── │
│ Open PRs (1)                 │
│  #141 chore(deps): ansible…  │  [Merge]
│ ──────────────────────────── │
│ Homepage ↗  Actions ↗  Repo ↗│
└──────────────────────────────┘
```

## Requirements

The [GitHub CLI](https://cli.github.com), authenticated:

```bash
gh auth status   # needs the `repo` scope
```

The app holds no token of its own — every call shells out to `gh`, so
`gh auth login` is the only credential management there is. It searches `PATH`
and then Nix, Homebrew and `/usr/local` explicitly, because a GUI app launched
from Finder does not inherit your shell's `PATH`.

## Build

```bash
make test      # unit tests against a fake `gh`
make bundle    # .build/Homelab.app
make install   # copy to /Applications
make run       # build and launch without installing
```

`swift test` alone is the fast red/green loop. The contract tests are excluded
from it by name:

```bash
swift test --skip Contract    # fakes only, no network
swift test --filter Contract  # real `gh`, read-only
```

To launch at login, add `/Applications/Homelab.app` under
System Settings → General → Login Items.

## Design

Data flows one way, and every layer above the process boundary is a pure
function of the layer below:

```
GitHubCommandLineRunner   ← the only impure thing; spawns `gh`
      ↓ Data
GitHubClient              ← decodes, maps onto domain types
      ↓ WorkflowRunSummary / PullRequestSummary
AppState                  ← @Observable, owns the polling loop
      ↓ MenuSnapshot      ← immutable; also what gets cached to disk
MenuView
```

`MenuSnapshot` is the seam. It answers every question the view can ask — what
colour a row is, whether its button is enabled, what the subtitle says — so the
view holds no logic and the logic needs no view to test.

Tests fake `CommandRunner`, the process boundary, which means decoding, mapping
and snapshot construction all run for real. A handful of read-only contract
tests run the actual `gh` to catch the one thing a fake cannot: `gh` changing
its output.

### Deliberate choices

- **No confirmation on trigger.** The guard against a stray double-click is that
  `▶` is disabled while a run is open, backed by `concurrency` groups on the
  workflows and `use_lockfile` on the Terraform backends.
- **The app never approves a deployment.** Terraform parks at its
  `required_reviewers` gate; the row says so and links to the run, where the
  plan is. Approving a plan you cannot see is just a slower auto-apply.
- **Notify on failure only.** Success is expected and the glyph already reports
  it, so a notification always means something broke.
- **A run awaiting approval does not raise the glyph or tighten polling.** It
  will sit there until a human acts.
- **Squash merge, always.** One commit on `main` per PR is one Update Homelab
  run is one line in the deploy log. Merging here deploys.
