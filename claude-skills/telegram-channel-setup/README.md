# telegram-channel-setup skill

## 목적

Claude Code의 `/channel` 기능을 활용하여 Telegram 봇과 Claude Code 세션을 연결하는 전체 과정을 자동화하는 skill입니다.

## 커버 범위

| 단계 | 자동화 여부 | 비고 |
|------|------------|------|
| Bun 설치 확인 및 자동 설치 | ✅ 자동 | curl 인스톨러 사용 |
| claude-plugins-official 마켓플레이스 등록 | ✅ 자동 | update → add fallback 순서 |
| telegram 플러그인 설치 및 활성화 | ✅ 자동 | `/plugin install` + `/reload-plugins` |
| BotFather 토큰 입력 | ⏸ 사용자 입력 | 봇 생성은 사람만 가능 |
| 토큰 설정 및 검증 | ✅ 자동 | `/telegram:configure`, `.env` 확인 |
| `--channels` 재시작 안내 | ⏸ 사용자 실행 | 세션 재시작은 Claude가 직접 못 함 |
| 페어링 코드 입력 | ⏸ 사용자 입력 | 봇에게 메시지 보낸 뒤 코드 받아야 함 |
| allowlist 정책 적용 | ✅ 자동 | `/telegram:access policy allowlist` |

## 설계 결정

### 왜 재시작 후 재실행 방식인가?

Claude Code의 채널 기능은 `--channels` 플래그로 시작된 세션에서만 동작합니다. Claude 자신이 세션을 재시작할 수 없기 때문에, **Phase 6에서 일단 멈추고** 사용자가 새 세션으로 재시작하면 **Phase 7부터 재개**하도록 resume detection 로직을 넣었습니다.

Resume 조건: `~/.claude/channels/telegram/.env` 파일이 존재하면 토큰 설정까지 완료된 것으로 판단하고 페어링 단계로 점프합니다.

### 토큰 validation

BotFather 토큰은 `숫자ID:35자이상_Base64` 패턴입니다. 정규식으로 사전 검증하여 오타로 인한 삽질을 방지합니다.

### Bun 설치 후 PATH 처리

Claude가 Bash 명령을 실행할 때 각 호출은 별도의 서브셸이므로 `export`로 설정한 환경변수가 다음 명령에 유지되지 않습니다. 따라서 두 단계로 처리합니다:

1. **현재 세션**: 설치 직후 검증은 `bun` 명령 대신 `~/.bun/bin/bun` 풀 경로를 사용합니다.
2. **영구 등록**: `$SHELL`을 읽어 현재 셸을 감지한 뒤 알맞은 rc 파일에 PATH를 추가합니다.
   - `zsh` → `~/.zshrc`
   - `bash` → `~/.bashrc`
   - `fish` → `~/.config/fish/config.fish` (문법도 `set -gx`로 분기)
   - 기타 → `~/.profile`

### allowlist 정책을 마지막에 적용하는 이유

페어링이 성공해야 본인의 sender ID가 등록됩니다. 페어링 전에 allowlist를 적용하면 본인도 차단될 수 있으므로 반드시 페어링 → allowlist 순서를 유지합니다.

## 사용법

### 1. skill 설치

이 디렉토리를 사용할 프로젝트의 `.claude/skills/` 에 복사합니다.

```bash
cp -r telegram-channel-setup ~/.claude/skills/
# 또는 특정 프로젝트에만 설치
cp -r telegram-channel-setup /your/project/.claude/skills/
```

### 2. skill 실행

Claude Code 세션에서:

```
/telegram-channel-setup
```

### 3. 진행 흐름

실행하면 Claude가 아래 순서로 안내합니다. 사용자 입력이 필요한 시점에는 자동으로 멈추고 안내 메시지를 표시합니다.

```
[자동] 사전 조건 확인 (Bun, Claude Code 버전)
[자동] 마켓플레이스 등록
[자동] telegram 플러그인 설치
  ↓
[입력] BotFather 토큰 붙여넣기
  ↓
[자동] 토큰 저장 및 검증
  ↓
[실행] claude --channels plugin:telegram@claude-plugins-official 으로 재시작
  ↓
/telegram-channel-setup 재실행 (자동으로 페어링 단계부터 이어서 시작)
  ↓
[입력] 봇에서 받은 페어링 코드 입력
  ↓
[자동] allowlist 정책 적용 → 완료
```

### 4. 완료 후 매일 사용하는 방법

채널 모드로 Claude Code를 시작:

```bash
claude --channels plugin:telegram@claude-plugins-official
```

백그라운드에서 항상 켜두기 (tmux):

```bash
tmux new-session -d -s claude-telegram 'claude --channels plugin:telegram@claude-plugins-official'
```

## 전제 조건

- Claude Code v2.1.80 이상
- claude.ai 계정으로 로그인된 상태 (Console/API key 인증은 channels 미지원)
- Team/Enterprise 플랜의 경우 관리자가 `channelsEnabled: true` 설정 필요
