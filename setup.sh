#!/usr/bin/env bash
# =============================================================================
# Primo Designs — Dev Environment Setup
# Clones all repos and installs dependencies in one shot.
#
# Usage (on any new machine):
#   gh auth login
#   git clone https://github.com/Primo217/primo-setup.git ~/Projects/primo-setup
#   bash ~/Projects/primo-setup/setup.sh
# =============================================================================

set -euo pipefail

GITHUB_USER="Primo217"
PROJECTS_DIR="$(cd "$(dirname "$0")/.." && pwd)"

# All repos on GitHub
REPOS=(
  japan-trip-hub
  primo-os
  primo-lead-intelligence
  delivery-signature-app
  shopworks-cloud-functions
  custom-catalog
  primo-intake-app
  lead-reply-tracker
  email-intelligence
  email-monitor
  ask-tj
  shower-thoughts
)

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No color

info()  { echo -e "${GREEN}[OK]${NC} $1"; }
warn()  { echo -e "${YELLOW}[SKIP]${NC} $1"; }
fail()  { echo -e "${RED}[ERROR]${NC} $1"; }

# ---------------------------------------------------------------------------
# 1. Check prerequisites
# ---------------------------------------------------------------------------
echo ""
echo "=== Primo Designs Dev Setup ==="
echo "Projects directory: $PROJECTS_DIR"
echo ""

# Git
if ! command -v git &>/dev/null; then
  fail "git is not installed. Install it first: https://git-scm.com"
  exit 1
fi
info "git found ($(git --version))"

# GitHub CLI
if ! command -v gh &>/dev/null; then
  fail "GitHub CLI (gh) is not installed. Install it first: https://cli.github.com"
  exit 1
fi

# Check gh auth
if ! gh auth status &>/dev/null; then
  fail "Not logged into GitHub CLI. Run: gh auth login"
  exit 1
fi
info "GitHub CLI authenticated"

# Node.js (optional but recommended)
if command -v node &>/dev/null; then
  info "Node.js found ($(node --version))"
  HAS_NODE=true
else
  warn "Node.js not found — skipping npm install steps"
  HAS_NODE=false
fi

echo ""

# ---------------------------------------------------------------------------
# 2. Clone repos
# ---------------------------------------------------------------------------
cloned=0
skipped=0
failed=0
installed=0

for repo in "${REPOS[@]}"; do
  repo_dir="$PROJECTS_DIR/$repo"

  if [ -d "$repo_dir" ]; then
    warn "$repo — already exists, skipping clone"
    skipped=$((skipped + 1))
  else
    echo -n "Cloning $repo... "
    if git clone "https://github.com/$GITHUB_USER/$repo.git" "$repo_dir" --quiet 2>/dev/null; then
      info "$repo cloned"
      cloned=$((cloned + 1))
    else
      fail "$repo — clone failed"
      failed=$((failed + 1))
      continue
    fi
  fi

  # npm install if package.json exists
  if [ "$HAS_NODE" = true ] && [ -f "$repo_dir/package.json" ]; then
    echo -n "  Installing dependencies for $repo... "
    if (cd "$repo_dir" && npm install --silent 2>/dev/null); then
      info "done"
      installed=$((installed + 1))
    else
      warn "npm install had issues (you can retry manually)"
    fi
  fi
done

# ---------------------------------------------------------------------------
# 3. Summary
# ---------------------------------------------------------------------------
echo ""
echo "=== Setup Complete ==="
echo "  Cloned:    $cloned"
echo "  Skipped:   $skipped (already existed)"
echo "  Failed:    $failed"
echo "  npm installs: $installed"
echo ""
echo "Your projects are in: $PROJECTS_DIR"
echo ""
echo "Quick start:"
echo "  cd $PROJECTS_DIR/<project-name>"
echo "  git pull          # get latest changes"
echo "  code .            # open in VS Code"
echo ""
echo "See GIT-CHEAT-SHEET.md in this folder for the basics."
echo ""
