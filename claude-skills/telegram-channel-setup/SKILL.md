---
name: telegram-channel-setup
description: Telegram 봇과 Claude Code channels를 연결하는 전체 세팅을 자동화합니다
---

You are setting up a Telegram ↔ Claude Code channel integration. Follow each phase in order. Stop and ask the user only at the marked USER INPUT points — everything else you handle automatically.

---

## RESUME DETECTION — Run this first, before anything else

Check whether a previous run already completed token configuration:

```bash
cat ~/.claude/channels/telegram/.env 2>/dev/null && echo "CONFIGURED" || echo "NOT_CONFIGURED"
```

Also check whether this session was started with `--channels`:

```bash
ps aux | grep "claude.*--channels" | grep -v grep && echo "CHANNELS_ACTIVE" || echo "NO_CHANNELS"
```

**Decision:**
- If output is `CONFIGURED` **and** `CHANNELS_ACTIVE` → skip directly to **PHASE 7 (Pairing)**. Do not run PHASE 1–6.
- If output is `CONFIGURED` but `NO_CHANNELS` → tell the user:
  > 토큰 설정은 완료되어 있습니다. `--channels` 플래그로 재시작한 뒤 `/telegram-channel-setup` 을 다시 실행하면 PHASE 7(페어링)부터 이어서 진행됩니다.
  > ```bash
  > source <SHELL_RC> && claude --channels plugin:telegram@claude-plugins-official
  > ```
  Then stop.
- If `NOT_CONFIGURED` → continue to PHASE 1 as normal.

---

## PHASE 1 — Prerequisite check

Run these checks and report results before proceeding:

```bash
echo "=== Claude Code version ===" && claude --version
echo "=== Bun version ===" && (bun --version 2>/dev/null || ~/.bun/bin/bun --version 2>/dev/null || echo "NOT INSTALLED")
echo "=== Telegram .env ===" && cat ~/.claude/channels/telegram/.env 2>/dev/null || echo "NOT CONFIGURED"
```

**If Bun is NOT INSTALLED**, run the official installer:
```bash
curl -fsSL https://bun.sh/install | bash
```

Then verify using the full path (shell PATH is not yet updated in this session):
```bash
~/.bun/bin/bun --version
```

If the above succeeds, detect the current shell and persist the PATH to the appropriate config file:
```bash
CURRENT_SHELL="$(basename "$SHELL")"
case "$CURRENT_SHELL" in
  zsh)  SHELL_RC="${ZDOTDIR:-$HOME}/.zshrc" ;;
  bash) SHELL_RC="$HOME/.bashrc" ;;
  fish) SHELL_RC="${XDG_CONFIG_HOME:-$HOME/.config}/fish/config.fish" ;;
  *)    SHELL_RC="$HOME/.profile" ;;
esac
echo "Detected shell: $CURRENT_SHELL → $SHELL_RC"
```

Then write the PATH entry (fish uses a different syntax):
```bash
if [ "$CURRENT_SHELL" = "fish" ]; then
  grep -q 'BUN_INSTALL' "$SHELL_RC" 2>/dev/null \
    || printf '\n# Bun\nset -gx BUN_INSTALL "$HOME/.bun"\nset -gx PATH "$BUN_INSTALL/bin" $PATH\n' >> "$SHELL_RC" \
    && echo "PATH entry written to $SHELL_RC"
else
  grep -q 'BUN_INSTALL' "$SHELL_RC" 2>/dev/null \
    || printf '\n# Bun\nexport BUN_INSTALL="$HOME/.bun"\nexport PATH="$BUN_INSTALL/bin:$PATH"\n' >> "$SHELL_RC" \
    && echo "PATH entry written to $SHELL_RC"
fi
```

**Then tell the user** (substitute `$SHELL_RC` and `$CURRENT_SHELL` with the actual detected values):
> Bun이 설치되었습니다. 셸 설정(`$SHELL_RC`)에 PATH가 추가되었으니, 새 터미널을 열거나 아래 명령어를 실행하면 `bun` 명령어를 바로 사용할 수 있습니다:
> ```bash
> source $SHELL_RC   # fish는: source $SHELL_RC 또는 새 터미널
> ```
> 지금 이 세션에서는 내부적으로 `~/.bun/bin/bun` 풀 경로를 사용하여 계속 진행합니다.

Tell the user if their Claude Code version is below v2.1.80 (channels require it) and stop if so.

If Telegram is already configured (`.env` exists), ask the user: "Telegram이 이미 설정되어 있습니다. 처음부터 다시 설정하시겠습니까? (y/n)" — stop if they say no.

---

## PHASE 2 — Marketplace setup

In Claude Code, run:
```
/plugin marketplace update claude-plugins-official
```

If that command fails with "marketplace not found", run:
```
/plugin marketplace add anthropics/claude-plugins-official
```
Then retry the update.

---

## PHASE 3 — Plugin install

Run:
```
/plugin install telegram@claude-plugins-official
```

