#!/usr/bin/env bash
# configure-attribution.test.sh
# configure-attribution.sh 의 동작을 격리된 환경에서 검증한다.
# 실제 ~/.claude/settings.json 은 건드리지 않는다.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT="$SCRIPT_DIR/configure-attribution.sh"
TESTBED_DIR="$(mktemp -d)"
PASS=0
FAIL=0

# ── 헬퍼 ─────────────────────────────────────────────────────────────────

green() { printf "\033[32m%s\033[0m\n" "$*"; }
red()   { printf "\033[31m%s\033[0m\n" "$*"; }

assert_eq() {
  local label="$1" expected="$2" actual="$3"
  if [[ "$expected" == "$actual" ]]; then
    green "  PASS  $label"
    PASS=$(( PASS + 1 ))
  else
    red   "  FAIL  $label"
    echo  "         expected: $expected"
    echo  "         actual:   $actual"
    FAIL=$(( FAIL + 1 ))
  fi
}

assert_file_contains() {
  local label="$1" file="$2" key="$3" expected="$4"
  local actual
  actual=$(jq -r "$key" "$file" 2>/dev/null || echo "FILE_NOT_FOUND")
  assert_eq "$label" "$expected" "$actual"
}

assert_exit_nonzero() {
  local label="$1"
  shift
  if ! "$@" &>/dev/null; then
    green "  PASS  $label (오류 정상 반환)"
    PASS=$(( PASS + 1 ))
  else
    red   "  FAIL  $label (오류를 반환했어야 함)"
    FAIL=$(( FAIL + 1 ))
  fi
}

# ── 테스트용 HOME 격리 ────────────────────────────────────────────────────
# user scope 테스트가 실제 ~/.claude 를 건드리지 않도록
# HOME 을 임시 디렉토리로 교체한다.
export HOME="$TESTBED_DIR/fake-home"
mkdir -p "$HOME"

echo ""
echo "========================================"
echo " configure-attribution.sh 테스트"
echo " testbed: $TESTBED_DIR"
echo "========================================"

# ─────────────────────────────────────────────────────────────────────────
echo ""
echo "[ 1. settings.json 이 없는 경우 — user scope ]"
# ─────────────────────────────────────────────────────────────────────────
bash "$SCRIPT"
assert_file_contains "commit 빈 문자열" "$HOME/.claude/settings.json" '.attribution.commit' ""
assert_file_contains "pr 빈 문자열"     "$HOME/.claude/settings.json" '.attribution.pr'     ""

# ─────────────────────────────────────────────────────────────────────────
echo ""
echo "[ 2. attribution 블록이 아예 없는 기존 settings.json ]"
# ─────────────────────────────────────────────────────────────────────────
echo '{"autoUpdates": true, "theme": "dark"}' > "$HOME/.claude/settings.json"
bash "$SCRIPT"
assert_file_contains "기존 autoUpdates 보존" "$HOME/.claude/settings.json" '.autoUpdates'        "true"
assert_file_contains "기존 theme 보존"        "$HOME/.claude/settings.json" '.theme'              "dark"
assert_file_contains "attribution.commit 생성" "$HOME/.claude/settings.json" '.attribution.commit' ""
assert_file_contains "attribution.pr 생성"     "$HOME/.claude/settings.json" '.attribution.pr'     ""

# ─────────────────────────────────────────────────────────────────────────
echo ""
echo "[ 3. 커스텀 commit / pr 메시지 ]"
# ─────────────────────────────────────────────────────────────────────────
bash "$SCRIPT" --commit "AI-assisted" --pr "AI-assisted"
assert_file_contains "commit 커스텀" "$HOME/.claude/settings.json" '.attribution.commit' "AI-assisted"
assert_file_contains "pr 커스텀"     "$HOME/.claude/settings.json" '.attribution.pr'     "AI-assisted"

# ─────────────────────────────────────────────────────────────────────────
echo ""
echo "[ 4. 빈 문자열로 재패치 (co-author 제거) ]"
# ─────────────────────────────────────────────────────────────────────────
bash "$SCRIPT" --commit "" --pr ""
assert_file_contains "commit 제거" "$HOME/.claude/settings.json" '.attribution.commit' ""
assert_file_contains "pr 제거"     "$HOME/.claude/settings.json" '.attribution.pr'     ""

# ─────────────────────────────────────────────────────────────────────────
echo ""
echo "[ 5. project scope — settings.json 없음 ]"
# ─────────────────────────────────────────────────────────────────────────
PROJECT_A="$TESTBED_DIR/project-a"
mkdir -p "$PROJECT_A"
bash "$SCRIPT" --scope project "$PROJECT_A"
assert_file_contains "project: commit 빈" "$PROJECT_A/.claude/settings.json" '.attribution.commit' ""
assert_file_contains "project: pr 빈"     "$PROJECT_A/.claude/settings.json" '.attribution.pr'     ""

# ─────────────────────────────────────────────────────────────────────────
echo ""
echo "[ 6. project scope — 기존 settings.json 에 attribution 블록 없음 ]"
# ─────────────────────────────────────────────────────────────────────────
PROJECT_B="$TESTBED_DIR/project-b"
mkdir -p "$PROJECT_B/.claude"
echo '{"permissions": {"allow": ["Bash"]}}' > "$PROJECT_B/.claude/settings.json"
bash "$SCRIPT" --scope project "$PROJECT_B"
assert_file_contains "project: permissions 보존" "$PROJECT_B/.claude/settings.json" '.permissions.allow[0]' "Bash"
assert_file_contains "project: commit 생성"       "$PROJECT_B/.claude/settings.json" '.attribution.commit'   ""

# ─────────────────────────────────────────────────────────────────────────
echo ""
echo "[ 7. 오류 케이스 ]"
# ─────────────────────────────────────────────────────────────────────────
assert_exit_nonzero "--scope project dir 누락" \
  bash "$SCRIPT" --scope project

assert_exit_nonzero "--scope 잘못된 값" \
  bash "$SCRIPT" --scope invalid

assert_exit_nonzero "존재하지 않는 project dir" \
  bash "$SCRIPT" --scope project "$TESTBED_DIR/no-such-dir"

# ── 정리 ─────────────────────────────────────────────────────────────────
rm -rf "$TESTBED_DIR"

echo ""
echo "========================================"
printf " 결과: "
if [[ $FAIL -eq 0 ]]; then
  green "PASS $PASS / $((PASS + FAIL))"
else
  red   "FAIL $FAIL / $((PASS + FAIL))  (PASS: $PASS)"
fi
echo "========================================"
echo ""

[[ $FAIL -eq 0 ]]
