---
status: accepted
date: 2026-11-25
---

# Record architecture decisions as MADR files

## Context and Problem Statement

Decisions that span repos (data contracts, deploy model, PR flow) were
written into untracked `CURRENT_PLAN.md` files. A plan is deleted or thinned
once its work lands, and with it the reasons behind the code. Where does a
decision live so that it outlasts the plan that made it?

## Considered Options

- Keep decisions in plans
- Keep decisions in each repo's `AGENTS.md` / `docs/architecture.md`
- Architecture Decision Records in [MADR](https://adr.github.io/madr/) format

## Decision Outcome

Chosen option: ADRs in MADR format, because they are tracked, dated,
reviewed in a PR, and say why, not only what.

- Cross-repo decisions live in this repo, under `docs/adr/`.
- Decisions that only touch one repo live in that repo's `docs/adr/`.
- Files are `NNNN-kebab-title.md`, numbered in order, starting from
  [template.md](template.md). Each one is listed in [README.md](README.md).
- An ADR is short: the problem, the options, the choice and its
  consequences. Measurements and history go in the PR description.
- An accepted ADR is not rewritten. A new ADR supersedes it, and the old
  one's status becomes `superseded by NNNN`.
- A plan links the ADRs it relies on and records new decisions as ADRs, not
  in its own text (see [the plan standard](../plan-standard.md)).

### Consequences

- Good, because the reason for a contract survives the plan that set it.
- Good, because a decision is reviewed in the same PR as the change.
- Bad, because a decision now needs a file and a PR, not a line in a plan.
