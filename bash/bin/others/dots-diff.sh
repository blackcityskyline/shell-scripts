#!/bin/bash
# ~/bin/dotfiles-diff.sh
# Usage:
#   dotfiles-diff.sh           — show status only (no diff)
#   dotfiles-diff.sh --diff    — show status + full diff
#   dotfiles-diff.sh --sync    — copy changed files from system to repo

USER_HOME="/home/black"
DOTFILES="$USER_HOME/git/personal/dotfiles"
SHOW_DIFF=false
SYNC=false
[[ "$1" == "--diff" ]] && SHOW_DIFF=true
[[ "$1" == "--sync" ]] && SYNC=true

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

declare -A ROOTS=(
  [".config"]="$USER_HOME/.config"
  [".local"]="$USER_HOME/.local"
  [".themes"]="$USER_HOME/.themes"
  ["bin"]="$USER_HOME/bin"
  ["usr"]="/usr"
  ["etc"]="/etc"
)

declare -A FILES=(
  [".bashrc"]="$USER_HOME/.bashrc"
)

CHANGED=()
MISSING_IN_SYSTEM=()

echo -e "${BOLD}=== dotfiles diff ===${NC}"
echo -e "repo: ${CYAN}$DOTFILES${NC}\n"

# -------------------------------------------------------
# Сравнение одного файла
# -------------------------------------------------------
check_file() {
  local REPO_FILE="$1"
  local SYS_FILE="$2"

  if ! sudo test -e "$SYS_FILE" 2>/dev/null; then
    MISSING_IN_SYSTEM+=("$REPO_FILE|$SYS_FILE")
  elif ! sudo diff -q "$REPO_FILE" "$SYS_FILE" &>/dev/null 2>&1; then
    CHANGED+=("$REPO_FILE|$SYS_FILE")
  fi
}

# -------------------------------------------------------
# Обход репозитория
# -------------------------------------------------------
for REPO_REL in "${!ROOTS[@]}"; do
  REPO_ROOT="$DOTFILES/$REPO_REL"
  SYS_ROOT="${ROOTS[$REPO_REL]}"
  [[ ! -d "$REPO_ROOT" ]] && continue
  while IFS= read -r -d '' REPO_FILE; do
    REL="${REPO_FILE#$REPO_ROOT/}"
    SYS_FILE="$SYS_ROOT/$REL"
    check_file "$REPO_FILE" "$SYS_FILE"
  done < <(find "$REPO_ROOT" -type f -print0 2>/dev/null)
done

for FILE_REL in "${!FILES[@]}"; do
  REPO_FILE="$DOTFILES/$FILE_REL"
  SYS_FILE="${FILES[$FILE_REL]}"
  [[ -f "$REPO_FILE" ]] && check_file "$REPO_FILE" "$SYS_FILE"
done

# -------------------------------------------------------
# Вывод изменённых
# -------------------------------------------------------
if [[ ${#CHANGED[@]} -gt 0 ]]; then
  echo -e "${YELLOW}${BOLD}modified:${NC}"
  for ENTRY in "${CHANGED[@]}"; do
    REPO_FILE="${ENTRY%%|*}"
    SYS_FILE="${ENTRY##*|}"
    REL="${SYS_FILE/$USER_HOME/~}"
    echo -e "  ${YELLOW}~${NC} $REL"
    if $SHOW_DIFF; then
      sudo diff --color=always -u "$REPO_FILE" "$SYS_FILE" 2>/dev/null | tail -n +3
      echo ""
    fi
  done
  echo ""
else
  echo -e "${GREEN}nothing changed${NC}\n"
fi

# -------------------------------------------------------
# Вывод отсутствующих
# -------------------------------------------------------
if [[ ${#MISSING_IN_SYSTEM[@]} -gt 0 ]]; then
  echo -e "${RED}${BOLD}missing in system:${NC}"
  for ENTRY in "${MISSING_IN_SYSTEM[@]}"; do
    SYS_FILE="${ENTRY##*|}"
    REL="${SYS_FILE/$USER_HOME/~}"
    echo -e "  ${RED}-${NC} $REL"
  done
  echo ""
fi

# -------------------------------------------------------
# Status
# -------------------------------------------------------
TOTAL_FILES=0
for REPO_REL in "${!ROOTS[@]}"; do
  REPO_ROOT="$DOTFILES/$REPO_REL"
  [[ ! -d "$REPO_ROOT" ]] && continue
  COUNT=$(find "$REPO_ROOT" -type f 2>/dev/null | wc -l)
  TOTAL_FILES=$(( TOTAL_FILES + COUNT ))
done
for FILE_REL in "${!FILES[@]}"; do
  [[ -f "$DOTFILES/$FILE_REL" ]] && TOTAL_FILES=$(( TOTAL_FILES + 1 ))
done
SYNCED=$(( TOTAL_FILES - ${#CHANGED[@]} - ${#MISSING_IN_SYSTEM[@]} ))

echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}  dotfiles / status${NC}"
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "  checked       ${BOLD}${TOTAL_FILES}${NC} files"
echo -e "  up to date    ${GREEN}${SYNCED} ✓${NC}"
echo -e "  modified      ${YELLOW}${#CHANGED[@]} ~${NC}"
echo -e "  missing       ${RED}${#MISSING_IN_SYSTEM[@]} ✗${NC}"
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if [[ ${#CHANGED[@]} -gt 0 ]]; then
  $SHOW_DIFF || echo -e "\n  ${CYAN}tip: run with --diff to see changes${NC}"
  echo -e "  ${YELLOW}run with --sync to update repo${NC}"
elif [[ ${#MISSING_IN_SYSTEM[@]} -eq 0 ]]; then
  echo -e "\n  ${GREEN}everything is up to date${NC}"
fi
echo ""

# -------------------------------------------------------
# Sync
# -------------------------------------------------------
if $SYNC; then
  if [[ ${#CHANGED[@]} -eq 0 ]]; then
    echo -e "${GREEN}nothing to sync${NC}"
    exit 0
  fi

  echo -e "${BOLD}syncing to repo...${NC}"
  for ENTRY in "${CHANGED[@]}"; do
    REPO_FILE="${ENTRY%%|*}"
    SYS_FILE="${ENTRY##*|}"
    sudo cp "$SYS_FILE" "$REPO_FILE"
    REL="${SYS_FILE/$USER_HOME/~}"
    echo -e "  ${YELLOW}↻${NC} $REL"
  done

  echo -e "\n${GREEN}done. run sync-dotfiles.sh to push${NC}"
fi
