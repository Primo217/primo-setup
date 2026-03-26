#!/usr/bin/env bash
# =============================================================================
# /start — Get everything ready for work
#
# This does EVERYTHING automatically:
#   1. Checks git & GitHub CLI are installed and logged in
#   2. Fetches your LIVE repo list from GitHub (catches new projects)
#   3. Clones any repos you don't have yet
#   4. Installs npm dependencies for new clones
#   5. Pulls latest code for all existing repos
#
# Just run it. It figures out the rest.
# =============================================================================

set -euo pipefail

GITHUB_USER="Primo217"
PROJECTS_DIR="$(cd "$(dirname "$0")/.." && pwd)"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info() { echo -e "${GREEN}[OK]${NC} $1"; }
warn() { echo -e "${YELLOW}[SKIP]${NC} $1"; }
fail() { echo -e "${RED}[ERROR]${NC} $1"; }

echo ""
echo "========================================="
echo "  Primo Designs — Starting Up"
echo "========================================="
echo "Projects: $PROJECTS_DIR"
echo ""

# ---------------------------------------------------------------------------
# 1. Check prerequisites
# ---------------------------------------------------------------------------
if ! command -v git &>/dev/null; then
  fail "git is not installed. Get it: https://git-scm.com"
  exit 1
fi
info "git found"

if ! command -v gh &>/dev/null; then
  fail "GitHub CLI not installed. Get it: https://cli.github.com"
  exit 1
fi

if ! gh auth status &>/dev/null; then
  fail "Not logged into GitHub. Run: gh auth login"
  exit 1
fi
info "GitHub authenticated"

HAS_NODE=false
if command -v node &>/dev/null; then
  info "Node.js found ($(node --version))"
  HAS_NODE=true
fi

echo ""

# ---------------------------------------------------------------------------
# 2. Fetch live repo list from GitHub (no hardcoded list!)
# ---------------------------------------------------------------------------
echo "Checking your GitHub for repos..."
REPOS=$(gh repo list "$GITHUB_USER" --limit 100 --json name --jq '.[].name' 2>/dev/null)

if [ -z "$REPOS" ]; then
  fail "Could not fetch repo list from GitHub"
  exit 1
fi

repo_count=$(echo "$REPOS" | wc -l | tr -d ' ')
info "Found $repo_count repos on GitHub"
echo ""

# ---------------------------------------------------------------------------
# 3. Clone new repos + pull existing ones
# ---------------------------------------------------------------------------
cloned=0
updated=0
already_current=0
npm_installed=0
errors=0

for repo in $REPOS; do
  repo_dir="$PROJECTS_DIR/$repo"

  # --- NEW REPO: clone it ---
  if [ ! -d "$repo_dir" ]; then
    echo -n "NEW: Cloning $repo... "
    if git clone "https://github.com/$GITHUB_USER/$repo.git" "$repo_dir" --quiet 2>/dev/null; then
      info "$repo cloned"
      cloned=$((cloned + 1))

      # Install npm dependencies if applicable
      if [ "$HAS_NODE" = true ] && [ -f "$repo_dir/package.json" ]; then
        echo -n "  Installing dependencies... "
        if (cd "$repo_dir" && npm install --silent 2>/dev/null); then
          info "done"
          npm_installed=$((npm_installed + 1))
        else
          warn "npm install had issues (retry manually)"
        fi
      fi
    else
      fail "$repo — clone failed"
      errors=$((errors + 1))
    fi
    continue
  fi

  # --- EXISTING REPO: pull latest ---
  echo -n "$repo — "
  output=$(cd "$repo_dir" && git pull 2>&1)

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

# ---------------------------------------------------------------------------
# 4. Summary
# ---------------------------------------------------------------------------
echo ""
echo "========================================="
echo "  Ready to work!"
echo "========================================="
[ $cloned -gt 0 ]          && echo "  New repos cloned: $cloned"
[ $npm_installed -gt 0 ]   && echo "  npm installs:     $npm_installed"
[ $updated -gt 0 ]         && echo "  Repos updated:    $updated"
echo "  Already current:  $already_current"
[ $errors -gt 0 ]          && echo -e "  ${RED}Errors:           $errors (check above)${NC}"
echo ""
