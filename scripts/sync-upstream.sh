#!/usr/bin/env bash
# Merge the latest Moonlight V+ upstream into the Material 3 branch.
# See docs/M3_DESIGN_SYSTEM.md for conflict guidance.
set -euo pipefail

BASE_BRANCH="${BASE_BRANCH:-m3-redesign}"
UPSTREAM_BRANCH="${UPSTREAM_BRANCH:-master}"
UPSTREAM_URL="${UPSTREAM_URL:-https://github.com/qiin2333/moonlight-vplus.git}"
SYNC_BRANCH="${SYNC_BRANCH:-automation/upstream-sync}"
PUSH="${PUSH:-0}"

cd "$(dirname "$0")/.."

if [[ -n "$(git status --porcelain)" ]]; then
  echo "Working tree is dirty. Commit or stash changes first." >&2
  exit 1
fi

if ! git remote get-url upstream >/dev/null 2>&1; then
  git remote add upstream "$UPSTREAM_URL"
else
  git remote set-url upstream "$UPSTREAM_URL"
fi

git fetch --prune upstream "$UPSTREAM_BRANCH"

if ! git show-ref --verify --quiet "refs/heads/$BASE_BRANCH"; then
  echo "Base branch '$BASE_BRANCH' does not exist." >&2
  exit 1
fi

git switch -C "$SYNC_BRANCH" "$BASE_BRANCH"

UPSTREAM_REF="upstream/$UPSTREAM_BRANCH"
BEHIND="$(git rev-list --count "HEAD..$UPSTREAM_REF")"
if [[ "$BEHIND" == "0" ]]; then
  echo "Already up to date with $UPSTREAM_REF."
  exit 0
fi

echo "Merging $UPSTREAM_REF ($BEHIND commit(s))..."
if ! git merge --no-edit "$UPSTREAM_REF"; then
  echo "" >&2
  echo "Merge conflict. Resolve the conflicts, then run:" >&2
  echo "  git add <files> && git commit" >&2
  echo "  pwsh -File scripts/check-m3-tokens.ps1" >&2
  echo "  git push -u origin $SYNC_BRANCH" >&2
  exit 2
fi

if command -v pwsh >/dev/null 2>&1; then
  pwsh -NoProfile -File scripts/check-m3-tokens.ps1
elif command -v powershell.exe >/dev/null 2>&1; then
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File scripts/check-m3-tokens.ps1
else
  echo "PowerShell not found; skipping the token consistency check." >&2
fi

git diff --stat "$BASE_BRANCH..HEAD"

if [[ "$PUSH" == "1" ]]; then
  git push --force-with-lease -u origin "$SYNC_BRANCH"
fi
