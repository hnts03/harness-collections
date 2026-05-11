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

- 플랜은 `_workspace/<NNN>-<short-job-description>/` 에서 격리 관리. 기존 `_workspace/<NNN>/` 형식도 인정. (`_workspace/` 는 gitignore)
- task = 단일 concern, 수정 파일 최대 3개
- 병렬 worker 스폰 시 `outputs.files` 겹침 체크 필수
- 작업 도중 모호한 사항 발생 시 즉시 유저에게 질문
- **Cost test**: 새 문서/스킬/에이전트 추가 전 "없으면 잘못 동작하는가?" 자문 (정식 정의: `harness-skill-template.md` "스킬 작성 컨벤션 → Cost test")
- **Description 변경 = 재평가**: 기존 스킬·에이전트 description 수정 시 동일 PR에서 `/harness-benchmark` 실행 (정식 정의: 동 컨벤션 → Description 변경 시 재평가 의무)
- **유저 대상 보고 표현**: 사용자 직접 노출 텍스트(보고·AskUserQuestion·dev-plan)에서 마크다운 구현 디테일·메타정보 노출 금지. 의미 단위로 표현한다. (정식 정의: 동 컨벤션 → 유저 대상 보고 — 메타정보 노출 제한)

## 완료된 세션 이력

<!-- update-from-phase 스킬이 각 세션(플랜) 완료 시 아래에 추가한다 -->
<!-- 형식: - [YYYY-MM-DD] 플랜 NNN: <한 줄 요약> — 주요 산출물: <파일/결정사항> -->
- [2026-04-09] 플랜 003 완료: PM 에이전트 실행 가시성 개선 — 원인 진단(3계층: 플랫폼/프롬프트/중첩) 후 project-manager.md에 실행 가시성 프로토콜(규칙 1~4) 추가 — 주요 산출물: .claude/agents/project-manager.md, docs/phase_003/003-session-report.md
- [2026-04-09] 플랜 004 완료: PM ad-hoc 문서화 의무화 + harness-skill-template.md 패턴 전파 — 주요 산출물: .claude/agents/project-manager.md, harness-skill-template.md
- [2026-05-08] 플랜 005 완료: harness-skill-template.md에 세 운영 원칙(① 무허가 방향성 결정 금지, ② 의미 불명 코드네임·약어 금지, ③ "phase" 용어를 유저 대상·dev-plan 상위 구조에서 사용 제한) 반영. 8개 변경 항목 적용(공통 운영 원칙 강화, dev-plan 구조 예시 전면 교체, task 식별자 작성 규칙 신설, "Phase 완료 시" → "작업 단계 완료 시", `## Phase 0` → `## 도메인 분석` 등). 후속 분리 항목 3건(실행 가시성 프로토콜 phase 표기, docs/phase_<N>/ 명명, project-manager.md 동일 원칙 반영) — 주요 산출물: harness-skill-template.md
- [2026-05-08] 플랜 006 완료: 팀 자산 13개 파일을 harness-skill-template.md와 일관성 확보. 6개 파일 / 13개 변경 항목 적용 — project-manager.md(8개: 공통 원칙 신설·dev-plan 예시 개정·식별자 규칙 신설·실행 가시성 프로토콜 정렬 등), harness-skill-template.md(line 192-201 실행 가시성 프로토콜 표 정렬, 플랜 005 후속 분리 #1 처리), reviewer.md(line 16 컨텍스트 키 phase→stage), clean-commit/SKILL.md(5개 헤더 PHASE→STEP), create-skill·create-agent SKILL.md(신규 스킬·에이전트가 따라야 할 운영 원칙 H2 섹션 신설). 변경 없는 8개 파일은 점검 근거 명시 후 보존. 다음 플랜 후보 2건 등록(/harness 라우팅 결정 가시성 보완, _workspace 디렉토리 명명 규칙 확장) — 주요 산출물: 6개 파일 + _workspace/006/design-spec.md
- [2026-05-08] 플랜 007 완료: _workspace 하위 plan 디렉토리 명명 규칙을 `_workspace/<NNN>/`에서 `_workspace/<NNN>-<short-job-description>/`로 확장. 4개 파일 / 13개 변경 항목 적용 — harness-skill-template.md(채번 규칙·STEP 2 식별자 도출 절차·placeholder 통일 7개), project-manager.md(STEP 0 정규식·STEP 2 식별자 절차·"표기 약속" 단락 신설·11건 일괄 치환), update-from-phase/SKILL.md(컨텍스트 변수 `<플랜 디렉토리>` 추가, dev-plan 경로), CLAUDE.md(운영 원칙 line 31 신규 명명 규칙). 핵심 결정 4건: ① 새 명명 규칙 정의, ② resume detection 정규식 `^[0-9]{3}(-[a-z0-9-]+)?$` + sed 추출(기존 001~006 호환), ③ dev-plan 파일명 `<NNN>-dev-plan.md` 형식 유지(디렉토리명과 비동기), ④ PM STEP 2 식별자 도출 절차 명령형 신설. 유저 결정 3건: 기존 디렉토리 미마이그레이션·세션 이력 미변경·dev-plan 파일명 단순 유지. 검증 단계 라이브 시나리오 4건 모두 합격(매칭 8건/배제 5건 정확). 다음 플랜 후보 1건(/harness 라우팅 가시성, 플랜 006에서 등록) 미해결 — 주요 산출물: 4개 파일 + _workspace/007-workspace-rename/{007-dev-plan.md, design-spec.md}
- [2026-05-08] 플랜 008 완료: PM 호출 진입 가시성 — 사용자가 `/pm`을 직접 호출하지 않은 진입점(예: `/harness:harness`)에서 PM이 자동 호출되어 PM 파이프라인이 시작되는 사실 자체를 사용자에게 명시 보고하고 동의받는 절차 도입. 원칙 1("무허가 방향성 결정 금지")의 진입점 적용 사례, 플랜 006 미해결 후보 처리. 메커니즘: **옵션 A (Hint 전달 방식)** — `/pm` SKILL.md에 indicator `HARNESS_PM_ENTRY_POINT: direct (/pm)` 평문 라인을 박아두고 PM이 STEP 0 [0단계]에서 정확 매칭으로 검사 → 존재 시 직접 호출(한 줄 안내 후 [1단계] 직진), 부재 시 비직접 호출(자가 announce + AskUserQuestion 2옵션). 3개 파일 / 13개 acceptance grep 모두 합격: SKILL.md(`## Calling Context` H2 + indicator), project-manager.md(STEP 0 [0단계] 진입 분기 판별 블록 — 자가 announce·AskUser 2옵션·종료 메시지 + 대안 3종), harness-skill-template.md(`## PM 호출 진입 가시성 원칙` H2 + 4개 H3 — Hint 메커니즘·비직접 절차·직접 동작·외부 호환성). 핵심 결정 4건: ① 메커니즘 옵션 A 채택(B/C 비교 생략), ② 플랜 framing 정정 "PM 호출 사실 가시화 중심"(작업 성격 분류는 부차·종속), ③ AskUser 2옵션(예/아니오) 한정 — 3번째 옵션 "작업 성격을 다시 분류"는 본 플랜 범위 외로 분리, ④ 직접 호출 시 한 줄 안내 유지(보조 가시화). 유저 결정 5건: 식별자·메커니즘·외부 플러그인 미변경·framing 정정·UX 2종(직접 한 줄 안내 유지·AskUser 2옵션). 검증 단계 walkthrough 3건 모두 합격(직접/비직접+동의/비직접+거부) — 주요 산출물: 3개 파일 + _workspace/008-pm-routing-visibility/{008-dev-plan.md, design-spec.md, validate-report.md}
- [2026-05-11] 플랜 009 완료: Perplexity "Designing, Refining, and Maintaining Agent Skills" 기사 6개 원칙 도입 — Cost test·Description 3요소 routing trigger·Eval-first 트리거 매트릭스·Gotchas 섹션 컨벤션·Description 변경 재평가 의무·글로벌 컨텍스트 복제 금지 자문. 5개 파일 / 40개 acceptance grep + 6개 walkthrough 시나리오 모두 합격. 핵심 결정: **template = single source of truth** 구조 채택 — 6개 항목 정식 정의 모두 `harness-skill-template.md` 신규 H2 `## 스킬 작성 컨벤션`(H3 6개) 묶음 배치 + version 0.4.0 bump, 메타 스킬(create-skill·create-agent)은 1줄 인용·운영 체크리스트로 참조. create-skill에 `## STEP 0 — 트리거 매트릭스 작성` 신설하여 description보다 매트릭스 작성을 먼저 강제. `## 실행 전 확인` 3번 항목으로 글로벌 컨텍스트 자문 추가. harness-benchmark description에 "description 변경"·"description 수정 후 재평가" 키워드 확장. CLAUDE.md 운영 원칙 2개 불릿 미러링. 유저 결정 2건: ① template SoT 구조(항목 2·3·6 canonical을 create-skill에서 template으로 이전), ② 식별자 규칙(harness-skill-template.md line 184) 위반 정정(`D1~D7`·`A1·A2`·`WA-N`·`[A]/[B]/[C]` 모두 서술형으로 교체). 플랜 흐름: 도메인 분석 → 설계 (1차 reviewer REWORK 4건 PM 보정) → 결정 게이트 → 설계 재작성 (architect 재호출 + 2차 reviewer REWORK 4건 PM 보정) → 적용 (5 worker 병렬) → qa PASS → 문서화. 다음 플랜 후보 3건 등록(항목 7 progressive disclosure / 6개 README Gotchas 시드 / description 변경 자동화 훅) — 주요 산출물: 5개 파일 + _workspace/009-perplexity-principles-adopt/{009-dev-plan.md, domain-analysis.md, design-spec.md, validate-report.md} + docs/phase_009/009-session-report.md
- [2026-05-11] 플랜 010 완료: 유저 대상 보고 메타정보 노출 제한 원칙 도입 — 플랜 005 운영 원칙 ②(의미 불명 코드네임·약어 금지)·③(phase 용어 제한)의 본질을 보고 일반으로 확장. 본 세션 진행 중 PM이 사용자 보고에 마크다운 메타 표현을 노출한 사례가 발생하여 사용자가 지적, 원래 시작했던 플랜 010(template-split-by-subject)을 폐기하고 본 플랜으로 재배정 (template 분할은 플랜 011로 이월). 3개 파일 / 13개 acceptance grep + 3개 walkthrough + 2개 보존 검증 모두 합격. 핵심 결정 7건: ① 명칭 `유저 대상 보고 — 메타정보 노출 제한`, ② 정식 정의 위치 = `harness-skill-template.md` 「스킬 작성 컨벤션」 영역 7번째 H3, ③ 포섭 모델 (신규 원칙 상위 / 기존 두 규칙 instance·원문 보존), ④ PM 미러링 = 실행 가시성 프로토콜 도입부 직전 1줄 블록쿼트, ⑤ reviewer 본문 미변경 (PM 자가 점검만), ⑥ 본 세션 실제 사례 4건 + 일반 예시 2건, ⑦ 분할 사전 영향 없음 (플랜 011에서 일관 처리). 변경 사양: harness-skill-template.md 신규 H3(소개 + 포섭 인용 + 유효 컨텍스트 구분 표 + 위반/정상 변환 예시 6건 + 위반 발견 시 대응) / project-manager.md 블록쿼트 1줄 미러링 / CLAUDE.md 운영 원칙 7번째 불릿. 유효 컨텍스트 구분 표를 본문 내장하여 design-spec·qa-report·에이전트 간 메시지·메타 스킬 본문을 비적용으로 명시 — worker가 design-spec에 grep 검증식 못 쓰게 되는 부작용 사전 차단. 적용 단계 side effect 2건 처리: worker 1 본문 볼드 범위 조정으로 G2 grep 정합성 확보, design-spec G10 grep에 `--` 옵션 종료자 추가로 ugrep 호환성 보강. 플랜 흐름: 도메인 분석 → 설계 (1차 reviewer OK 8/10 minor 3건 PM 보정) → 결정 게이트 (4건 일괄 + 3건 권장안 자동) → 적용 (3 worker 병렬) → 검증 (qa PASS, critical 0건) → 문서화. 다음 플랜 후보: 플랜 011 = template-split-by-subject (사용자 결정으로 이월). 플랜 009 후속 후보 3건(progressive disclosure / README Gotchas 시드 / description 변경 자동화 훅)도 미해결로 유지 — 주요 산출물: 3개 파일 + _workspace/010-user-report-meta-restriction/{010-dev-plan.md, domain-analysis.md, design-spec.md, validate-report.md} + docs/phase_010/010-session-report.md
