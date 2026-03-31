# commit skill

## 사용법

### 설치

```bash
cp -r commit /your/project/.claude/skills/
```

### 실행

```
/commit
```

### 흐름

```
[자동] repo의 스타일 도구 탐지 (ESLint, Prettier, Ruff, Black, Biome, Makefile 타겟 등)
[자동] 변경 파일 파악
[확인] 의심 파일 탐지 시 사용자에게 포함 여부 확인
       (.env / 시크릿 패턴 / 빌드 아티팩트 / 1MB 이상 파일 등)
[자동] lint/format 자동 수정 → 수정 불가 오류 시 사용자에게 보고
[자동] commit message convention 탐지 (commitlint 등)
[자동] co-author 없이 커밋
```

## 설계 결정

### co-author 제거

Claude의 내부 지침은 커밋 메시지 끝에 `Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>`을 붙이도록 되어 있다. Skill 프롬프트 안에서 이를 명시적으로 금지하는 규칙을 선언함으로써 내부 지침을 override한다.

### 별도 agent를 만들지 않은 이유

Skill은 현재 세션의 컨텍스트(열려있는 파일, 이전 대화)를 그대로 이어받는다. 코드 변경 맥락을 별도 agent에 전달하면 컨텍스트 손실이 생기므로 같은 세션 안에서 처리하는 것이 더 정확하다.

### 스타일 도구 탐지를 먼저 하는 이유

repo마다 사용하는 도구가 다르기 때문에 하드코딩 대신 설정 파일을 읽어 도구를 동적으로 선택한다. Makefile 타겟이 있으면 개별 도구보다 우선 사용한다 — 프로젝트가 정의한 공식 명령어를 따르는 것이 가장 안전하다.

### 의심 파일 검토

`.env`, 시크릿 패턴(`secret`, `credential`, `token`, `*.pem` 등), 빌드 아티팩트(`dist/`, `node_modules/`, `*.pyc`), 1MB 이상 파일이 staging 영역에 포함되어 있으면 커밋 전에 사용자에게 포함 여부를 묻는다. 파일 단위로 제외 여부를 선택할 수 있다.

### 자동 수정 범위

단순 스타일 오류는 자동으로 수정하되, 로직 변경이 필요한 오류는 사용자에게 보고하고 대기한다. 의도하지 않은 코드 변경을 방지하기 위함이다.
