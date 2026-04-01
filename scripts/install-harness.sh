#!/usr/bin/env bash
# install-harness.sh
#
# 대상 프로젝트 이름으로 harness-collections에 브랜치 + git worktree를 생성하고,
# worktree 경로를 절대 경로 symlink로 대상 프로젝트의 .claude/에 연결한다.
#
# 사용법:
#   bash /path/to/harness-collections/scripts/install-harness.sh [OPTIONS]
#
# Options:
#   --force     기존 symlink를 덮어쓴다
#   --dry-run   실제 변경 없이 수행될 작업을 출력한다
#   --gitignore .gitignore에 .claude/ 예외 패턴을 자동 추가한다
#
# 구조:
#   harness-collections/worktrees/<project-name>/  ← worktree (<project-name> 브랜치)
#   <project>/.claude/skills/<skill>  →  worktrees/<project-name>/claude-skills/<skill>/
#   <project>/.claude/agents/<agent>.md  →  worktrees/<project-name>/claude-agents/<agent>/AGENT.md

set -euo pipefail

# ── 색상 ──────────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'
BOLD='\033[1m'; RESET='\033[0m'

info()    { echo -e "  ${BLUE}•${RESET} $*"; }
success() { echo -e "  ${GREEN}✓${RESET} $*"; }
skip()    { echo -e "  ${YELLOW}–${RESET} $*"; }
warn()    { echo -e "  ${RED}!${RESET} $*"; }
die()     { echo -e "\n  ${RED}ERROR:${RESET} $*\n"; exit 1; }

# ── 옵션 파싱 ─────────────────────────────────────────────────────────────────
FORCE=false
DRY_RUN=false
UPDATE_GITIGNORE=false

for arg in "$@"; do
  case "$arg" in
    --force)      FORCE=true ;;
    --dry-run)    DRY_RUN=true ;;
    --gitignore)  UPDATE_GITIGNORE=true ;;
    --help|-h)
      sed -n '3,14p' "$0" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    *) die "알 수 없는 옵션: $arg" ;;
  esac
done

# ── 경로 결정 ─────────────────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HARNESS_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TARGET_DIR="$(pwd)"
PROJECT_NAME="$(basename "$TARGET_DIR")"
WORKTREE_DIR="$HARNESS_ROOT/worktrees/$PROJECT_NAME"

# harness-collections 안에서 실행 방지
if [ "$TARGET_DIR" = "$HARNESS_ROOT" ]; then
  die "현재 디렉토리가 harness-collections 자체입니다. 설치할 프로젝트 루트로 이동 후 실행하세요."
fi

# ── 헤더 ──────────────────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}harness-collections installer${RESET}"
echo -e "  Harness : ${BLUE}${HARNESS_ROOT}${RESET}"
echo -e "  Project : ${BLUE}${TARGET_DIR}${RESET}"
echo -e "  Branch  : ${BLUE}${PROJECT_NAME}${RESET}"
echo -e "  Worktree: ${BLUE}${WORKTREE_DIR}${RESET}"
$DRY_RUN && echo -e "  ${YELLOW}[DRY RUN — 실제 변경 없음]${RESET}"
echo ""

# ── Worktree 준비 ─────────────────────────────────────────────────────────────
echo -e "${BOLD}Worktree${RESET}"

if [ -d "$WORKTREE_DIR" ]; then
  skip "worktree  already exists: worktrees/$PROJECT_NAME"
else
  # 브랜치가 이미 있는지 확인
  BRANCH_EXISTS=false
  if git -C "$HARNESS_ROOT" show-ref --verify --quiet "refs/heads/$PROJECT_NAME"; then
    BRANCH_EXISTS=true
  fi

  if $DRY_RUN; then
    if $BRANCH_EXISTS; then
      info "worktree  (skip branch creation — '$PROJECT_NAME' already exists)"
    else
      info "branch    git branch $PROJECT_NAME"
    fi
    info "worktree  git worktree add worktrees/$PROJECT_NAME $PROJECT_NAME"
  else
    $DRY_RUN || mkdir -p "$HARNESS_ROOT/worktrees"
    if $BRANCH_EXISTS; then
      info "branch    '$PROJECT_NAME' already exists, reusing"
    fi
    git -C "$HARNESS_ROOT" worktree add "$WORKTREE_DIR" \
      $($BRANCH_EXISTS && echo "$PROJECT_NAME" || echo "-b $PROJECT_NAME") \
      2>/dev/null
    success "worktree  worktrees/$PROJECT_NAME  (branch: $PROJECT_NAME)"
  fi
