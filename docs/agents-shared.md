## Shared conventions

Synced from `docs/agents-shared.md` in
[gtfs-zone/.github](https://github.com/gtfs-zone/.github). Edit it there, then
run `mani run sync-agents`; CI fails while this block differs from that copy.

- **Pull requests**: every change to `main` goes through a PR
  ([ADR 0005](https://github.com/gtfs-zone/.github/blob/main/docs/adr/0005-pr-flow.md)).
  Branch from `main` (never an `agent/` prefix), push, open it with
  `gh pr create`. The description lists the changes made, nothing else.
  Merge with a merge commit once the required checks and Argos (where
  present) pass. Renovate PRs follow the same flow. Never push to `main`.
- **Commits**: Conventional Commits on every commit. Never add
  Co-Authored-By trailers.
- **Plans**: `CURRENT_PLAN.md` at the repo root follows the
  [plan standard](https://github.com/gtfs-zone/.github/blob/main/docs/plan-standard.md).
  It is neither tracked nor gitignored: never stage or commit it.
  Decisions go in ADRs: cross-repo ones in
  [gtfs-zone/.github `docs/adr/`](https://github.com/gtfs-zone/.github/tree/main/docs/adr),
  single-repo ones in the repo's own `docs/adr/`.
- **Testing**
  ([ADR 0007](https://github.com/gtfs-zone/.github/blob/main/docs/adr/0007-testing-policy.md)):
  Vitest for pure logic and invariants (`pnpm test`, part of `pnpm check`),
  Playwright with Argos for UI, both on web-common's presets. Python repos
  use pytest. A test file says which invariant it holds and links where
  that invariant is documented.
- **Local web-common**: in a consumer, `pnpm common:local` links
  `../gtfs-zone-web-common` in place of the pinned tag, so its edits show up
  live; `pnpm common:tag` restores the tag. Build and push fail while the
  link is local. The change itself still lands in web-common as a PR, a tag
  and a bump in each consumer.
- **Tooling**: mise pins each repo's toolchain (`.mise.toml`, then
  `mise install`). mani runs tasks across every repo from
  gtfs-zone-dev-stack (`mani run status`, `mani run sync-agents`). Sibling
  repos live under one parent directory and may be read and edited when a
  change spans repos.
