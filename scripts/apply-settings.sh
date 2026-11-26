#!/bin/sh
# Applies the shared settings to the gtfs-zone repos.
#
# Every repo that is not a fork or archived: merge commits only, head
# branches deleted on merge. Each repo in settings/rulesets.json also gets the
# "main" ruleset on its default branch: PR required (no approval, merge
# commit only), no force push or deletion, and its listed checks required.
# The gtfs-zone-release GitHub App bypasses the ruleset so release.yml can
# push the bump commit and tag; while the app does not exist, the ruleset has
# no bypass actor. With --dry-run, prints each request instead of sending.
#
#   scripts/apply-settings.sh [--dry-run]
set -eu

ORG=gtfs-zone
RULESET_NAME=main
RELEASE_APP_SLUG=gtfs-zone-release
# GitHub Actions app: the source the required checks must come from.
ACTIONS_APP_ID=15368
RULESETS="$(cd "$(dirname "$0")/.." && pwd)/settings/rulesets.json"

dry=0
if [ "${1:-}" = "--dry-run" ]; then
  dry=1
  shift
fi
[ $# -eq 0 ] || { echo "usage: $0 [--dry-run]" >&2; exit 2; }

# Sends stdin as the JSON body: send <method> <path>
send() {
  if [ "$dry" = 1 ]; then
    echo "[apply-settings] $1 $2"
    jq -c .
  else
    gh api -X "$1" "$2" --input - > /dev/null
    echo "[apply-settings] $1 $2: done"
  fi
}

repo_settings() {
  jq -n '{
    allow_merge_commit: true,
    allow_squash_merge: false,
    allow_rebase_merge: false,
    delete_branch_on_merge: true
  }'
}

# Ruleset body for one repo: ruleset <repo>
ruleset() {
  jq --arg repo "$1" --arg name "$RULESET_NAME" --argjson app "$ACTIONS_APP_ID" \
    --argjson bypass "$bypass" '{
    name: $name,
    target: "branch",
    enforcement: "active",
    conditions: { ref_name: { include: ["~DEFAULT_BRANCH"], exclude: [] } },
    bypass_actors: $bypass,
    rules: [
      { type: "deletion" },
      { type: "non_fast_forward" },
      { type: "pull_request", parameters: {
          required_approving_review_count: 0,
          dismiss_stale_reviews_on_push: false,
          require_code_owner_review: false,
          require_last_push_approval: false,
          required_review_thread_resolution: false,
          allowed_merge_methods: ["merge"] } },
      { type: "required_status_checks", parameters: {
          strict_required_status_checks_policy: false,
          do_not_enforce_on_create: false,
          required_status_checks: [.[$repo][] | { context: ., integration_id: $app }] } }
    ]
  }' "$RULESETS"
}

if release_app_id=$(gh api "apps/$RELEASE_APP_SLUG" --jq .id 2> /dev/null); then
  bypass=$(jq -n --argjson id "$release_app_id" \
    '[{ actor_id: $id, actor_type: "Integration", bypass_mode: "always" }]')
else
  echo "[apply-settings] warning: app $RELEASE_APP_SLUG not found, rulesets get no bypass actor" >&2
  bypass='[]'
fi

for repo in $(gh repo list "$ORG" --limit 200 --source --no-archived --json name --jq '.[].name'); do
  repo_settings | send PATCH "repos/$ORG/$repo"
done

for repo in $(jq -r 'keys[]' "$RULESETS"); do
  id=$(gh api "repos/$ORG/$repo/rulesets?includes_parents=false" \
    --jq ".[] | select(.name == \"$RULESET_NAME\") | .id")
  if [ -n "$id" ]; then
    ruleset "$repo" | send PUT "repos/$ORG/$repo/rulesets/$id"
  else
    ruleset "$repo" | send POST "repos/$ORG/$repo/rulesets"
  fi
done
