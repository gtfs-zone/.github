---
status: accepted
date: 2026-11-15
---

# One fetch per feed per day, in feed-catalog

## Context and Problem Statement

The catalog's endpoint check, timetable-sites, crimes, static-importer and
rt-archive each downloaded the same schedule zips on their own timers, each
with its own cache and validators, and two of them computed overlapping
facts from the same zip. Some hosts were hit several times a day in
parallel. Which component downloads a schedule, and how do the others get
it?

## Considered Options

- A: timetable-sites is the only downloader
- B: a fetch asset in feed-catalog, zips stored content-addressed in the
  object store
- C: B, on a shared volume instead of the object store

## Decision Outcome

Chosen option: B.

- feed-catalog fetches every static URL once a day with a conditional GET
  (ETag / Last-Modified, sha256 when the server sends neither), per-host
  politeness, and a size cap (`FETCH_MAX_BYTES`). The GET is also the URL's
  liveness check; HEAD stays for realtime URLs and zips over the cap.
- Zips go in the `gtfs-zips` bucket as `gtfs/<sha256>.zip`, indexed by
  normalized URL in `gtfs/index.json`. Only the latest version per URL is
  kept; rt-archive keeps its own history.
- Facts are computed once per sha256 (`gtfs/<sha256>.facts.json`) by the
  shared library
  [gtfs-zone-feed-fetch](https://github.com/gtfs-zone/gtfs-zone-feed-fetch),
  a git-tag dependency of every consumer. Fetch, store, zip and fact code
  lands there first, then a tag bump in each consumer.
- All dedup (same feed, overlap) happens in feed-catalog, where every feed
  is visible, and is published in `feeds.json` for every app.
- Consumers read zips from the store instead of downloading them.

### Consequences

- Good, because a feed is downloaded at most once a day, and not at all
  when the server answers 304.
- Good, because politeness, size limits and facts live in one place.
- Good, because facts exist for feeds too big for a site build.
- Bad, because the store (about 15 to 17 GB of current versions) shares a
  fixed volume with pages and snapshots, and the cap rises only with it.
- Bad, because consumers depend on the catalog run finishing first.
