# harness-collections

Reusable Claude Code harness assets — skills, agents, and prompt collections.  
Each asset is designed to be dropped into any project and used immediately with no additional setup.

## Directory Structure

```
harness-collections/
├── claude-skills/       # Drop-in skill definitions (.claude/skills/)
├── claude-agents/       # Agent prompt definitions (.claude/agents/)
├── collections/         # Curated references and external resource bundles
└── scripts/             # Standalone scripts and automation patterns
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
| [commit](claude-skills/commit/) | Run style checks, fix issues, and commit without AI co-author attribution | `/commit` |
| [project-manager](claude-skills/project-manager/) | Dev-PM — refine requirements, generate an atomic task plan, and orchestrate sub-agents end-to-end | `/project-manager` |
| [telegram-channel-setup](claude-skills/telegram-channel-setup/) | Automate end-to-end Telegram bot ↔ Claude Code channels integration | `/telegram-channel-setup` |

## Agents

Agents are prompt definitions consumed by the Claude Code `Agent` tool. They are not invoked directly by the user — a parent skill or agent spawns them at runtime.

Install by copying into your project's `.claude/agents/`:

```bash
cp -r claude-agents/<agent-name> /your/project/.claude/agents/
```

### Available Agents

| Agent | Description | Spawned by |
|-------|-------------|------------|
| [worker](claude-agents/worker/) | Executes a single atomic task; reports what/how/why on failure | PM |
| [reviewer](claude-agents/reviewer/) | Critically reviews group implementation; returns `OK` or `REWORK` with a quality score | PM |
| [qa](claude-agents/qa/) | Plans and runs integration tests after all groups complete; writes `qa-report.md` | PM |
| [tech-writer](claude-agents/tech-writer/) | Consolidates all artifacts into `final-report.md` | PM |

### Project Manager Agent Architecture

The `project-manager` skill drives a layered multi-agent system:

```
/project-manager (skill)
└── PM  ←─ orchestrates everything directly (flat, per Claude Code sub-agent constraints)
    ├── Worker × N  (atomic tasks per group, parallel where possible)
    ├── Reviewer    (per group, OK / REWORK + quality score, up to 5 rounds)
    ├── QA
    └── TechWriter
```

**Orchestration model:** PM manages state via `project-plan.md` (file-based, persistent). Workers, Reviewer, QA, and TechWriter are leaf sub-agents spawned directly by PM via the `Agent` tool. Sub-agents cannot spawn other sub-agents per Claude Code constraints.

See [claude-agents/project-manager/SPEC.md](claude-agents/project-manager/SPEC.md) for the full architecture spec.

## Installation

### Recommended: symlink install (stays in sync with updates)

`install-harness.sh` creates absolute-path symlinks from any project into this repo. Running `git pull` on harness-collections immediately reflects in all linked projects.

```bash
# From your project root
bash /path/to/harness-collections/scripts/install-harness.sh

# Also update .gitignore automatically
bash /path/to/harness-collections/scripts/install-harness.sh --gitignore

# Preview without making changes
bash /path/to/harness-collections/scripts/install-harness.sh --dry-run

# Overwrite existing symlinks
bash /path/to/harness-collections/scripts/install-harness.sh --force
```

After install, your project will have:

```
.claude/
├── skills/
│   ├── commit              -> .../harness-collections/claude-skills/commit/
│   ├── project-manager     -> .../harness-collections/claude-skills/project-manager/
│   └── telegram-channel-setup -> ...
└── agents/
    ├── worker.md           -> .../harness-collections/claude-agents/worker/AGENT.md
    ├── reviewer.md         -> ...
    ├── qa.md               -> ...
    └── tech-writer.md      -> ...
```

### Alternative: copy individual assets

```bash
# Single skill
cp -r claude-skills/<skill-name> /your/project/.claude/skills/

# Single agent
cp claude-agents/<agent-name>/AGENT.md /your/project/.claude/agents/<agent-name>.md
```

## Scripts

Standalone scripts for Claude automation patterns.

| Script | Description |
|--------|-------------|
| [install-harness.sh](scripts/install-harness.sh) | Symlink-install all skills and agents into any project (`--force`, `--dry-run`, `--gitignore`) |
| [auto-refresher.sh](scripts/auto-refresher.sh) | Keep-alive loop that refreshes Claude sessions every 5 hours |
| [configure-attribution.sh](scripts/configure-attribution.sh) | Patch Claude co-author attribution strings at user or project scope |

## Collections

Curated references and external resource bundles by domain.

| Collection | Description |
|------------|-------------|
| [harness-framework](collections/harness-framework/) | Comparison of deployed harness frameworks (paperclip, gitagent, harness) |
| [skills](collections/skills/) | References to externally authored skill collections (harness-100, etc.) |

## Conventions

- Each skill directory contains `SKILL.md` (entrypoint prompt) and `README.md` (usage + design decisions).
- Each agent directory contains `AGENT.md` (prompt passed to the `Agent` tool).
- `SKILL.md` / `AGENT.md` frontmatter: `name` (identifier), `description` (shown in `/` picker).
- See [CLAUDE.md](CLAUDE.md) for full authoring guidelines.
