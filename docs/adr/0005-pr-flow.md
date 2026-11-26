---
status: accepted
date: 2026-11-25
---

# Every change to main goes through a pull request

## Context and Problem Statement

Work was merged into `main` locally and pushed, so checks ran only after
the fact and nothing gated a broken commit. How does a change reach `main`?

## Considered Options

- Local merges, CI after push
- Pull requests, squash merge
- Pull requests, merge commit

## Decision Outcome

Chosen option: pull requests with a merge commit.

- One branch per change from `main`, never with an `agent/` prefix.
  Conventional Commits on every commit.
- Push the branch, open the PR with `gh pr create`. The description lists
  the changes made, nothing else.
- Merge with a merge commit once the required checks (check, commit check,
  Argos where present) pass. The branch is deleted on merge.
- Renovate PRs follow the same flow.
- A ruleset on `main` in each repo enforces it: PR required (no approval,
  merge commit only), required checks, no force push or deletion. Org
  rulesets need GitHub Team, so `scripts/apply-settings.sh` writes the same
  ruleset into each repo listed in `settings/rulesets.json`, with that
  repo's required checks. It also turns off squash and rebase merges and
  turns on head branch deletion in every repo.
- Release bumps (`cz bump`) run in the reusable `release.yml`, dispatched
  by hand. It pushes the bump commit and tag with a token of the
  org-owned `gtfs-zone-release` GitHub App, which is the ruleset's bypass
  actor. A repo ruleset only accepts apps owned by the org, so the GitHub
  Actions app cannot be one, and a tag pushed with `GITHUB_TOKEN` would
  start no deploy. The app's client ID (`RELEASE_APP_CLIENT_ID` variable)
  and private key (`RELEASE_APP_PRIVATE_KEY` secret) are org-wide.

### Consequences

- Good, because nothing reaches `main` without passing checks.
- Good, because merge commits keep each branch's Conventional Commits,
  which `cz bump` reads for the changelog.
- Bad, because a one-line fix now needs a branch and a PR.
