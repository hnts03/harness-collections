# project-manager skill

Dev-PM 에이전트. 요구사항 정제 → 계획 수립 → sub-agent 오케스트레이션 → QA → 결과 보고서 생성까지 전체 개발 프로젝트를 자율 실행한다.

---

## 사용법 (Usage)

### 설치

이 skill은 sub-agent 파일에 의존한다. 두 디렉토리를 모두 복사해야 한다.

```bash
# skill 설치
cp -r claude-skills/project-manager/ .claude/skills/project-manager/

# sub-agent 설치
mkdir -p .claude/agents
cp -r claude-agents/architect/  .claude/agents/architect/
cp -r claude-agents/worker/     .claude/agents/worker/
cp -r claude-agents/reviewer/   .claude/agents/reviewer/
cp -r claude-agents/qa/         .claude/agents/qa/
cp -r claude-agents/tech-writer/ .claude/agents/tech-writer/
```

설치 후 디렉토리 구조:

```
{프로젝트 루트}/
├── .claude/
│   ├── skills/
│   │   └── project-manager/
│   │       └── SKILL.md
│   └── agents/
│       ├── architect/AGENT.md
│       ├── worker/AGENT.md
│       ├── reviewer/AGENT.md
│       ├── qa/AGENT.md
│       └── tech-writer/AGENT.md
```

### 실행

```
/project-manager
```

이후 Claude Code가 요구사항을 물어보며 프로세스를 시작한다.

### 실행 흐름

| 단계 | 주체 | 자동/입력 |
|------|------|-----------|
| 1. Resume 감지 | PM | 자동 |
| 2. 요구사항 수집 | PM ↔ 사용자 | **사용자 입력** |
| 3. 계획 확인 | PM ↔ 사용자 | **사용자 승인** |
| 4. Architect 오케스트레이션 | PM → Architect → Worker/Reviewer | 자동 |
| 5. Escalation (발생 시) | PM ↔ 사용자 | **사용자 입력** |
| 6. QA | PM → QA → Worker | 자동 |
| 7. TechWriter | PM → TechWriter | 자동 |
| 8. 완료 보고 | PM | 자동 |

### 산출물

실행 완료 후 프로젝트 루트에 생성되는 파일:

| 파일 | 내용 |
|------|------|
| `project-plan.md` | 전체 실행 계획 및 진행 상황 (source of truth) |
| `qa-report.md` | 통합 테스트 결과 |
| `final-report.md` | 최종 프로젝트 결과 보고서 |

---

## 설계 결정 (Design Decisions)

### 하이브리드 오케스트레이션

PM과 Architect는 `project-plan.md`(파일 기반)로 상태를 관리하고, Worker/Reviewer/QA/TechWriter는 `Agent` tool로 실행한다. 파일이 세션 복구와 관측 가능성을 제공하고, Agent tool이 실행의 편의성을 제공한다.

### PM이 Project Planner를 겸함

요구사항을 가장 잘 이해하는 주체가 계획도 세워야 한다. 분리하면 컨텍스트 전달 비용과 해석 오차가 생긴다.

### Reviewer와 QA의 역할 분리

- **Reviewer**: group-level 코드 품질 (설계, 로직, 타입 — 정적 검토)
- **QA**: 전체 시스템 통합 동작 (런타임 검증)

같은 역할을 두 에이전트가 맡으면 책임이 모호해지고 중복 피드백이 발생한다.

### Escalation 경로 이원화

- **Worker 5회 실패** → PM이 해당 group 범위를 재계획 (계획 문제이므로 PM이 해결 가능)
- **Reviewer 5회 거부** → Human escalation (방향 자체의 충돌이므로 판단이 필요)

### sub-agent 파일을 별도 디렉토리에 분리

PM SKILL.md에 모든 프롬프트를 인라인으로 넣으면 유지보수가 어렵다. 각 에이전트 프롬프트를 독립 파일로 관리하고 PM이 런타임에 Read tool로 읽어 Agent tool에 전달하는 방식을 채택했다.
