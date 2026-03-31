# harness-collections

Reusable Claude Code harness assets — skills, techniques, and prompt collections.  
Each asset is designed to be dropped into any project and used immediately with no additional setup.

## Directory Structure

```
harness-collections/
├── claude-skills/       # Drop-in .claude/skills/ directories
├── collections/         # Curated bundles of skills for specific use cases
├── techniques/          # Standalone scripts and automation patterns
└── claude-agents/       # Custom agent definitions
```

## Skills

Install any skill by copying its directory into your project's `.claude/skills/`:

```bash
cp -r claude-skills/<skill-name> /your/project/.claude/skills/
```

Then invoke it in Claude Code with `/<skill-name>`.

### Available Skills

| Skill | Description | Invoke |
|-------|-------------|--------|
| [telegram-channel-setup](claude-skills/telegram-channel-setup/) | Telegram 봇과 Claude Code channels 연동을 end-to-end로 자동화 | `/telegram-channel-setup` |

## Collections

도메인별 큐레이션된 레퍼런스 및 외부 리소스 모음.

| Collection | Description |
|------------|-------------|
| [harness-framework](collections/harness-framework/) | 배포·운영 중인 harness 프레임워크 비교 (paperclip, gitagent, harness) |
| [skills](collections/skills/) | 외부 제작 skill 컬렉션 레퍼런스 (harness-100 등) |

## Techniques

Standalone scripts for Claude automation patterns.

| Script | Description |
|--------|-------------|
| [auto-refresher.sh](techniques/auto-refresher.sh) | Claude 세션을 5시간 간격으로 자동 keep-alive |
| [configure-attribution.sh](techniques/configure-attribution.sh) | Claude co-author attribution 문구를 user/project 범위로 패치 |

## Conventions

- Each skill directory contains `SKILL.md` (entrypoint) and `README.md` (usage + design decisions).
- `SKILL.md` frontmatter: `name` (skill identifier), `description` (shown in `/` picker).
- See [CLAUDE.md](CLAUDE.md) for authoring guidelines.
