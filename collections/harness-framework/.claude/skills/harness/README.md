# harness skill

메타 스킬. 도메인/프로젝트에 맞는 에이전트 팀과 스킬을 생성한다.

## 사용법

### 설치

`harness-collections` 플러그인을 install하면 자동 포함된다:

```
/plugin marketplace add hnts03/harness-collections
/plugin install harness@harness-collections
```

또는 이 디렉토리만 직접 복사:

```bash
cp -r harness /your/project/.claude/skills/
```

### 실행

```
/harness
```

또는 자연어로: "이 프로젝트에 맞는 하네스 구성해줘", "에이전트 팀 설계해줘".

### 흐름

```
[자동] Phase 1: 도메인 분석 (코드베이스 탐색, 작업 유형 식별, 기존 자산 충돌 확인)
[확인] Phase 2: 실행 모드 선택 (에이전트 팀 vs 서브 에이전트)
[자동] Phase 3: 에이전트 정의 생성 (.claude/agents/<name>.md)
[자동] Phase 4: 스킬 생성 (.claude/skills/<name>/skill.md + references/)
[자동] Phase 5: 오케스트레이션 (데이터 전달 프로토콜, 에러 핸들링)
[자동] Phase 6: 검증 (구조·트리거·드라이런 테스트)
```

## 설계 결정

### Progressive disclosure (references 분리)

SKILL.md 본문은 워크플로우 골격만 담고, 상세 가이드는 `references/`에 분리한다:

- `agent-design-patterns.md` — 아키텍처 패턴, 에이전트 분리 기준, 정의 구조
- `team-examples.md` — 실제 하네스 예시 (PM-Worker 팀 등의 파일 전문)
- `skill-writing-guide.md` — 스킬 작성 패턴, description 예시, 데이터 스키마
- `skill-testing-guide.md` — with-skill vs without-skill 비교 실행, near-miss 트리거 검증
- `qa-agent-guide.md` — QA 에이전트 정의 및 경계면 버그 패턴 (7개 실사례)
- `orchestrator-template.md` — 오케스트레이터 스킬 템플릿, 에러 전략표

Phase별 필요할 때만 references를 로드하여 컨텍스트 윈도우를 보호한다.

### 에이전트 팀이 기본 실행 모드

2개 이상의 에이전트가 협업할 때는 에이전트 팀(TeamCreate + SendMessage)을 우선 고려한다. 서브 에이전트는 통신이 불필요한 단방향 결과 전달 시에만 선택. 이유는 SKILL.md의 Phase 2-1 참조.

### 에이전트 정의 파일 강제

빌트인 타입(`general-purpose`, `Explore`, `Plan`)을 쓰더라도 `.claude/agents/<name>.md` 파일을 반드시 생성한다. Agent tool의 `prompt`에 역할을 인라인으로 넣지 않는다. 이유: 다음 세션 재사용성과 팀 통신 프로토콜의 명시적 문서화.

### 모든 에이전트는 opus

Agent tool 호출 시 `model: "opus"`를 명시한다. 하네스 품질은 에이전트의 추론 능력에 직결되며, opus가 최고 품질을 보장한다.
