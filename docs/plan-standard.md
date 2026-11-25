# Plan standard

How a working plan (`CURRENT_PLAN.md`) is written in any gtfs.zone repo. A
plan says what is left to do. Why things are the way they are lives in an
[ADR](adr/README.md); what happened lives in the PR.

## File

- `CURRENT_PLAN.md` at the repo root. It is never tracked: never stage or
  commit it.
- At most about 150 lines. A longer plan is cut, not split into a log.

## Top

- The goal in two or three lines.
- The repos it touches.
- Links to the ADRs it relies on.

## Body

- Open phases only, as checklists (`- [ ]`), ticked as work lands.
- A finished phase becomes one line in the same turn it finishes:
  `- [x] Phase N: <what> (<sha or tag>)`.
- No decisions: a choice made while planning goes in an ADR, and the plan
  links it.
- No measurements or history: those go in the PR description, or in the
  ADR when they justify a decision.

## Cross-repo plans

- The plan lives in one repo, the one most of the work happens in.
- Every other repo it touches holds a three-line `CURRENT_PLAN.md`
  pointer: the goal, the path to the plan, and which phases touch this
  repo.
