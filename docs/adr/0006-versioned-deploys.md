---
status: accepted
date: 2026-11-27
---

# Versioned deploys and per-PR previews on Cloudflare Workers

## Context and Problem Statement

The browser apps deploy to GitHub Pages: one live version, no preview of a
PR, no way back to an older release. Users of the editor keep feeds in
OPFS and IndexedDB, which are per origin, and a change to the stored
format currently wipes them on upgrade. Where do the apps deploy, how are
older versions kept, and what happens to stored data when its format
changes?

## Decision Drivers

- A preview URL on every PR
- Older releases stay reachable for development and testing
- A user on latest never loses stored data to a format change
- No data migrations (users export and reimport instead)

## Considered Options

- Hosting: Cloudflare Workers static assets, or Cloudflare Pages
- Kept versions on a path of the same origin (`edit.gtfs.zone/v/0.47.0/`),
  or on their own origin (`v0-47.edit.gtfs.zone`)
- On a format change: migrate the stored data, or export from the build
  that wrote it and reimport in latest

## Decision Outcome

Chosen option: Workers static assets, kept versions on paths of the same
origin, and export and reimport on a format change. Workers is Cloudflare's
recommended target for new static sites. A path shares storage with
latest, so data saved by an older build can always be opened in that
build and exported. Its own origin would isolate the data where latest
cannot reach or rescue it.

- `edit.gtfs.zone` serves latest; `/v/<version>/` serves each kept build,
  built with that base path. `/versions.json` at the root lists the kept
  versions and their URLs for the web-common version menu.
- Kept builds are stored in R2. The production deploy uploads latest at
  the root and every kept build under `/v/`.
- Each app that stores data stamps a storage-format version. A build that
  finds data in another format neither opens nor deletes it:
  - older data: it names the version that wrote it and links to
    `/v/<version>/` to export it there, then offers a discard once
    exported
  - newer data: it links to latest
- PRs get a preview deploy on its own origin, posted on the PR as a
  status. A tag deploys production.
- Retention: the last 3 minors plus anything newer than 90 days, from the
  first release that stamps a format version. A weekly job prunes the
  rest.
- The Worker, domains and API token are managed in gtfs-zone-infra's tofu.

### Consequences

- Good, because every PR can be checked on a real URL.
- Good, because a format change costs the user an export and a reimport,
  never their data.
- Good, because a regression can be checked against an older build with
  the same stored data.
- Bad, because every kept build shares the origin's storage, settings and
  tab lock with latest; kept builds are for development and testing.
- Bad, because a format change is only safe while the build that wrote
  the data is kept.

## More Information

[0005](0005-pr-flow.md) for the PR flow the previews attach to.
