# The menu bar app lives in this repo, which constrains two workflows

`apps/homelab-menubar/` is a native macOS SwiftUI application — a Swift package
with its own `Makefile` and test suite — sitting inside a repository that is
otherwise entirely Ansible, Terraform and Jinja. It exists to drive this
repository's three dispatchable workflows (`update.yml`, `terraform.yml`,
`clean.yml`), read open pull requests, and link out to Homepage.

Decided: it stays here rather than in a separate `homelab-menubar` repository,
because the app is a control surface for *this* repo's CI/CD and nothing else —
its `DispatchableWorkflow` enum is literally a list of files in
`.github/workflows/`. Splitting them puts a hard coupling across a repo
boundary where nothing can enforce it.

**The cost is a coupling that is invisible from the app's side and destructive
if forgotten.** `update.yml` and `build-mcp-arr.yml` both trigger on every push
to `main` with no path filter. Without `paths-ignore: ['apps/**']` on both, a
commit that only touches Swift source runs Ansible against all six hosts and
rebuilds the MCP images. Those two `paths-ignore` blocks are load-bearing:
deleting one looks like tidying and behaves like an accidental deploy on every
future app commit.

Adopting the app also forced two unrelated fixes, because a menu bar button
makes dispatching cheap enough to do twice by accident. `clean.yml` and
`terraform.yml` had no `concurrency` group, and the three Terraform R2 backends
had no state locking (`use_lockfile` unset, no DynamoDB table) — so two
concurrent applies could corrupt state. Both are now fixed at the source rather
than guarded in the app, so pushes and bare `gh` invocations are protected too.
The app additionally disables its trigger button while a run is open, but that
is defence in depth, not the mechanism.

The alternatives were a separate repository, which removes the `paths-ignore`
trap entirely but leaves the workflow-file coupling unenforceable and undiscovered
until something breaks; and a local-only checkout with no remote, which loses
history and a second machine. Neither addressed the concurrency and locking gaps,
which were latent in the repository before this app existed and were only found
because dispatching became a one-click operation.
