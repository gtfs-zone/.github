# Architecture Decision Records

Decisions that span more than one gtfs.zone repo, in
[MADR](https://adr.github.io/madr/) format. A decision that touches only one
repo lives in that repo's `docs/adr/`. How and why: [0000](0000-record-decisions.md).

To add one, copy [template.md](template.md) to the next number, open a PR
with the change it describes, and add it below.

| ADR | Title | Status |
| --- | --- | --- |
| [0000](0000-record-decisions.md) | Record architecture decisions as MADR files | accepted |
| [0001](0001-one-fetch-per-feed-per-day.md) | One fetch per feed per day, in feed-catalog | accepted |
| [0002](0002-sites-replaces-list.md) | sites.gtfs.zone replaces list.gtfs.zone | accepted |
| [0003](0003-i18n.md) | Internationalization without an i18n framework in the browser apps | accepted |
| [0004](0004-feed-state-and-naming.md) | One feed state and one naming rule, set by feed-catalog | accepted |
| [0005](0005-pr-flow.md) | Every change to main goes through a pull request | accepted |
| [0006](0006-versioned-deploys.md) | Versioned deploys and per-PR previews on Cloudflare | proposed |
| [0007](0007-testing-policy.md) | Vitest for logic, Playwright and Argos for UI | accepted |
| [0008](0008-reusable-workflows.md) | Reusable workflows in the org repo | accepted |
| [0009](0009-renovate.md) | Dependency updates through one shared Renovate preset | accepted |
| [0010](0010-mani-and-mise.md) | mani for tasks across repos, mise for each repo's toolchain | accepted |
