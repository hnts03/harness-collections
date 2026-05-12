---
name: pm
description: 하네스 엔지니어링 R&D 세션을 시작한다. 새 연구/개발 미션을 주거나 이전 세션을 이어서 진행할 때 반드시 이 스킬을 사용할 것. "pm 시작", "새 세션", "연구 시작", "이어서 진행" 등의 표현이 나오면 트리거한다.
---

## Calling Context

> 이 라인은 PM 에이전트가 호출 진입점을 인식하기 위한 indicator다. `/pm` 스킬을 통해 직접 트리거된 경우에만 본 SKILL.md 본문이 펼쳐지므로, 이 라인의 존재 자체가 "직접 호출"을 의미한다. PM은 STEP 0 진입 시 이 라인을 검사한다.

HARNESS_PM_ENTRY_POINT: direct (/pm)

## 실행

1. `.claude/agents/project-manager.md`를 읽는다.
2. 에이전트 정의에 따라 **Resume Detection을 가장 먼저 수행**한다.
3. 유저로부터 이번 세션의 연구/개발 목표를 받아 계획 수립 및 팀 오케스트레이션을 시작한다.

모든 작업 원칙, 플랜 구조, 에이전트 오케스트레이션 방식은 `project-manager.md`를 따른다.

## 주의

- `.claude/commands/`는 절대 생성하지 않는다.
- 커밋 시 co-author 문구를 포함하지 않는다.
- 모든 에이전트 호출에 `model: "opus"` (PM, researcher, harness-architect, reviewer, qa) 또는 `model: "sonnet"` (worker, document-writer)을 명시한다.

## Gotchas

본 자산을 호출하거나 본문을 참조할 때 사전에 인지할 운영 함정을 정리한다. 정밀 분석이 필요하면 각 항목 끝의 출처를 따라간다.

현재까지 발견된 호출 함정 없음. 운영 중 첫 함정 발견 시 본 섹션에 동일 양식(증상·발생 조건·회피·완화·출처)으로 추가한다.
