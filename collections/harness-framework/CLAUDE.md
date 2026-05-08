# CLAUDE.md — Harness Framework

이 프로젝트는 재사용 가능한 Claude Code 하네스 팀입니다.
PM 에이전트를 `/pm` 스킬로 트리거하여 R&D 세션을 시작합니다.

## 팀 구성

| 에이전트 | 모델 | 역할 |
|---------|------|------|
| project-manager | opus | `/pm` 스킬로 트리거. resume detection → 플랜 수립 → 오케스트레이션 |
| researcher | opus | 관련 패턴/기법 심층 조사 |
| harness-architect | opus | 연구 결과 기반 패턴/기법 설계 |
| worker | sonnet | 설계 기반 구현 (atomic task 단위) |
| reviewer | opus | 산출물 품질 검토 |
| qa | opus | Phase 단위 검증 |
| document-writer | sonnet | 결과 문서화 |

## 스킬 목록

| 스킬 | 용도 |
|------|------|
| `/pm` | PM 에이전트 트리거 — 매 이슈마다 사용 |
| `/clean-commit` | co-author 없는 git commit |
| `/update-from-phase` | Phase 완료 처리 (dev-plan 갱신 + commit + push) |
| `/create-skill` | 새 스킬 생성 |
| `/create-agent` | 새 에이전트 생성 |
| `/harness-benchmark` | 스킬/에이전트 효과 측정 |

## 운영 원칙

- 플랜은 `_workspace/<플랜번호>/` 에서 격리 관리 (`_workspace/` 는 gitignore)
- task = 단일 concern, 수정 파일 최대 3개
- 병렬 worker 스폰 시 `outputs.files` 겹침 체크 필수
- 작업 도중 모호한 사항 발생 시 즉시 유저에게 질문

## 완료된 세션 이력

<!-- update-from-phase 스킬이 각 세션(플랜) 완료 시 아래에 추가한다 -->
<!-- 형식: - [YYYY-MM-DD] 플랜 NNN: <한 줄 요약> — 주요 산출물: <파일/결정사항> -->
- [2026-04-09] 플랜 003 완료: PM 에이전트 실행 가시성 개선 — 원인 진단(3계층: 플랫폼/프롬프트/중첩) 후 project-manager.md에 실행 가시성 프로토콜(규칙 1~4) 추가 — 주요 산출물: .claude/agents/project-manager.md, docs/phase_003/003-session-report.md
- [2026-04-09] 플랜 004 완료: PM ad-hoc 문서화 의무화 + harness-skill-template.md 패턴 전파 — 주요 산출물: .claude/agents/project-manager.md, harness-skill-template.md
- [2026-05-08] 플랜 005 완료: harness-skill-template.md에 세 운영 원칙(① 무허가 방향성 결정 금지, ② 의미 불명 코드네임·약어 금지, ③ "phase" 용어를 유저 대상·dev-plan 상위 구조에서 사용 제한) 반영. 8개 변경 항목 적용(공통 운영 원칙 강화, dev-plan 구조 예시 전면 교체, task 식별자 작성 규칙 신설, "Phase 완료 시" → "작업 단계 완료 시", `## Phase 0` → `## 도메인 분석` 등). 후속 분리 항목 3건(실행 가시성 프로토콜 phase 표기, docs/phase_<N>/ 명명, project-manager.md 동일 원칙 반영) — 주요 산출물: harness-skill-template.md