Then activate it:
```
/reload-plugins
```

Confirm the plugin is now listed.

---

## PHASE 4 — USER INPUT: Telegram Bot Token

**Stop here and tell the user:**

---
**[ACTION REQUIRED] Telegram 봇 토큰이 필요합니다.**

아직 봇이 없다면:
1. Telegram에서 [@BotFather](https://t.me/BotFather) 를 열고 `/newbot` 을 보내세요
2. 봇 이름과 username(`bot`으로 끝나야 함)을 설정하세요
3. BotFather가 반환하는 토큰을 복사하세요 (형식: `1234567890:ABCdef...`)

**봇 토큰을 여기에 붙여넣어 주세요:**

---

Wait for the user to provide the token. Validate it matches the pattern `^\d+:[A-Za-z0-9_-]{35,}$`. If it doesn't match, tell the user it looks invalid and ask them to check again.

---

## PHASE 5 — Token configuration

Once you have the valid token, run:
```
/telegram:configure <TOKEN_FROM_USER>
```

Verify the file was written:
```bash
cat ~/.claude/channels/telegram/.env
```

Confirm `TELEGRAM_BOT_TOKEN` is present in the output (mask most of the value when displaying it, e.g. `1234567890:ABCd...`).

---

## PHASE 6 — PATH verification & restart with channels enabled

Before asking the user to restart, verify `bun` is accessible via PATH by sourcing the rc file:

```bash
CURRENT_SHELL="$(basename "$SHELL")"
case "$CURRENT_SHELL" in
  zsh)  SHELL_RC="${ZDOTDIR:-$HOME}/.zshrc" ;;
  bash) SHELL_RC="$HOME/.bashrc" ;;
  fish) SHELL_RC="${XDG_CONFIG_HOME:-$HOME/.config}/fish/config.fish" ;;
  *)    SHELL_RC="$HOME/.profile" ;;
esac

if [ "$CURRENT_SHELL" = "fish" ]; then
  fish -c "source $SHELL_RC; bun --version" 2>/dev/null \
    && echo "✅ bun PATH OK ($SHELL_RC sourced)" \
    || echo "⚠️  bun not in PATH after source — will fall back to full path"
else
  (source "$SHELL_RC" 2>/dev/null && bun --version) \
    && echo "✅ bun PATH OK ($SHELL_RC sourced)" \
    || echo "⚠️  bun not in PATH after source — will fall back to full path"
fi
```

If the check passes, **tell the user:**

---
**[ACTION REQUIRED] Claude Code를 채널 모드로 재시작해야 합니다.**

현재 세션을 종료하고 아래 명령어로 다시 시작하세요.  
rc 파일을 먼저 소싱하여 `bun` PATH를 적용한 뒤 Claude를 시작합니다:

- **zsh / bash:**
  ```bash
  source <SHELL_RC> && claude --channels plugin:telegram@claude-plugins-official
  ```
- **fish:**
  ```fish
  source <SHELL_RC>; and claude --channels plugin:telegram@claude-plugins-official
  ```

재시작한 뒤, 새 세션에서 `/telegram-channel-setup` 을 다시 실행하면 **PHASE 7 (Pairing)** 부터 자동으로 이어서 진행됩니다.

---

If the PATH check failed (⚠️), also include this note in the user message:
> ⚠️ `bun`이 PATH에 없습니다. 재시작 전에 새 터미널을 열거나 위 명령어로 직접 소싱하세요.

**After the user confirms they have restarted**, check if the channel is active:
```bash
ps aux | grep "telegram" | grep -v grep
```
If no telegram process is found, remind the user to restart with the `--channels` flag.

---

## PHASE 7 — Pairing

**Tell the user:**

---
**[ACTION REQUIRED] 봇과 페어링하세요.**

Telegram에서 방금 만든 봇에게 아무 메시지나 보내세요 (예: `hello`).
봇이 페어링 코드를 응답으로 보냅니다.

**페어링 코드를 여기에 입력해 주세요:**

---

Wait for the user to paste the pairing code.

Run:
```
/telegram:access pair <PAIRING_CODE>
```

---

## PHASE 8 — Lock down access

Run:
```
/telegram:access policy allowlist
```

---

## PHASE 9 — Verification & summary

**Tell the user:**

---
**✅ Telegram 채널 연동이 완료되었습니다!**

설정 요약:
- 봇 토큰: `~/.claude/channels/telegram/.env` 에 저장됨
- 접근 정책: allowlist (본인 계정만 허용)

**사용 방법:**
매번 채널 모드로 시작하려면:
```bash
claude --channels plugin:telegram@claude-plugins-official
```

백그라운드에서 항상 켜두려면 (tmux 예시):
```bash
tmux new-session -d -s claude-telegram 'claude --channels plugin:telegram@claude-plugins-official'
```

**테스트:** Telegram에서 봇에게 `현재 디렉토리가 어디야?` 라고 보내보세요.

---

