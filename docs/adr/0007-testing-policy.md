---
status: accepted
date: 2026-11-25
---

# Vitest for logic, Playwright and Argos for UI

## Context and Problem Statement

The browser apps had no automated tests; changes were checked by hand, and
the editor's invariants (patch system, frozen rows, networks) were held by
convention only. What do the JS repos test, and with what?

## Considered Options

- Manual checks only
- Vitest for pure logic, Playwright with Argos for UI
- Playwright end to end for everything

## Decision Outcome

Chosen option: Vitest for pure logic, Playwright with Argos for UI.

- **Vitest** for pure logic and invariants, on a shared preset from
  web-common. `pnpm test` runs in `pnpm check`. Each test file says which
  invariant it holds and links where that invariant is documented.
- **Playwright** for UI, on a shared preset from web-common (light, dark
  and mobile projects, animations off, fixed viewport, `vite preview`),
  with fixture feeds pinned by sha256 and a local basemap.
- **Argos** for visual regression: PR screenshots are compared against
  `main`, and an unreviewed diff blocks the merge.
- Release screenshots come from the same specs, so docs and the homepage
  show the current UI.
- Python repos keep pytest.

### Consequences

- Good, because invariants are checked on every PR, not remembered.
- Good, because UI changes show up as reviewed screenshot diffs.
- Bad, because screenshot specs need fixed fixtures and a pinned browser
  image to stay stable.
