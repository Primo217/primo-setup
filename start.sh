#!/usr/bin/env bash
# =============================================================================
# /start — Pull latest code for all repos
# Run this when you sit down to work on any computer.
# =============================================================================

set -euo pipefail

PROJECTS_DIR="$(cd "$(dirname "$0")/.." && pwd)"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo ""
echo "=== Good morning! Pulling all repos... ==="
echo ""

updated=0
already_current=0
errors=0

for dir in "$PROJECTS_DIR"/*/; do
  [ -d "$dir/.git" ] || continue
  repo="$(basename "$dir")"

  echo -n "$repo — "

  output=$(cd "$dir" && git pull 2>&1)

  if echo "$output" | grep -q "Already up to date"; then
    echo -e "${GREEN}up to date${NC}"
    already_current=$((already_current + 1))
  elif echo "$output" | grep -q "error\|fatal\|CONFLICT"; then
    echo -e "${RED}ERROR${NC}"
    echo "  $output"
    errors=$((errors + 1))
  else
    echo -e "${YELLOW}updated${NC}"
    updated=$((updated + 1))
  fi
done

echo ""
echo "=== Ready to work ==="
echo "  Updated:    $updated repos"
echo "  Up to date: $already_current repos"
[ $errors -gt 0 ] && echo -e "  ${RED}Errors:     $errors repos (check above)${NC}"
echo ""
