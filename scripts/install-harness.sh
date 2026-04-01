#!/usr/bin/env bash
# install-harness.sh
#
# harness-collections의 skills와 agents를 현재 프로젝트에 절대 경로 symlink로 연결한다.
# harness-collections를 git pull하면 연결된 모든 프로젝트에 자동 반영된다.
#
# 사용법:
#   bash /path/to/harness-collections/scripts/install-harness.sh [OPTIONS]
#
# Options:
#   --force     기존 symlink를 덮어쓴다
#   --dry-run   실제 변경 없이 수행될 작업을 출력한다
#   --gitignore .gitignore에 .claude/ 예외 패턴을 자동 추가한다

set -euo pipefail

# ── 색상 ──────────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'
BOLD='\033[1m'; RESET='\033[0m'

info()    { echo -e "  ${BLUE}•${RESET} $*"; }
success() { echo -e "  ${GREEN}✓${RESET} $*"; }
skip()    { echo -e "  ${YELLOW}–${RESET} $*"; }
warn()    { echo -e "  ${RED}!${RESET} $*"; }

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
      sed -n '3,12p' "$0" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    *) warn "알 수 없는 옵션: $arg"; exit 1 ;;
  esac
done

# ── 경로 결정 ─────────────────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HARNESS_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TARGET_DIR="$(pwd)"

# harness-collections 안에서 실행하면 경고
if [ "$TARGET_DIR" = "$HARNESS_ROOT" ]; then
  warn "현재 디렉토리가 harness-collections 자체입니다."
  warn "설치할 대상 프로젝트 루트로 이동한 뒤 실행하세요."
  exit 1
fi

# ── 헤더 ──────────────────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}harness-collections installer${RESET}"
echo -e "  Source : ${BLUE}${HARNESS_ROOT}${RESET}"
echo -e "  Target : ${BLUE}${TARGET_DIR}${RESET}"
$DRY_RUN && echo -e "  ${YELLOW}[DRY RUN — 실제 변경 없음]${RESET}"
echo ""

# ── 헬퍼: symlink 생성 ────────────────────────────────────────────────────────
make_link() {
  local src="$1"   # 절대 경로 (harness-collections 내)
  local dest="$2"  # 생성할 symlink 경로

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
  make_link "$skill_dir" "$TARGET_DIR/.claude/skills/$skill_name"
  (( skill_count++ )) || true
done
echo ""

# ── Agents 설치 ───────────────────────────────────────────────────────────────
echo -e "${BOLD}Agents${RESET}"
$DRY_RUN || mkdir -p "$TARGET_DIR/.claude/agents"

agent_count=0
for agent_dir in "$HARNESS_ROOT/claude-agents"/*/; do
  agent_dir="${agent_dir%/}"   # trailing slash 제거
  agent_name="$(basename "$agent_dir")"
  agent_file="$agent_dir/AGENT.md"
  # AGENT.md 없는 디렉토리(예: project-manager/SPEC.md만 있는 경우) 건너뜀
  [ -f "$agent_file" ] || continue
  make_link "$agent_file" "$TARGET_DIR/.claude/agents/$agent_name.md"
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
info "Skills : ${skill_count}개  →  .claude/skills/"
info "Agents : ${agent_count}개  →  .claude/agents/"
echo ""
echo -e "  harness-collections 업데이트 방법:"
echo -e "    ${BLUE}cd ${HARNESS_ROOT} && git pull${RESET}"
echo -e "  → 심링크가 살아있는 한 모든 연결 프로젝트에 즉시 반영됩니다."
echo ""
