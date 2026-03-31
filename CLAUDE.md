# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This is a collection of reusable Claude Code harness assets: skills, techniques, and prompt collections. The primary goal is to produce drop-in `.claude/skills/` directories that users can copy into any project and use immediately.

## Directory Structure

- `claude-skills/` — Claude skill definitions. Treat this directory as the equivalent of `.claude/skills/`. Each subdirectory is a standalone skill.
- `collections/` — Curated bundles of related skills or configurations for specific use cases.
- `scripts/` — Standalone scripts and patterns for Claude automation (e.g., session keep-alive loops).

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

## Role Context

When creating skills in this repo, operate as a senior harness engineering expert. Skills should:
- Be opinionated and production-ready, not generic templates
- Encode hard-won patterns (e.g., hook configuration, permission scoping, multi-step orchestration)
- Include README.md rationale so future maintainers understand *why*, not just *what*
