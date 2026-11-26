#!/bin/sh
# Writes docs/agents-shared.md between the shared markers of each repo's
# AGENTS.md. With --check, rewrites nothing and exits 1 on any difference.
#
#   scripts/sync-agents.sh [--check] <repo-dir>...
set -eu

START='<!-- shared:start -->'
END='<!-- shared:end -->'
SHARED="$(cd "$(dirname "$0")/.." && pwd)/docs/agents-shared.md"

check=0
if [ "${1:-}" = "--check" ]; then
  check=1
  shift
fi
[ $# -gt 0 ] || { echo "usage: $0 [--check] <repo-dir>..." >&2; exit 2; }

status=0
for repo in "$@"; do
  file="$repo/AGENTS.md"
  if [ ! -f "$file" ]; then
    echo "[sync-agents] $file: missing" >&2
    status=1
    continue
  fi
  starts=$(grep -cxF "$START" "$file" || true)
  ends=$(grep -cxF "$END" "$file" || true)
  if [ "$starts" != 1 ] || [ "$ends" != 1 ]; then
    echo "[sync-agents] $file: needs exactly one '$START' and one '$END' line" >&2
    status=1
    continue
  fi

  # Everything up to the start marker, the shared text, everything from the end marker.
  tmp=$(mktemp)
  awk -v start="$START" -v end="$END" -v shared="$SHARED" '
    $0 == start { print; while ((getline line < shared) > 0) print line; skip = 1; next }
    $0 == end   { skip = 0 }
    !skip       { print }
  ' "$file" > "$tmp"

  if cmp -s "$tmp" "$file"; then
    rm "$tmp"
    echo "[sync-agents] $file: up to date"
  elif [ "$check" = 1 ]; then
    echo "[sync-agents] $file: shared block differs from docs/agents-shared.md" >&2
    diff -u "$file" "$tmp" >&2 || true
    rm "$tmp"
    status=1
  else
    cat "$tmp" > "$file"
    rm "$tmp"
    echo "[sync-agents] $file: rewritten"
  fi
done
exit $status
