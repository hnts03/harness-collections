---
name: create-skill
description: 새로운 하네스 스킬(SKILL.md)을 생성한다. 스킬 설계가 완료되었거나 새 스킬 파일 작성이 필요할 때 반드시 이 스킬을 사용할 것. "스킬 만들어", "skill 생성", "새 스킬 작성", "SKILL.md 작성" 등의 표현이 나오면 트리거한다. 기존 스킬 수정은 Edit 도구를 직접 사용하고 이 스킬은 트리거하지 않는다.
---

## 실행 전 확인

1. 유사한 스킬이 이미 존재하는지 확인한다:
   ```bash
   ls .claude/skills/ 2>/dev/null
   ```
   유사 스킬이 존재하면 새로 생성하지 않고 기존 스킬 확장을 제안한다.

2. 스킬 명세가 준비되어 있는지 확인한다. 없으면 다음을 유저에게 묻는다:
   - 스킬 이름 (디렉토리명이자 `/skill-name` 커맨드)
   - 스킬의 목적 (한 줄)
   - 주요 실행 단계
   - 트리거 조건 (어떤 상황에서 사용하는가)

---

## SKILL.md 생성 규칙

**파일명은 반드시 `SKILL.md` (대문자 고정)**. `skill.md`는 절대 사용하지 않는다.

생성 경로: `.claude/skills/<skill-name>/SKILL.md`

### frontmatter 필수 항목

```yaml
---
name: <skill-name>
description: <적극적 트리거 유도형 description>
---
```

**description 작성 원칙 (핵심):**

나쁜 예: `"PDF 파일을 처리하는 스킬"`  
좋은 예: `"PDF 읽기, 텍스트 추출, 병합, 분할, OCR 등 모든 PDF 작업을 수행. .pdf 파일을 언급하거나 PDF 산출물을 요청하면 반드시 이 스킬을 사용할 것."`

포함할 것:
- 스킬이 하는 일 (구체적)
- 트리거 조건 (어떤 상황, 어떤 표현)
- 유사하지만 트리거하면 안 되는 경우와 구분

### 본문 작성 원칙

- 명령형 어조 ("~한다", "~하라")
- 500줄 이내 목표
- 세부 참조 자료는 `references/` 하위에 분리하고 본문에 포인터 기술
- 특정 예시에만 맞는 좁은 규칙보다 원리를 설명하여 범용성 확보
- `.claude/commands/`는 절대 생성하지 않음

---

## 생성 후 검증

```bash
# 파일이 올바른 위치에 생성되었는지 확인
ls .claude/skills/<skill-name>/SKILL.md

# frontmatter 확인
head -5 .claude/skills/<skill-name>/SKILL.md
```

생성된 스킬을 유저에게 제시하고 피드백을 받는다.
