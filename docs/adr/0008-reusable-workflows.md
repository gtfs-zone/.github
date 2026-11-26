---
status: accepted
date: 2026-11-26
---

# Reusable workflows in the org repo

## Context and Problem Statement

Every repo carried its own copy of the same check, commit check and
vulnerability scan workflows. A fix or an action bump had to be repeated
in each repo, and the copies drifted. Where does CI live?

## Decision Drivers

- One place to change a job
- Each repo still decides when its jobs run
- Third-party actions stay pinned by SHA

## Considered Options

- A copy of each workflow per repo
- Composite actions in the org repo
- Reusable workflows (`workflow_call`) in the org repo

## Decision Outcome

Chosen option: reusable workflows in `gtfs-zone/.github`.

- `.github/workflows/` holds `node-check.yml`, `python-check.yml`,
  `commit-check.yml`, `vuln-scan.yml`, `docs-check.yml` (markdownlint-cli2
  and lychee), `agents-check.yml` (the shared AGENTS.md block) and
  `release.yml` (`cz bump` and the tag push, see ADR 0005).
- Each repo keeps thin callers that set the triggers: `check.yml`
  (check, commit check, agents check) and `vuln-scan.yml`. Deploy
  workflows still call the repo's own `check.yml` before they build.
- Callers reference the org workflows by commit SHA, with the branch in a
  comment; Renovate keeps those refs and the actions inside them current.
- Scripts a repo also runs locally (`scripts/vuln-gate.sh`,
  `scripts/check.sh`) stay in that repo; the workflows call them.
- `workflow-templates/` gives new repos the same callers from the
  "New workflow" page.

### Consequences

- Good, because an action bump or a job fix lands once, then reaches each
  repo as a Renovate PR.
- Good, because the callers are short enough to read at a glance.
- Bad, because a change to a reusable workflow is only tested in the repos
  that pick it up.

## More Information

[0005](0005-pr-flow.md) names the required checks these workflows provide.
