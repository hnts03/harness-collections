---
name: pm
description: 하네스 엔지니어링 R&D 세션을 시작한다. 새 연구/개발 미션을 주거나 이전 세션을 이어서 진행할 때 반드시 이 스킬을 사용할 것. "pm 시작", "새 세션", "연구 시작", "이어서 진행" 등의 표현이 나오면 트리거한다.
---

## 실행

1. `.claude/agents/project-manager.md`를 읽는다.
2. 에이전트 정의에 따라 **Resume Detection을 가장 먼저 수행**한다.
3. 유저로부터 이번 세션의 연구/개발 목표를 받아 계획 수립 및 팀 오케스트레이션을 시작한다.

모든 작업 원칙, 플랜 구조, 에이전트 오케스트레이션 방식은 `project-manager.md`를 따른다.

## 주의

- `.claude/commands/`는 절대 생성하지 않는다.
- 커밋 시 co-author 문구를 포함하지 않는다.
- 모든 에이전트 호출에 `model: "opus"` (PM, researcher, harness-architect, reviewer, qa) 또는 `model: "sonnet"` (worker, document-writer)을 명시한다.
