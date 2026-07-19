# Migrate Sonarr/Radarr MCP to wyattjoh/media-server-mcp

## Background

The upstream repos behind our MCP containers (`jmagar/sonarr-mcp`, `jmagar/radarr-mcp`)
were deleted from GitHub, so the "Build MCP servers" workflow has failed on every run
since mid-July 2026. The running containers survive on the last images pushed to GHCR,
but nothing can be rebuilt.

Replacement: [wyattjoh/media-server-mcp](https://github.com/wyattjoh/media-server-mcp)
— a single MCP server covering Sonarr, Radarr, Plex, and TMDB with streamable HTTP at
`/mcp` (the transport MCP Jungle supports). Forked to
[BenSuskins/media-server-mcp](https://github.com/BenSuskins/media-server-mcp) so the
source cannot disappear again; the build workflow uses the fork.

## Changes

1. **Fork** `wyattjoh/media-server-mcp` → `BenSuskins/media-server-mcp` (done).
2. **Workflow** `.github/workflows/build-mcp-arr.yml`: replace the two jobs with one
   building `ghcr.io/bensuskins/media-server-mcp:latest` from the fork.
3. **Task file** `tasks/docker/media-server-mcp.yml`: standard container pattern.
   Host port `3200` → container `3000` (3000 is taken by workboard on the ai host).
   Env: `SONARR_URL`/`SONARR_API_KEY`, `RADARR_URL`/`RADARR_API_KEY` (both keys
   already in vault). Dockerfile default CMD already runs `--http` on `0.0.0.0:3000`.
4. **`group_vars/ai.yml`**: replace `sonarr-mcp` + `radarr-mcp` with `media-server-mcp`.
5. **Remove** `tasks/docker/sonarr-mcp.yml` and `tasks/docker/radarr-mcp.yml`.

Deliberately skipped for now (all optional in the server):

- `PLEX_API_KEY` / `TMDB_API_KEY` — add to vault later to enable Plex/TMDB tools.
- `MCP_AUTH_TOKEN` — LAN-only, matches previous (unauthenticated) setup.
- `TOOL_EXCLUDE` — consider excluding `radarr_delete_movie,sonarr_delete_series`
  once the tool surface has been reviewed.

## Cutover (manual, after merge)

1. Wait for the "Build MCP servers" workflow to push the new image.
2. `ansible-playbook plays/deploy-containers.yml --ask-vault-pass` — starts
   `media-server-mcp` on the ai host. Old containers keep running (deploy does not
   prune), so nothing breaks yet.
3. Register in MCP Jungle: `http://<ai-host>:3200/mcp` (streamable_http) and smoke
   test Sonarr + Radarr tool calls through it.
4. Once verified: deregister the old `sonarr`/`radarr` MCP servers in MCP Jungle and
   `docker rm -f sonarr-mcp radarr-mcp` on the ai host.
5. Optionally delete the stale `ghcr.io/bensuskins/{sonarr,radarr}-mcp` packages.

## Rollback

Old images remain in GHCR and the old containers keep running until step 4 of the
cutover, so rollback is just re-adding the two entries to `ai.yml` and reverting the
task-file deletions.
