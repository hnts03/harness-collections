# Skill Collections

외부에서 제작·배포된 Claude Code skill 컬렉션 레퍼런스 모음.

---

## harness-100

> "10개 도메인, 100개 production-grade agent team harness"

**링크:** https://github.com/revfactory/harness-100  
**라이선스:** Apache 2.0  
**언어 지원:** 영문(`en/`) + 한국어(`ko/`) 동일 구성

### 규모

| 항목 | 수치 |
|------|------|
| 전체 harness | 200개 (영문 100 + 한국어 100) |
| Agent 정의 | 978개 |
| Skill | 630개 |
| 문서 파일 | 1,808개 |

### 10개 도메인

| # | 도메인 | 주요 사례 |
|---|--------|-----------|
| 1 | Content Creation | YouTube, 팟캐스트, 내러티브, 번역 |
| 2 | Software Dev & DevOps | Full-stack, API, CI/CD, 보안, 인프라 |
| 3 | Data & AI/ML | 실험 관리, NLP, RAG, 디자인 시스템 |
| 4 | Business & Strategy | 스타트업, 시장조사, 가격 전략, 재무 모델 |
| 5 | Education & Learning | 튜터링, 시험 준비, 토론 시뮬레이션 |
| 6 | Legal & Compliance | 계약, 특허, GDPR/PIPA, 규제 대응 |
| 7 | Health & Lifestyle | 식단, 피트니스, 세금, 여행, 웨딩 |
| 8 | Communication & Docs | 기술 문서, SOP, 제안서, 위기 커뮤니케이션 |
| 9 | Operations & Process | 채용, 온보딩, 감사, 조달 |
| 10 | Specialized Domains | 부동산, 이커머스, ESG, IP 포트폴리오 |

### Harness 구조

각 harness는 3-layer skill 구조를 따른다:

```
<harness-name>/
├── orchestrator skill      # 팀 워크플로우 조율, agent 간 상호작용, 에러 처리
├── agent-extending skills  # 도메인 전문성 확장 (harness당 2-3개)
└── external tool skills    # 서드파티 서비스 연동
```

- **Specialist agent 4-5명**으로 구성
- 운영 규모별 스케일 지원 (mini / standard / enterprise)
- 도메인 표준 프레임워크 내장 (OWASP, Bloom's Taxonomy, Porter's Five Forces 등)
- 트리거 경계 정의 + 에러 핸들링 + 테스트 시나리오 포함

### 설치 방법

```bash
# 원하는 harness 디렉토리를 프로젝트의 .claude/skills/에 복사
cp -r en/<harness-name> /your/project/.claude/skills/
# 또는 한국어 버전
cp -r ko/<harness-name> /your/project/.claude/skills/
```

### 활용 시점

- 도메인별 agent 팀을 처음부터 설계하지 않고 바로 가져다 쓰고 싶을 때
- 프로덕션 수준의 orchestration 패턴이 필요할 때
- [harness](../harness-framework/README.md#3-harness) meta-skill로 생성한 결과물의 레퍼런스로 활용할 때
