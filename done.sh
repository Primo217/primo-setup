#!/usr/bin/env bash
# =============================================================================
# /done — Commit and push all repos that have changes
# Run this when you're done working for the day.
# =============================================================================

set -euo pipefail

PROJECTS_DIR="$(cd "$(dirname "$0")/.." && pwd)"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo ""
echo "=== Wrapping up — saving all your work... ==="
echo ""

pushed=0
clean=0
errors=0

for dir in "$PROJECTS_DIR"/*/; do
  [ -d "$dir/.git" ] || continue
  repo="$(basename "$dir")"

  cd "$dir"

  # Check if there are any changes (staged, unstaged, or untracked)
  if [ -z "$(git status --porcelain)" ]; then
    echo -e "$repo — ${GREEN}clean${NC}"
    clean=$((clean + 1))
    continue
  fi

  # Show what changed
  changed=$(git status --porcelain | wc -l | tr -d ' ')
  echo -e "$repo — ${YELLOW}$changed file(s) changed${NC}"

  # Stage everything
  git add .

  # Commit with a simple timestamp message
  timestamp=$(date +"%Y-%m-%d %H:%M")
  branch=$(git branch --show-current)
  git commit -m "Work in progress — $timestamp" --quiet

  # Push
  if git push --quiet 2>/dev/null; then
    echo -e "  ${GREEN}pushed to $branch${NC}"
    pushed=$((pushed + 1))
  else
    echo -e "  ${YELLOW}committed locally (push failed — you may need to pull first)${NC}"
    errors=$((errors + 1))
  fi
done

echo ""
echo "=== Done for the day ==="
echo "  Pushed:  $pushed repos"
echo "  Clean:   $clean repos (no changes)"
[ $errors -gt 0 ] && echo "  Issues:  $errors repos (committed locally, push next time)"
echo ""
echo "Your work is saved. See you next time!"
echo ""
