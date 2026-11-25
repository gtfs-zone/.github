---
status: accepted
date: 2026-11-23
---

# sites.gtfs.zone replaces list.gtfs.zone

## Context and Problem Statement

list.gtfs.zone (gtfs-zone-feed-list) is a client app over the catalog
artifacts: a list, a map and a page per feed. timetable-sites builds a
static site per feed from the schedule itself. Two public front ends showed
the same feeds with different pages, names and search. Which one stays?

## Considered Options

- Keep both
- Keep list.gtfs.zone, link to sites from it
- sites.gtfs.zone takes over every catalog feed; list.gtfs.zone redirects

## Decision Outcome

Chosen option: sites takes over.

- Every catalog feed gets a sites page. The root and country pages keep the
  choropleth (no clustered feed points) and get client-side search over the
  catalog.
- feed-catalog keeps the inventory and its JSON artifacts, and stops writing
  per-feed HTML and the sitemap; sites owns every page.
- list.gtfs.zone is retired after a feature-by-feature check against it.
  infra keeps only redirects: `/feed/<id>/<slug>` to `/<slug>/` (301),
  `#feed=<id>` through `slugs.json`, everything else to the sites root.
- The `gtfs-zone-feed-list` repo's `main` is now the catalog data mirror;
  the old app lives on its `old-main` branch.
- web-common keeps `feed-catalog`, `feed-badges` and `feed-search`, which the
  editor and viewers still use.

### Consequences

- Good, because there is one public page per feed, built from its data.
- Good, because pages work without JavaScript and can be indexed.
- Bad, because the list's live client-side filters must be rebuilt in sites
  or dropped, which the feature check decides one by one.
- Bad, because the retirement waits on every inbound link (crimes, the
  editor, the viewer) moving to sites.

## More Information

Tracked as Phase 7 in timetable-sites' `SITES_PLAN.md` (7d redirects).
