#!/bin/bash
# ~/bin/sync-dotfiles.sh

DOTFILES="$HOME/git/personal/dotfiles"
LOG="$HOME/.cache/log/cron.log"

# Change dir
cd "$DOTFILES" || {
  echo "$(date) - ERROR: Cannot cd to $DOTFILES" >>"$LOG"
  exit 1
}

# Check if repositoriy is git
if ! git rev-parse --git-dir >/dev/null 2>&1; then
  echo "$(date) - ERROR: Not a git repository" >>"$LOG"
  exit 1
fi

# Save list
CHANGES_BEFORE=$(git status --porcelain)

# Add changes
git add -A

# Check commit
if git diff --cached --quiet; then
  echo "$(date) - No changes to commit" >>"$LOG"
  exit 0
fi

# Commit
if git commit -m "Sync $(date +%Y-%m-%d)"; then
  COMMIT_STATUS="OK"
else
  COMMIT_STATUS="FAILED"
fi

# Push
if git push origin main; then
  PUSH_STATUS="OK"
else
  PUSH_STATUS="FAILED"
fi

# Logs
{
  echo "---"
  echo "$(date) - Sync attempt"
  echo "Changes before add:"
  echo "$CHANGES_BEFORE"
  echo "Commit status: $COMMIT_STATUS"
  echo "Push status: $PUSH_STATUS"
  echo "---"
} >>"$LOG"
