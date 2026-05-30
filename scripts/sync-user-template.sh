#!/usr/bin/env bash
# sync-user-template.sh
#
# collections/harness-framework/harness-skill-template.md (+ references/)를
# /harness 스킬 안의 references/user-template/ 사본으로 동기화한다.
#
# SoT는 collections/harness-framework/harness-skill-template.md 이고,
# plugin install 시 사용자 머신에서 그 SoT는 따라가지 않기 때문에
# /harness 스킬 디렉토리 안에 사본을 두어 plugin install로도 자동 포함되게 한다.
#
# 사용법:
#   bash scripts/sync-user-template.sh           # SoT → 사본 동기화
#   bash scripts/sync-user-template.sh --check   # 차이가 있으면 비-0 종료 (CI용)

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SOT_FILE="$REPO_ROOT/collections/harness-framework/harness-skill-template.md"
SOT_REF_DIR="$REPO_ROOT/collections/harness-framework/harness-skill-template/references"
COPY_DIR="$REPO_ROOT/collections/harness-framework/.claude/skills/harness/references/user-template"

if [ ! -f "$SOT_FILE" ]; then
  echo "SoT 파일이 없습니다: $SOT_FILE" >&2
  exit 1
fi

mode="${1:-sync}"

if [ "$mode" = "--check" ]; then
  diff "$SOT_FILE" "$COPY_DIR/harness-skill-template.md" > /dev/null || { echo "harness-skill-template.md 차이 발견"; exit 1; }
  diff -r "$SOT_REF_DIR" "$COPY_DIR/references" > /dev/null || { echo "references/ 차이 발견"; exit 1; }
  echo "user-template 사본이 SoT와 일치합니다."
  exit 0
fi

mkdir -p "$COPY_DIR/references"
cp "$SOT_FILE" "$COPY_DIR/harness-skill-template.md"
cp "$SOT_REF_DIR"/*.md "$COPY_DIR/references/"

echo "user-template 사본 동기화 완료:"
echo "  $COPY_DIR/harness-skill-template.md"
echo "  $COPY_DIR/references/*.md ($(ls "$COPY_DIR/references" | wc -l | tr -d ' ')개)"
