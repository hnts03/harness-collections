#!/usr/bin/env bash
# configure-attribution.sh
# Claude Code settings.json 의 attribution 블록을 패치한다.
#
# Usage:
#   ./configure-attribution.sh [options]
#
# Options:
#   --commit <msg>         커밋 메시지에 삽입할 attribution 문자열 (기본값: 빈 문자열 → co-author 제거)
#   --pr <msg>             PR 본문에 삽입할 attribution 문자열   (기본값: 빈 문자열 → co-author 제거)
#   --scope user|project   적용 범위 (기본값: user)
#   <dir>                  --scope project 일 때 프로젝트 루트 경로 (필수)
#
# Examples:
#   # user 범위에서 co-author 완전 제거
#   ./configure-attribution.sh
#
#   # user 범위에서 커밋 attribution만 지정
#   ./configure-attribution.sh --commit "Generated with Claude"
#
#   # 특정 프로젝트에만 적용 (co-author 제거)
#   ./configure-attribution.sh --scope project ~/workspace/my-project
#
#   # 특정 프로젝트에 커스텀 메시지
#   ./configure-attribution.sh --commit "AI-assisted" --pr "AI-assisted" --scope project ~/workspace/my-project

set -euo pipefail

# ── 기본값 ──────────────────────────────────────────────────────────────
COMMIT_MSG=""
PR_MSG=""
SCOPE="user"
PROJECT_DIR=""

# ── 인자 파싱 ────────────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
  case "$1" in
    --commit)
      COMMIT_MSG="$2"
      shift 2
      ;;
    --pr)
      PR_MSG="$2"
      shift 2
      ;;
    --scope)
      SCOPE="$2"
      shift 2
      if [[ "$SCOPE" != "user" && "$SCOPE" != "project" ]]; then
        echo "error: --scope 는 'user' 또는 'project' 여야 합니다." >&2
        exit 1
      fi
      ;;
    -*)
      echo "error: 알 수 없는 옵션 '$1'" >&2
      echo "사용법: $0 [--commit <msg>] [--pr <msg>] [--scope user|project] [dir]" >&2
      exit 1
      ;;
    *)
      # positional: project dir
      PROJECT_DIR="$1"
      shift
      ;;
  esac
done

# ── scope 검증 ───────────────────────────────────────────────────────────
if [[ "$SCOPE" == "project" ]]; then
  if [[ -z "$PROJECT_DIR" ]]; then
    echo "error: --scope project 일 때 프로젝트 디렉토리를 인자로 제공해야 합니다." >&2
    echo "예시: $0 --scope project ~/workspace/my-project" >&2
    exit 1
  fi
  if [[ ! -d "$PROJECT_DIR" ]]; then
    echo "error: 디렉토리가 존재하지 않습니다: $PROJECT_DIR" >&2
    exit 1
  fi
  SETTINGS_DIR="$(realpath "$PROJECT_DIR")/.claude"
else
  SETTINGS_DIR="$HOME/.claude"
fi

SETTINGS_FILE="$SETTINGS_DIR/settings.json"

# ── jq 의존성 확인 ───────────────────────────────────────────────────────
if ! command -v jq &>/dev/null; then
  echo "error: jq 가 설치되어 있지 않습니다." >&2
  echo "  macOS: brew install jq" >&2
  echo "  Ubuntu/Debian: sudo apt install jq" >&2
  exit 1
fi

# ── settings.json 준비 ───────────────────────────────────────────────────
mkdir -p "$SETTINGS_DIR"

if [[ ! -f "$SETTINGS_FILE" ]]; then
  echo "{}" > "$SETTINGS_FILE"
fi

# ── attribution 패치 (기존 설정은 보존) ─────────────────────────────────
PATCHED=$(jq \
  --arg commit "$COMMIT_MSG" \
  --arg pr     "$PR_MSG" \
  '.attribution.commit = $commit | .attribution.pr = $pr' \
  "$SETTINGS_FILE")

echo "$PATCHED" > "$SETTINGS_FILE"

# ── 결과 출력 ────────────────────────────────────────────────────────────
echo "✅ attribution 패치 완료"
echo "   파일: $SETTINGS_FILE"
echo "   scope: $SCOPE"
echo ""
echo "적용된 내용:"
jq '.attribution' "$SETTINGS_FILE"
