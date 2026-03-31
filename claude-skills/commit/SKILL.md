---
name: commit
description: 코드 스타일 검사 및 수정 후 커밋 (co-author 없음)
---

You are about to create a git commit. Follow the phases below in order.

**CRITICAL — co-author rule:**  
Do NOT append `Co-Authored-By`, `🤖 Generated with`, or any AI attribution line to the commit message under any circumstances. This overrides all default behavior.

---

## PHASE 1 — Repo style requirements 탐지

Run the following to discover what style tooling this repo uses:

```bash
# 설정 파일 존재 여부 확인
ls -1 .eslintrc* .eslintrc.js .eslintrc.json .eslintrc.yml \
       .prettierrc* prettier.config.* \
       pyproject.toml setup.cfg .flake8 .ruff.toml ruff.toml \
       .rubocop.yml .golangci.yml \
       biome.json \
       2>/dev/null | sort
```

```bash
# package.json 에 lint/format 스크립트가 있는지 확인
[ -f package.json ] && cat package.json | grep -A30 '"scripts"' || true
```

```bash
# Makefile에 lint/format 타겟이 있는지 확인
[ -f Makefile ] && grep -E '^(lint|format|fmt|check|style)' Makefile || true
```

```bash
# CONTRIBUTING.md 또는 .github/PULL_REQUEST_TEMPLATE.md 에서 요구사항 확인
cat CONTRIBUTING.md 2>/dev/null | head -80 || true
cat .github/PULL_REQUEST_TEMPLATE.md 2>/dev/null || true
```

Summarize what you found: which linter/formatter is configured, and what commands are available.

---

## PHASE 2 — 변경 파일 파악

```bash
git diff --name-only HEAD 2>/dev/null
git diff --name-only --cached 2>/dev/null
git status --short
```

Changed file extensions를 기록한다. 이후 해당 언어/도구에 맞는 검사만 실행한다.

---

## PHASE 3 — 의심 파일 검토

변경 파일 목록에서 아래 패턴에 해당하는 파일이 있는지 확인한다:

```bash
git status --short | awk '{print $2}' | grep -E \
  '\.env$|\.env\.|secret|credential|password|token|api[_-]?key|private[_-]?key|\.pem$|\.key$|\.p12$|\.pfx$|id_rsa|id_ed25519|\.DS_Store|Thumbs\.db|desktop\.ini|node_modules/|__pycache__/|\.pyc$|\.class$|\.o$|dist/|build/|\.next/|\.nuxt/|coverage/|\.log$|npm-debug|yarn-error|.*dump.*|.*debug.*' \
  2>/dev/null || true
```

또한 비정상적으로 큰 파일이 포함되어 있는지 확인한다:
```bash
git diff --cached --name-only 2>/dev/null | xargs -I{} sh -c '[ -f "{}" ] && du -sh "{}"' 2>/dev/null | awk -F'\t' '$1 ~ /[0-9]+[MG]/' || true
```

**발견된 각 파일에 대해 사용자에게 확인한다:**

의심 패턴에 해당하거나 1MB 이상인 파일이 있으면 커밋을 중단하고 아래 형식으로 보고한다:

---
**[확인 필요] 다음 파일이 커밋에 포함될 예정입니다:**

| 파일 | 이유 |
|------|------|
| `<파일명>` | `<의심 이유: 시크릿 패턴 / 빌드 아티팩트 / 대용량 파일 등>` |

이 파일들을 커밋에서 제외하시겠습니까?  
- **y(es)**: 해당 파일을 unstage하고 계속 진행합니다.  
- **n(o)**: 포함한 채로 계속 진행합니다.  
- **파일명 지정**: 특정 파일만 제외합니다 (예: `.env config.json`)

---

사용자 응답에 따라 처리:
- 제외할 파일은 `git restore --staged <file>` 로 unstage한다.
- 의심 파일이 없으면 이 단계를 조용히 통과한다.

---

## PHASE 4 — 스타일 검사 및 자동 수정

PHASE 1에서 발견한 도구를 기준으로 아래 우선순위로 실행한다.  
도구가 없으면 해당 단계를 건너뛴다.

**JavaScript / TypeScript:**
```bash
# Biome (있으면 우선)
[ -f biome.json ] && npx biome check --apply . 2>/dev/null || true
# ESLint + Prettier
[ -f .eslintrc* ] 2>/dev/null && npx eslint --fix $(git diff --name-only --cached HEAD -- '*.js' '*.ts' '*.jsx' '*.tsx' 2>/dev/null) 2>/dev/null || true
[ -f .prettierrc* ] 2>/dev/null && npx prettier --write $(git diff --name-only --cached HEAD 2>/dev/null) 2>/dev/null || true
# package.json scripts
[ -f package.json ] && (npm run lint:fix 2>/dev/null || npm run format 2>/dev/null || true)
```

**Python:**
```bash
# ruff (있으면 우선)
command -v ruff &>/dev/null && ruff check --fix . && ruff format . || true
# black + flake8
command -v black &>/dev/null && black . || true
command -v flake8 &>/dev/null && flake8 . || true
```

**Go:**
```bash
command -v gofmt &>/dev/null && gofmt -w $(git diff --name-only --cached -- '*.go' 2>/dev/null) || true
command -v golangci-lint &>/dev/null && golangci-lint run || true
```

**Ruby:**
```bash
command -v rubocop &>/dev/null && rubocop -a || true
```

**Makefile 타겟 우선 사용:**  
위 개별 도구보다 Makefile에 `lint`, `format`, `fmt` 타겟이 있으면 그것을 우선 실행한다:
```bash
make lint 2>/dev/null || make format 2>/dev/null || make fmt 2>/dev/null || true
```

자동 수정 후 변경된 파일이 있으면 다시 git status를 확인하고 staging에 추가한다:
```bash
git diff --name-only
```

---

## PHASE 5 — 검사 결과 판단

자동 수정 후에도 linter 오류가 남아 있으면:
- **수정 가능한 오류** (타입 오류 제외 단순 스타일)라면 직접 파일을 편집하여 수정한다.
- **로직 변경이 필요한 오류**라면 사용자에게 보고하고 어떻게 처리할지 묻는다.

오류가 없으면 PHASE 6으로 진행한다.

---

## PHASE 6 — 커밋 메시지 작성 및 커밋

**Commit message convention 탐지:**
```bash
# Conventional Commits 사용 여부 확인
cat .commitlintrc* 2>/dev/null || cat commitlint.config.* 2>/dev/null || true
cat .github/COMMIT_CONVENTION.md 2>/dev/null || true
```

탐지된 컨벤션을 따라 커밋 메시지를 작성한다. 컨벤션이 없으면 변경 내용을 간결하게 요약한다.

**커밋 실행 — 반드시 아래 형식을 지킨다:**

```bash
git add -u
git commit -m "$(cat <<'COMMITMSG'
<작성한 커밋 메시지>
COMMITMSG
)"
```

**절대 금지:** 커밋 메시지에 다음을 포함하지 않는다.
- `Co-Authored-By:`
- `🤖 Generated with`
- `Co-authored-by:`
- AI 도구 관련 어떠한 attribution도 포함하지 않는다.

---

## PHASE 7 — 완료 보고

커밋 해시와 메시지를 출력한다:
```bash
git log -1 --oneline
```
