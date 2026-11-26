---
status: accepted
date: 2026-11-25
---

# One feed state and one naming rule, set by feed-catalog

## Context and Problem Statement

The list, the editor and the viewer each worked out a feed's state, name
and realtime URLs. They disagreed: a feed read "Down" because one catalog
row listed a typo URL while the right one answered, and a curated example
named a Maine agency after a French city. How is a feed's state and name
decided, and by whom?

## Decision Outcome

feed-catalog computes both once and publishes them in `feeds.json` and
`search.json`; the apps read them through web-common's `gtfs/feed-catalog`
and never compute their own.

- **Role state.** Each role (schedule, trip updates, vehicle positions,
  service alerts, untyped realtime) is up if any of its URLs answers.
- **Feed state.**
  - Down when the schedule is down
  - Partial when the schedule is up and a realtime role is down
  - Up otherwise
  - Inaccessible (`unknown`) when nothing could be checked
  - Without a checked schedule, the realtime roles decide
- **Wording.** "Down since `<date>`".
- **Name.** The first non-empty of, static rows first:
  1. Transitland operator
  2. Mobility Database provider, its "(feed_name)" moved to `subtitle`
  3. the schedule's single agency, else its `feed_info` publisher
  4. NTD agency
  5. any row's name
- **Aggregates** (many agencies) are not renamed; they are described by
  `agencies`, `agencyCount` and `overlaps`. There is no curated name or
  override file.
- **Untyped realtime.** A Mobility Database realtime URL with no declared
  entity types is role `realtime` (chip "RT"); a viewer fills the first
  empty slot in the order VP, TU, SA with it.
- Feeds served by rt.gtfs.zone itself come from its public `GET /feeds`, as
  catalog `gtfszone`.

### Consequences

- Good, because every app shows the same state, wording and name.
- Good, because a feed with one bad mirror URL is no longer down.
- Bad, because a wrong upstream name can only be fixed upstream.
