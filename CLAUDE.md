# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This repository is both a **Claude Code plugin marketplace** and a **source-of-truth (SoT) collection** of reusable harness assets — skills, agents, the harness R&D framework, and the user-template that drives `/harness`. The same content is exposed two ways:

1. **Plugin marketplace** (primary, multi-machine): `/plugin marketplace add hnts03/harness-collections` → `/plugin install harness@harness-collections`. Bundles `/pm`, `/harness`, 5 harness-family helper skills, 2 utility skills, and 7 sub-agents.
2. **Worktree-symlink install** (secondary, local-dev): `scripts/install-harness.sh` creates a per-project git worktree and symlinks the same 9 skills + 7 agents into that project's `.claude/`. Use this when you want to customize the harness per project on a dedicated branch.

The R&D framework's own operating principles live in `collections/harness-framework/CLAUDE.md` — that is the working environment for evolving the reference team.

## Directory Structure

- `.claude-plugin/marketplace.json` — Marketplace manifest. Declares the `harness` plugin and its source path.
- `plugins/harness/` — **Plugin view layer**. Contains `.claude-plugin/plugin.json` and symlinks into the SoT locations. **Do not edit content here** — edit the SoT and the symlinks reflect the change.
- `claude-skills/` — **SoT for utility skills** (`commit`, `telegram-channel-setup`). Each subdirectory holds `SKILL.md` + `README.md`.
- `claude-agents/` — Reserved for future utility agents (currently empty). Agents needed by `/pm` live in `collections/harness-framework/.claude/agents/`.
- `collections/harness-framework/` — **The actively developed R&D harness.** Contains `.claude/skills/`, `.claude/agents/`, `harness-skill-template.md`, session-history docs, and its own `CLAUDE.md` with operating principles.
- `scripts/` — `install-harness.sh`, `sync-user-template.sh`, etc.

## SoT ↔ Plugin View Layer

| Asset class | SoT location | Plugin view |
|---|---|---|
| Harness-family skills (7) | `collections/harness-framework/.claude/skills/<name>/SKILL.md` | `plugins/harness/skills/<name>` — directory symlink |
| Sub-agents (7) | `collections/harness-framework/.claude/agents/<name>.md` (single .md) | `plugins/harness/agents/<name>.md` — file symlink |
| Utility skills (2) | `claude-skills/<name>/SKILL.md` | `plugins/harness/skills/<name>` — directory symlink |
| user-template (1 + 4 refs) | `collections/harness-framework/harness-skill-template.md` + `harness-skill-template/references/*.md` | Copy in `collections/harness-framework/.claude/skills/harness/references/user-template/` — sync via `scripts/sync-user-template.sh` |

The user-template is **copied, not symlinked**, because plugin install only ships files under the plugin source path. The symlink target outside that path would resolve to nothing on a freshly installed machine. The sync script keeps the two in step; run it (or its `--check` form in CI) whenever the SoT changes.

## Authoring Conventions

### Adding a new harness-family skill or agent

1. Author the file in `collections/harness-framework/.claude/{skills|agents}/` following that framework's `CLAUDE.md` and `harness-skill-template.md`.
2. Add the view-layer symlink:
   ```bash
   ln -sf ../../../collections/harness-framework/.claude/skills/<name>   plugins/harness/skills/<name>
   # or, for an agent:
   ln -sf ../../../collections/harness-framework/.claude/agents/<name>.md plugins/harness/agents/<name>.md
   ```
3. Bump version (see "Versioning" below).
4. Run `/harness-benchmark` if a `description` field was added or modified (required by `harness-skill-template/references/skill-authoring-conventions.md`).

### Adding a new utility skill

1. Author `claude-skills/<name>/{SKILL.md, README.md}`. README must include 사용법 + 설계 결정 sections.
2. Add the symlink: `ln -sf ../../../claude-skills/<name> plugins/harness/skills/<name>`
3. Bump version.

### Agent file format

Sub-agents under `collections/harness-framework/.claude/agents/` are **single `.md` files** with frontmatter:

```markdown
---
name: agent-name
description: 이 에이전트가 하는 일 한 줄 설명
---

<agent prompt content>
```

This is the Claude Code plugin standard. Agents authored as directories with `AGENT.md` (older convention) are not supported in the plugin view layer — convert to single-file form first.

## Versioning

Bump `plugins/harness/.claude-plugin/plugin.json` `version` **AND** `.claude-plugin/marketplace.json` plugin entry `version` together — they must match for `/plugin update` to detect a new release on other machines.

- **patch** (1.1.x) — bugfix in a skill/agent body, no API surface change
- **minor** (1.x.0) — new skill or agent added, or material content rewrite
- **major** (x.0.0) — directory layout change, plugin rename, breaking invocation change

A `description` field change always requires a benchmark (`/harness-benchmark`) regardless of version bump size.

## Git Workflow

커밋할 때는 반드시 `/commit` 스킬(루트 utility) 또는 `/clean-commit`(harness 자산 변경 시)을 사용하세요. 직접 `git commit` 명령어를 실행하지 마세요.

## Role Context

When evolving this repository:
- Author skills and agents in their SoT location; let the plugin view layer be derived.
- Prefer editing existing assets over creating new ones (cost test: "Without this new file, would something fail?").
- Keep `description` fields specific and trigger-explicit — see `collections/harness-framework/harness-skill-template/references/skill-authoring-conventions.md`.
- For changes to the R&D framework itself, follow the principles in `collections/harness-framework/CLAUDE.md` — particularly: no unauthorized direction-setting, no opaque codenames, restrict "phase" terminology in user-facing reports.
