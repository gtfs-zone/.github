---
status: accepted
date: 2026-11-27
---

# mani for tasks across repos, mise for each repo's toolchain

## Context and Problem Statement

There are 27 gtfs-zone repos, checked out as siblings. Seeing which have
uncommitted work or stale branches, or running every check, means a shell
loop each time. Node, pnpm, python and uv versions are set in several
places (`packageManager`, `requires-python`, `node-version` in workflows)
and differ between laptops and CI. How do we run one command over every
repo, and get the same toolchain everywhere?

## Decision Drivers

- One config file lists every repo, its clone URL and its groups
- A repo's toolchain is pinned once, in the repo, and CI reads the same pin
- Renovate can update the pins (ADR 0009)
- No custom scripts where a maintained tool exists

## Considered Options

- Shell loops in a script, versions left to each workflow
- mani (repos and tasks in one YAML file) and mise (a `.mise.toml` per repo)
- A monorepo

## Decision Outcome

Chosen option: mani and mise, because both are single binaries with
declarative configs, and a monorepo would undo the per-repo CI, releases
and access the org is built on.

- `mani.yaml` in gtfs-zone-dev-stack lists every repo (path, URL, tags
  `web`, `python`, `rt`, `wifi`, `data`) and the tasks `status`,
  `branches`, `check`, `sync-agents` and `pull`. A run with no target goes
  to every repo. `mani sync` clones the missing ones.
- Each repo has a `.mise.toml` pinning exact versions: node and pnpm in
  pnpm repos, python and uv in uv repos, both in repos that have both.
- `node-check.yml` and `python-check.yml` install the toolchain with
  `jdx/mise-action`, in place of `setup-node`, `pnpm/action-setup` and
  `setup-uv`. `commit-check.yml` and `release.yml` keep `setup-uv`: they
  only need `uvx` for commitizen, not the repo's toolchain.
- `packageManager` in `package.json` stays, since pnpm and Corepack read
  it. `node-check.yml` fails when it names a different pnpm than
  `.mise.toml`, and the Renovate preset updates both in one PR.

### Consequences

- Good, because laptops and CI run the same node, pnpm, python and uv.
- Good, because `mani run branches` and `mani run status` replace ad hoc
  loops across repos.
- Bad, because a repo calling the new reusable workflows without a
  `.mise.toml` fails to install anything; each repo gets its `.mise.toml`
  in the same PR that bumps its workflow ref.
- Bad, because the pnpm store is no longer cached between CI runs.

## More Information

[0008](0008-reusable-workflows.md) for the reusable workflows,
[0009](0009-renovate.md) for the Renovate preset. Install and usage are in
the gtfs-zone-dev-stack README.
