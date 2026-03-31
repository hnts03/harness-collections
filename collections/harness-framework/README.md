# Harness Framework Collection

배포 및 운영 중인 AI agent harness 프레임워크 레퍼런스 모음.  
각 프레임워크의 설계 철학, 구조, 적합한 사용 사례를 정리한다.

---

## 프레임워크 비교

| | [paperclip](#1-paperclip) | [gitagent](#2-gitagent) | [harness](#3-harness) |
|---|---|---|---|
| **핵심 개념** | Agent 팀을 운영하는 회사 OS | Git repo = Agent 정의 | Claude Code 전용 multi-agent 설계 도구 |
| **대상 규모** | 조직 / 멀티 컴퍼니 | 팀 / 개인 | 프로젝트 단위 |
| **상태 관리** | PostgreSQL + 서버 | Git history + memory/ | 없음 (stateless skill) |
| **프레임워크 의존성** | Node.js 서버 + React UI | 프레임워크 무관 (YAML 표준) | Claude Code 필수 |
| **배포 방식** | Docker / self-hosted | git clone | Claude Code marketplace |
| **라이선스** | — | — | Apache 2.0 |

---

## 1. paperclip

> "Zero-human companies를 위한 오픈소스 오케스트레이션"

**링크:** https://github.com/paperclipai/paperclip  
**Stars:** 41.3k · **Forks:** 6.2k

### 개요

Agent 팀이 공통 비즈니스 목표를 향해 협력하는 구조를 Node.js 서버와 React 대시보드로 관리한다. 사람 없이 회사를 운영하는 것을 목표로 한다.

### 핵심 기능

- **BYOA (Bring Your Own Agent)** — Claude Code, Codex, Cursor, HTTP 기반 등 어떤 agent든 연결 가능
- **Goal Alignment** — 모든 태스크가 회사 미션까지 컨텍스트 계보(ancestry)로 추적됨
- **Heartbeats** — 스케줄 기반 agent 실행 및 이벤트 트리거
- **Cost Control** — Agent별 월 예산 설정 + 자동 스로틀링
- **Governance** — 승인 게이트, 설정 버전 관리, 롤백
- **Multi-Company** — 단일 배포로 복수 조직 격리 운영

### 디렉토리 구조

```
paperclip/
├── cli/
├── server/
├── ui/
├── packages/
├── skills/
├── docs/
└── docker/
```

### 적합한 사용 사례

- agent 팀을 제품/서비스로 운영해야 하는 경우
- 비용, 승인, 감사 로그가 필요한 엔터프라이즈 환경
- 여러 AI 플랫폼의 agent를 단일 대시보드로 통합 관리

---

## 2. gitagent

> "Clone a repo, get an agent"

**링크:** https://github.com/open-gitagent/gitagent  
**패키지:** `@shreyaskapale/gitagent` (npm)

### 개요

AI agent를 Git 레포지토리로 정의하는 프레임워크 무관(framework-agnostic) 표준. 프롬프트와 스킬의 전체 변경 이력이 git history로 보존되고, 한 번 정의하면 Claude Code, OpenAI, CrewAI, LangChain 등으로 export된다.

### 핵심 기능

- **Git-native 버전 관리** — 프롬프트·스킬 변경 이력 완전 보존, undo 가능
- **프레임워크 무관 export** — Claude Code, OpenAI, CrewAI, LangChain, AutoGen, GitHub Actions 어댑터 제공
- **Composable agents** — extend / depend / delegate로 agent 간 계층 구성
- **SkillsFlow** — 결정론적 멀티스텝 워크플로우 정의
- **Compliance-ready** — FINRA Rule 3110, 4511 / SEC Reg S-P / SR 11-7 대응 구조
- **Human-in-the-loop** — PR 워크플로우로 강화 학습

### Agent 레포 구조

```
my-agent/
├── agent.yaml       # 필수: agent 매니페스트
├── SOUL.md          # 필수: agent 정체성/페르소나
├── RULES.md         # 행동 규칙
├── DUTIES.md        # 역할 분리 (maker/checker/executor/auditor)
├── skills/          # 재사용 가능한 스킬
├── tools/           # 외부 도구 연동
├── knowledge/       # 지식 트리 + 임베딩
├── memory/runtime/  # 런타임 메모리
├── workflows/       # SkillsFlow 워크플로우
├── agents/          # 하위 agent 정의
├── compliance/      # 컴플라이언스 문서
└── hooks/           # 이벤트 훅
```

### 적합한 사용 사례

- 특정 AI 플랫폼에 종속되지 않고 portable한 agent를 만들어야 할 때
- 금융·의료 등 컴플라이언스가 중요한 도메인
- agent 정의를 팀 단위로 Git으로 협업하고 리뷰하고 싶을 때

---

## 3. harness

> "Claude Code 전용 multi-agent 시스템 설계 meta-skill"

**링크:** https://github.com/revfactory/harness  
**Stars:** 824 · **Forks:** 102 · **라이선스:** Apache 2.0

### 개요

도메인을 분석하고, agent 팀 구조를 설계하고, 각 agent가 사용할 skill을 생성하는 meta-skill. Claude Code marketplace에서 설치하면 `/harness` 하나로 전체 agent 시스템 설계가 자동화된다.

### 핵심 기능

- **6가지 아키텍처 패턴** 자동 선택 및 적용:
  - Pipeline, Fan-out/Fan-in, Expert Pool
  - Producer-Reviewer, Supervisor, Hierarchical Delegation
- **6-Phase 워크플로우** — 도메인 분석 → 팀 설계 → Agent 정의 → Skill 생성 → 통합 오케스트레이션 → 검증
- **Progressive disclosure** — 단계별로 결과물을 보여주며 사용자 확인 후 진행
- **두 가지 실행 모드** — Agent Teams (기본) / Subagents
- **검증 프레임워크** — 트리거 검증 + 비교 테스트

### 디렉토리 구조

```
harness/
├── .claude-plugin/
│   └── plugin.json          # 마켓플레이스 매니페스트
└── skills/harness/
    ├── SKILL.md             # 메인 워크플로우 프롬프트
    ├── pipeline.md
    ├── fan-out-fan-in.md
    ├── expert-pool.md
    ├── producer-reviewer.md
    ├── supervisor.md
    └── hierarchical-delegation.md
```

### 설치

```
/plugin install harness@claude-plugins-official
```

### 적합한 사용 사례

- Claude Code 프로젝트에서 multi-agent 시스템을 빠르게 설계해야 할 때
- 어떤 아키텍처 패턴을 써야 할지 모를 때 (자동 추천)
- skill 파일을 직접 작성하기 어려울 때 자동 생성 용도

---

## 선택 가이드

```
운영 규모가 조직 수준이고 대시보드·비용관리 필요?
  └─ paperclip

AI 플랫폼 무관하게 portable한 agent 표준이 필요하거나 컴플라이언스 대응?
  └─ gitagent

Claude Code 프로젝트 안에서 multi-agent 설계를 빠르게 자동화?
  └─ harness
```
