---
name: clean-commit
description: co-author 문구 없이, DCO Signed-off-by 포함하여 git commit을 수행한다. 하네스 파일(마크다운, 스크립트) 커밋 시 사용. "커밋", "commit", "변경 사항 저장" 등의 표현이 나오면 트리거한다. 단, update-from-phase 스킬이 이미 커밋을 처리하는 경우에는 이 스킬을 별도로 트리거하지 않는다.
---

**CRITICAL — co-author rule:**
커밋 메시지에 `Co-Authored-By`, `Co-authored-by`, `🤖 Generated with`, 또는 AI attribution 관련 어떤 문구도 포함하지 않는다. 이 규칙은 모든 다른 기본 동작보다 우선한다.

---

## PHASE 1 — 변경 파일 파악

```bash
git status --short
git diff --name-only HEAD 2>/dev/null
```

변경된 파일 목록과 확장자를 파악한다.

---

## PHASE 2 — 의심 파일 검토

커밋 전 아래 패턴에 해당하는 파일 확인:

```bash
git status --short | awk '{print $2}' | grep -E \
  '\.env$|\.env\.|secret|credential|password|token|api[_-]?key|\.pem$|\.key$' \
  2>/dev/null || true
```

발견 시 커밋을 중단하고 사용자에게 확인한다.

---

## PHASE 3 — DCO 서명 정보 해결

커밋 전 DCO(Developer Certificate of Origin) 서명에 사용할 identity를 확정한다.

```bash
GLOBAL_NAME=$(git config --global user.name 2>/dev/null || echo "")
GLOBAL_EMAIL=$(git config --global user.email 2>/dev/null || echo "")
LOCAL_NAME=$(git config --local user.name 2>/dev/null || echo "")
LOCAL_EMAIL=$(git config --local user.email 2>/dev/null || echo "")
echo "GLOBAL: $GLOBAL_NAME <$GLOBAL_EMAIL>"
echo "LOCAL:  $LOCAL_NAME <$LOCAL_EMAIL>"
```

결과에 따라 처리한다:

- **로컬 identity 없음** (LOCAL_NAME/EMAIL이 빈 값): 글로벌 identity를 자동 사용한다.
- **로컬 = 글로벌**: 글로벌 identity를 자동 사용한다.
- **로컬 ≠ 글로벌 (둘 다 존재)**: 사용자에게 확인한다.

  ```
  [DCO 서명] 두 개의 git identity가 감지되었습니다:
  1. 글로벌: <GLOBAL_NAME> <GLOBAL_EMAIL>
  2. 로컬:   <LOCAL_NAME> <LOCAL_EMAIL>
  어떤 identity로 서명하시겠습니까? (1/2)
  ```

- **글로벌도 없음**: 사용자에게 이름과 이메일을 직접 입력해달라고 요청한다.

결정된 값을 `DCO_NAME`, `DCO_EMAIL` 로 기억한다.

---

## PHASE 4 — staging 및 커밋

하네스 파일 특성상 스타일 검사는 생략한다 (마크다운 중심).

```bash
git add -u
```

변경 내용을 요약하여 커밋 메시지를 작성한다. Conventional Commits 형식을 따른다 (feat/fix/docs/refactor/chore).

```bash
git commit -m "$(cat <<'COMMITMSG'
<작성한 커밋 메시지>

Signed-off-by: <DCO_NAME> <<DCO_EMAIL>>
COMMITMSG
)"
```

---

## PHASE 5 — 완료 보고

```bash
git log -1 --oneline
```

커밋 해시와 메시지를 출력한다.
