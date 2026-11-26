---
status: accepted
date: 2026-11-26
---

# Dependency updates through one shared Renovate preset

## Context and Problem Statement

Each consumer pins `gtfs-zone-web-common` to a git tag by hand, so several
apps run old tags (v5 next to v7). Actions, npm and uv dependencies are
bumped by hand when someone notices. How do updates reach every repo
without per-repo setup?

## Decision Drivers

- A new web-common tag reaches each consumer without anyone remembering
- Few PRs: one weekly batch per ecosystem, not one per package
- Actions and org workflow refs stay pinned by SHA (ADR 0008)
- Every update goes through a PR and its required checks (ADR 0005)

## Considered Options

- Manual bumps
- Dependabot, a `dependabot.yml` per repo
- Renovate, with one preset in the org repo that each repo extends

## Decision Outcome

Chosen option: Renovate with a shared preset, because Dependabot cannot
share one config across repos and does not follow `github:` git tags in
`package.json`.

`renovate-config/default.json` in `gtfs-zone/.github`:

- `gtfs-zone-web-common` (`github:gtfs-zone/gtfs-zone-web-common#vX`): a PR
  per new tag in each consumer, at any time
- Org reusable workflow refs (`gtfs-zone/.github/...@<sha> # main`): a PR
  as soon as `main` moves
- npm and uv (`pep621`): one grouped PR per ecosystem for minor and patch
  updates, Monday 00:00 to 04:00 UTC; majors get their own PRs on the same
  schedule
- GitHub Actions: one grouped PR a week, majors included; digests pinned
  through `helpers:pinGitHubActionDigests`
- Lock file maintenance (`pnpm-lock.yaml`, `uv.lock`) on the 1st of each
  month
- Conventional Commit PR titles (`chore(deps): ...`); no automerge

Each repo's `renovate.json` holds only:

```json
{ "extends": ["github>gtfs-zone/.github//renovate-config/default"] }
```

### Consequences

- Good, because a preset change reaches every repo without a PR per repo.
- Good, because consumers stop drifting behind web-common.
- Bad, because a broken preset breaks Renovate in every repo at once.
- Bad, because the Renovate GitHub App needs read and write access to
  every repo in the org.

## More Information

[0005](0005-pr-flow.md) for the PR flow,
[0008](0008-reusable-workflows.md) for the SHA-pinned workflow refs.
