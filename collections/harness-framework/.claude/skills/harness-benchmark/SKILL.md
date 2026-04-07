---
name: harness-benchmark
description: 하네스 스킬/에이전트의 효과성을 측정한다. 트리거 정확도 테스트(should-trigger / should-NOT-trigger), with-skill vs without-skill A/B 비교를 수행하고 벤치마크 보고서를 생성한다. "벤치마크", "스킬 테스트", "효과 측정", "A/B 비교", "트리거 테스트", "skill 검증" 등의 표현이 나오면 반드시 이 스킬을 사용할 것. 단순 파일 존재 확인은 이 스킬을 트리거하지 않는다.
---

## 실행 전 확인

테스트 대상을 파악한다:
- 어떤 스킬/에이전트를 테스트하는가
- 어떤 측면을 검증하는가 (트리거 / A/B 비교 / 경계 케이스)

대상 파일을 읽는다:
```bash
cat .claude/skills/<skill-name>/SKILL.md 2>/dev/null
```

---

## MODULE A — 트리거 정확도 테스트

### A1. 테스트 쿼리 생성

**Should-trigger 쿼리 (8~10개):**
스킬의 description을 보고, 실제 사용자가 이 스킬을 써야 하는 상황에서 입력할 법한 다양한 표현을 생성한다. 표현 다양성 체크:
- [ ] 공식적 표현
- [ ] 캐주얼 표현  
- [ ] 한국어 + 영어 혼합
- [ ] 명시적 ("create-skill 써서 만들어줘")
- [ ] 암시적 ("새 스킬 파일이 필요해")

**Should-NOT-trigger 쿼리 (8~10개 — near-miss 중심):**
키워드가 유사하지만 다른 도구/스킬이 적합한 경계 케이스를 생성한다. "명백히 무관한 쿼리"는 테스트 가치가 없다. 경계가 모호한 쿼리에 집중한다.

### A2. 평가

각 쿼리에 대해 현재 description이 의도한 대로 트리거를 유도/방지하는지 평가한다:
- description이 should-trigger 쿼리를 포착하는가
- description이 should-NOT-trigger 쿼리를 명확히 배제하는가

트리거 정확도 = (올바르게 판정된 쿼리 수) / (전체 쿼리 수)

---

## MODULE B — A/B 비교 테스트

스킬의 실제 효과를 측정하기 위해 두 에이전트를 비교한다:

**With-skill 에이전트:**
```
스킬 파일을 읽은 후 다음 작업을 수행하세요: <테스트 프롬프트>
참조: .claude/skills/<skill-name>/SKILL.md
```

**Without-skill 에이전트 (baseline):**
```
다음 작업을 수행하세요: <테스트 프롬프트>
(스킬 참조 없음)
```

두 에이전트를 병렬로 스폰하고 결과를 비교한다.

**비교 기준:**
- 산출물 품질 (구조, 완전성, 규칙 준수)
- 규칙 준수 (파일명 규칙, frontmatter 완전성 등)
- 일관성 (같은 프롬프트에 동일 결과를 내는가)

---

## MODULE C — 경계 케이스 테스트

스킬의 엣지 케이스를 직접 테스트한다:
- 입력이 불완전할 때 어떻게 처리하는가
- description이 의도하지 않은 작업을 흡수하지 않는가
- 실패 시 명확한 오류 메시지를 반환하는가

---

## 벤치마크 보고서 작성

`_workspace/<플랜번호>/benchmark-<skill-name>.md`에 보고서를 작성한다:

```markdown
# 벤치마크 보고서: <skill-name>

**테스트 일시**: <날짜>
**대상 스킬**: .claude/skills/<skill-name>/SKILL.md

## 트리거 정확도

**Should-trigger (N개):** X/N PASS
| 쿼리 | 평가 | 비고 |
|------|------|------|
| ... | PASS/FAIL | |

**Should-NOT-trigger (N개):** X/N PASS
| 쿼리 | 평가 | 비고 |
|------|------|------|
| ... | PASS/FAIL | |

**종합 정확도**: X%

## A/B 비교 결과

| 항목 | With-skill | Without-skill |
|------|-----------|---------------|
| 파일명 규칙 준수 | | |
| frontmatter 완전성 | | |
| 구조 완전성 | | |
| 전반적 품질 | | |

**스킬 부가가치**: <유의미한 차이가 있는 항목 요약>

## 경계 케이스 결과
[케이스별 결과]

## 개선 권고
[description 또는 본문에서 개선이 필요한 부분]
```

---

## 완료 보고

```
STATUS: completed
REPORT: <보고서 경로>
TRIGGER_ACCURACY: <X%>
AB_DELTA: <with-skill이 유의미하게 나은 항목 수>
RECOMMENDATIONS:
- <개선 권고 1>
- <개선 권고 2>
```
