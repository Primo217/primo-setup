#!/usr/bin/env bash
# =============================================================================
# /done — Save all your work and go home
#
# This does EVERYTHING automatically:
#   1. Finds every repo in your Projects folder
#   2. If a repo has changes, commits and pushes them
#   3. If a repo is brand new (no GitHub remote), creates the GitHub repo for you
#   4. Skips repos with no changes
#
# Just run it. Everything gets saved.
# =============================================================================

set -uo pipefail

GITHUB_USER="Primo217"
PROJECTS_DIR="$(cd "$(dirname "$0")/.." && pwd)"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo ""
echo "========================================="
echo "  Primo Designs — Saving Your Work"
echo "========================================="
echo ""

pushed=0
clean=0
new_repos=0
errors=0

for dir in "$PROJECTS_DIR"/*/; do
  [ -d "$dir" ] || continue
  repo="$(basename "$dir")"

  # --- NOT A GIT REPO YET: init and push to GitHub ---
  if [ ! -d "$dir/.git" ]; then
    # Skip non-project folders (no code files)
    if [ ! -f "$dir/package.json" ] && [ ! -f "$dir/index.html" ] && [ ! -f "$dir/README.md" ] && [ ! -f "$dir/main.py" ]; then
      continue
    fi

    echo -e "$repo — ${YELLOW}NEW PROJECT (not on GitHub yet)${NC}"
    echo -n "  Creating GitHub repo and pushing... "

    cd "$dir"
    git init --quiet
    git add .
    git commit -m "Initial commit" --quiet

    if gh repo create "$GITHUB_USER/$repo" --public --source=. --push --description "Primo Designs — $repo" &>/dev/null; then
      echo -e "${GREEN}done${NC}"
      new_repos=$((new_repos + 1))
    else
      echo -e "${RED}failed (you may need to create it manually)${NC}"
      errors=$((errors + 1))
    fi
    continue
  fi

  cd "$dir"

  # --- CLEAN REPO: nothing to do ---
  if [ -z "$(git status --porcelain)" ]; then
    echo -e "$repo — ${GREEN}clean${NC}"
    clean=$((clean + 1))
    continue
  fi

  # --- HAS CHANGES: commit and push ---
  changed=$(git status --porcelain | wc -l | tr -d ' ')
  branch=$(git branch --show-current)
  echo -e "$repo — ${YELLOW}$changed file(s) changed${NC}"

  git add .

  timestamp=$(date +"%Y-%m-%d %H:%M")
  git commit -m "Work in progress — $timestamp" --quiet

  if git push --quiet 2>/dev/null; then
    echo -e "  ${GREEN}pushed to $branch${NC}"
    pushed=$((pushed + 1))
  else
    # Maybe upstream isn't set — try setting it
    if git push --set-upstream origin "$branch" --quiet 2>/dev/null; then
      echo -e "  ${GREEN}pushed to $branch (set upstream)${NC}"
      pushed=$((pushed + 1))
    else
      echo -e "  ${YELLOW}committed locally (push failed — run start.sh then try again)${NC}"
      errors=$((errors + 1))
    fi
  fi
done

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
echo ""
echo "========================================="
echo "  All saved!"
echo "========================================="
echo "  Pushed:     $pushed repos"
echo "  No changes: $clean repos"
[ $new_repos -gt 0 ] && echo "  New on GitHub: $new_repos repos"
[ $errors -gt 0 ]    && echo -e "  ${RED}Issues:      $errors (check above)${NC}"
echo ""
echo "Your work is safe. See you next time!"
echo ""
