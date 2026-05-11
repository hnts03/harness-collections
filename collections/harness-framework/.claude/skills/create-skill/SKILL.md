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

3. **글로벌 컨텍스트 복제 금지 자문 (template 참조)**: 다음 3개 질문을 모두 확인한다. 하나라도 "예"이면 스킬 생성을 중단하고 유저에게 대안을 제안한다. 정식 정의는 `harness-skill-template/references/skill-authoring-conventions.md` "글로벌 컨텍스트 복제 금지 자문" 섹션 참조.
   - 이 내용이 `CLAUDE.md`에 들어가야 할 **글로벌 지침**이 아닌가?
   - 이 내용이 **단일 문장 프롬프트**로 대체 가능하지 않은가?
   - 이 스킬이 정말 **독립 트리거 가치**가 있는가, 아니면 기존 스킬의 확장으로 충분한가?

   자문이 "예"인 경우 대응안(글로벌 지침 → CLAUDE.md 1줄 추가 제안, 단일 프롬프트 → 직접 수행 제안, 기존 확장 → 해당 스킬 이름 명시 후 Edit 제안) 중 적절한 것을 유저에게 제시한 뒤 중단한다. 유저가 명시적으로 진행을 원하면 생성을 허용한다.

---

## STEP 0 — 트리거 매트릭스 작성

description을 작성하기 **전에** 트리거 매트릭스를 먼저 작성한다. 정식 컨벤션은 `harness-skill-template/references/skill-authoring-conventions.md` "Eval-first 트리거 매트릭스" 섹션 참조. 본 STEP은 운영 절차만 다룬다.

작성 절차:
1. should-trigger 케이스 ≥5개, should-NOT-trigger 케이스 ≥2개(near-miss 중심) 작성.
2. `_workspace/<플랜 디렉토리>/trigger-matrix-<skill-name>.md`에 별도 파일로 보존하거나, 작은 스킬의 경우 본 STEP의 인-라인 코멘트로 보존.
3. description은 이 매트릭스를 통과하도록 역설계한다 — 항목 #2(description 3요소)와 결합.
4. 스킬 파일 생성 완료 후 `/harness-benchmark`를 트리거하여 매트릭스 기반 트리거 정확도를 측정한다(MODULE A — 트리거 정확도 테스트).

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

description은 사용자 쿼리에 대한 라우팅 신호다. 정식 정의는 `harness-skill-template/references/skill-authoring-conventions.md` "Description = routing trigger 3요소" 섹션 참조. 본 절은 운영 절차만 다룬다.

작성 절차:
1. STEP 0(아래)에서 작성한 트리거 매트릭스를 입력으로 받는다.
2. should-trigger 케이스를 모두 포착하고 should-NOT-trigger 케이스를 모두 배제하도록 description을 역설계한다.
3. description에 3요소(트리거 시점 명세 / 트리거 키워드 목록 / 트리거하지 않을 케이스)가 모두 포함되었는지 점검한다.
4. 생성 완료 후 `/harness-benchmark`로 트리거 정확도를 검증한다.

### 본문 작성 원칙

- 명령형 어조 ("~한다", "~하라")
- 500줄 이내 목표
- 세부 참조 자료는 `references/` 하위에 분리하고 본문에 포인터 기술
- 특정 예시에만 맞는 좁은 규칙보다 원리를 설명하여 범용성 확보
- `.claude/commands/`는 절대 생성하지 않음

---

## 신규 스킬이 따라야 할 운영 원칙

생성하는 SKILL.md 본문에 다음 세 원칙을 반드시 반영한다.

- **무허가 방향성 결정 금지**: 신규 스킬은 작업 방향·구조·해결책을 자체 결정하지 않는다. 본문에 "유저 align 지점"을 명시한다 — 어떤 시점에 유저에게 확인을 받아야 하는지(예: 명세 누락 시 질문, 모호한 요구사항 발견 시 즉시 align)를 STEP 또는 "실행 전 확인" 섹션으로 명문화한다.
- **의미 불명 코드네임/약어 금지**: 신규 스킬의 식별자(섹션 헤더, 변수명, task_id 등)는 서술형으로 작성한다. `T1`, `G2` 같은 단순 코드네임은 금지한다. `STEP 1`, `MODULE A` 같은 자체 작업 흐름 표현은 허용한다. 의미 약어 케밥케이스(`recon-agents`, `qa-trigger-test` 등)도 허용 범주.
- **"phase" 용어 사용 제한**: 신규 스킬의 유저 대상 출력(보고 형식, 본문 헤더, 본문 안 안내문 등)과 외부 문서(`README.md` 등)에서 "phase" 단어를 사용하지 않는다. 자체 작업 흐름 호칭은 `## STEP N` 또는 서술형(예: "단계 시작")을 사용한다. 에이전트 내부 협업용으로만 phase를 호칭하는 경우는 허용한다.
- **Cost test 자문 (template 참조)**: 신규 스킬을 만들기 전, "이 스킬이 없으면 에이전트가 잘못 동작하는가?"를 자문한다. 답이 "아니오"면 만들지 않는다. 정식 정의는 `harness-skill-template/references/skill-authoring-conventions.md` "Cost test (비용 자문)" 섹션 참조.

---

**Gotchas 시드 여부 (template 참조)**

신규 스킬에는 함정이 아직 관측되지 않았으므로 `README.md`의 `## Gotchas` 섹션을 시드하지 않는다. 운영 중 첫 함정 발견 시 그 시점에 추가한다. 정식 컨벤션은 `harness-skill-template/references/skill-authoring-conventions.md` "Gotchas 섹션 컨벤션" 섹션 참조.

## 생성 후 검증

```bash
# 파일이 올바른 위치에 생성되었는지 확인
ls .claude/skills/<skill-name>/SKILL.md

# frontmatter 확인
head -5 .claude/skills/<skill-name>/SKILL.md
```

생성된 스킬을 유저에게 제시하고 피드백을 받는다.