fi
echo ""

# SOURCE는 worktree 경로를 기준으로 한다
LINK_SOURCE="$WORKTREE_DIR"

# ── 헬퍼: symlink 생성 ────────────────────────────────────────────────────────
make_link() {
  local src="$1"
  local dest="$2"

  if [ -L "$dest" ]; then
    if $FORCE; then
      $DRY_RUN || ln -sf "$src" "$dest"
      success "updated  $(basename "$dest")"
    else
      skip "exists   $(basename "$dest")  (--force로 덮어쓸 수 있음)"
    fi
  elif [ -e "$dest" ]; then
    warn "conflict $(basename "$dest")  (symlink 아닌 파일/디렉토리가 이미 존재)"
  else
    $DRY_RUN || ln -s "$src" "$dest"
    success "linked   $(basename "$dest")"
  fi
}

# ── Skills 설치 ───────────────────────────────────────────────────────────────
echo -e "${BOLD}Skills${RESET}"
$DRY_RUN || mkdir -p "$TARGET_DIR/.claude/skills"

skill_count=0
for skill_dir in "$HARNESS_ROOT/claude-skills"/*/; do
  [ -f "$skill_dir/SKILL.md" ] || continue
  skill_name="$(basename "$skill_dir")"
  make_link "$LINK_SOURCE/claude-skills/$skill_name" "$TARGET_DIR/.claude/skills/$skill_name"
  (( skill_count++ )) || true
done
echo ""

# ── Agents 설치 ───────────────────────────────────────────────────────────────
echo -e "${BOLD}Agents${RESET}"
$DRY_RUN || mkdir -p "$TARGET_DIR/.claude/agents"

agent_count=0
for agent_dir in "$HARNESS_ROOT/claude-agents"/*/; do
  agent_dir="${agent_dir%/}"
  agent_name="$(basename "$agent_dir")"
  [ -f "$agent_dir/AGENT.md" ] || continue
  make_link "$LINK_SOURCE/claude-agents/$agent_name/AGENT.md" \
            "$TARGET_DIR/.claude/agents/$agent_name.md"
  (( agent_count++ )) || true
done
echo ""

# ── .gitignore 업데이트 ───────────────────────────────────────────────────────
if $UPDATE_GITIGNORE; then
  GITIGNORE="$TARGET_DIR/.gitignore"
  MARKER="# harness: .claude/skills·agents는 symlink이므로 추적"

  if [ -f "$GITIGNORE" ] && grep -q "$MARKER" "$GITIGNORE"; then
    skip ".gitignore  harness 패턴이 이미 존재함"
  else
    echo -e "${BOLD}.gitignore${RESET}"
    if $DRY_RUN; then
      info "추가 예정:"
      echo "    $MARKER"
      echo "    .claude/*"
      echo "    !.claude/skills/"
      echo "    !.claude/agents/"
    else
      {
        echo ""
        echo "$MARKER"
        echo ".claude/*"
        echo "!.claude/skills/"
        echo "!.claude/agents/"
      } >> "$GITIGNORE"
      success ".gitignore  harness 예외 패턴 추가됨"
    fi
    echo ""
  fi
fi

# ── 완료 요약 ─────────────────────────────────────────────────────────────────
echo -e "${BOLD}완료${RESET}"
info "Branch  : $PROJECT_NAME"
info "Worktree: harness-collections/worktrees/$PROJECT_NAME"
info "Skills  : ${skill_count}개  →  .claude/skills/"
info "Agents  : ${agent_count}개  →  .claude/agents/"
echo ""
echo -e "  이 프로젝트 전용 harness를 수정하려면:"
echo -e "    ${BLUE}cd ${WORKTREE_DIR}${RESET}  (${PROJECT_NAME} 브랜치)"
echo ""
echo -e "  main의 변경을 이 worktree에 반영하려면:"
echo -e "    ${BLUE}cd ${WORKTREE_DIR} && git merge main${RESET}"
echo ""
