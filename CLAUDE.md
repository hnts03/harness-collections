# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This is a collection of reusable Claude Code harness assets: skills, techniques, and prompt collections. The primary goal is to produce drop-in `.claude/skills/` directories that users can copy into any project and use immediately.

## Directory Structure

- `claude-skills/` — Claude skill definitions. Treat this directory as the equivalent of `.claude/skills/`. Each subdirectory is a standalone skill.
- `claude-agents/` — Claude agent definitions. Each subdirectory is a standalone agent with a defined role, responsibilities, and prompt.
- `collections/` — Curated bundles of related skills or configurations for specific use cases.
- `scripts/` — Standalone scripts and patterns for Claude automation (e.g., session keep-alive loops).

## Agent Authoring Convention

각 agent는 `claude-agents/` 하위의 독립 디렉토리에 위치한다. Agent 디렉토리에는 반드시 `AGENT.md` 파일이 있어야 한다.

`AGENT.md`는 Claude Code의 `Agent` tool에 `prompt` 파라미터로 전달되는 실행 프롬프트다. 다음 형식을 따른다:

```markdown
---
name: agent-name
description: 이 에이전트가 하는 일 한 줄 설명
---

<agent prompt content>
```

**Agent 프롬프트 작성 원칙:**
- 에이전트가 수행할 STEP을 번호 순서로 명확히 나열한다.
- 입력(Context 블록)과 출력(반환 형식)을 명시한다.
- 에이전트가 스스로 판단해야 하는 경우와 caller에게 위임해야 하는 경우를 구분한다.
- 실패 시 스스로 재시도하지 않고 실패 결과를 반환하는 원칙을 지킨다 (Worker 등).

Agent를 호출하는 상위 에이전트(PM, Architect 등)는 `Agent` tool을 사용할 때 다음 방식으로 프롬프트를 구성한다:
1. `cat .claude/agents/{name}/AGENT.md`로 에이전트 프롬프트를 로드한다.
2. 로드한 프롬프트 뒤에 Context 블록(실행 컨텍스트)을 추가한다.
3. 합쳐진 내용을 Agent tool의 `prompt` 파라미터로 전달한다.

배포 경로: `claude-agents/{name}/` → `.claude/agents/{name}/`

## Skill Authoring Convention

Each skill lives in its own subdirectory under `claude-skills/`. A skill directory must contain:

1. **`SKILL.md`** — The skill prompt file (the actual entrypoint Claude reads when the skill is invoked). The filename is always `SKILL.md` — the directory name determines the `/skill-name` command.
2. **`README.md`** — Must include two sections:
   - **사용법 (Usage)**: How to install the skill (copy path) and invoke it (`/skill-name`), the step-by-step flow showing which steps are automatic vs. require user input, and how to use it after setup is complete.
   - **설계 결정 (Design decisions)**: Why the prompt is structured this way, what problem it solves, and any non-obvious implementation choices.

A skill directory should be fully self-contained so that copying it into a project's `.claude/skills/` makes it immediately usable with no additional setup.

### Skill Prompt File Format

`SKILL.md` must follow the Claude Code skill schema:

```markdown
---
name: skill-name
description: One-line description shown in skill picker
---

<skill prompt content>
```

The `description` field is what surfaces in `/` command listings, so make it action-oriented and specific.

## Git Workflow

커밋할 때는 반드시 `/commit` 스킬을 사용하세요. 직접 `git commit` 명령어를 실행하지 마세요.

## Role Context

When creating skills in this repo, operate as a senior harness engineering expert. Skills should:
- Be opinionated and production-ready, not generic templates
- Encode hard-won patterns (e.g., hook configuration, permission scoping, multi-step orchestration)
- Include README.md rationale so future maintainers understand *why*, not just *what*
