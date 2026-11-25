---
status: proposed
date: 2026-11-25
---

# Versioned deploys and per-PR previews on Cloudflare

## Context and Problem Statement

The browser apps deploy to GitHub Pages: one live version, no preview of a
PR, no way back to an older release. Users of the editor keep feeds in
OPFS and IndexedDB, which are per origin. Where do the apps deploy, and how
are older versions kept without breaking stored data?

## Decision Drivers

- A preview URL on every PR
- Older releases stay reachable
- An older build never opens a database written by a newer one

## Considered Options

- Hosting: Cloudflare Workers static assets, or Cloudflare Pages
- Kept versions on a path of the same origin (`edit.gtfs.zone/v/0.47/`)
- Kept versions on their own origin (`v0-47.edit.gtfs.zone`)

## Decision Outcome

Proposed: Cloudflare (Workers static assets or Pages, chosen in a spike),
one origin per kept version.

- A path on the same origin shares the database with the current version,
  so an older build would open a newer schema. A version on its own origin
  is isolated, at the cost of its feeds not carrying over. The version menu
  says so ("separate storage").
- PRs get a preview deploy; a tag deploys production and a version alias.
- The production deploy carries `versions.json` (kept versions and their
  URLs), which the web-common version menu reads.
- Retention: the last N minors plus anything newer than 90 days; a weekly
  job prunes the rest. N is set in the spike.
- Projects, domains and the API token are managed in gtfs-zone-infra's tofu.

### Consequences

- Good, because every PR can be checked on a real URL.
- Good, because a regression can be worked around by opening an older
  version.
- Bad, because feeds do not follow a user into an older version.
- Bad, because wildcard routing and per-version domains add infra.

## More Information

Accepted once the spike picks the hosting option and N.
