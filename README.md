# harness-collections

A **Claude Code plugin marketplace** that bundles the harness R&D framework — `/pm` (PM orchestration), `/harness` (meta-skill with the user-template auto-loaded), six harness-family skills, two utility skills, and the seven sub-agents that PM spawns — all installable on any machine with one command.

## Quick install (any machine)

```bash
# In Claude Code
/plugin marketplace add hnts03/harness-collections
/plugin install harness@harness-collections
```

To update later: `/plugin update harness@harness-collections`.

## What's in the `harness` plugin

### Skills (9)

| Skill | Description | Invoke |
|-------|-------------|--------|
| [pm](collections/harness-framework/.claude/skills/pm/) | Start a harness R&D session — spawns the PM agent which orchestrates the rest of the team | `/pm` |
| [harness](collections/harness-framework/.claude/skills/harness/) | **Meta-skill.** Design a new harness from scratch. Auto-loads `references/user-template/harness-skill-template.md` first | `/harness` |
| [create-agent](collections/harness-framework/.claude/skills/create-agent/) | Author a new agent definition file | `/create-agent` |
| [create-skill](collections/harness-framework/.claude/skills/create-skill/) | Author a new skill (with trigger matrix) | `/create-skill` |
| [harness-benchmark](collections/harness-framework/.claude/skills/harness-benchmark/) | Trigger accuracy + with/without A/B benchmark; mandatory after editing a `description` field | `/harness-benchmark` |
| [clean-commit](collections/harness-framework/.claude/skills/clean-commit/) | Commit harness files without co-author attribution; with DCO Signed-off-by | `/clean-commit` |
| [update-from-phase](collections/harness-framework/.claude/skills/update-from-phase/) | Phase completion bundling: dev-plan update + CLAUDE.md + memory + commit & push | `/update-from-phase` |
| [commit](claude-skills/commit/) | General-purpose commit (style checks + co-author removal) | `/commit` |
| [telegram-channel-setup](claude-skills/telegram-channel-setup/) | Telegram bot ↔ Claude Code channels end-to-end setup | `/telegram-channel-setup` |

### Sub-agents (7)

Spawned by `/pm` — not invoked directly by users.

| Agent | Model | Role |
|-------|-------|------|
| [project-manager](collections/harness-framework/.claude/agents/project-manager.md) | opus | Resume detection → plan → orchestration |
| [harness-architect](collections/harness-framework/.claude/agents/harness-architect.md) | opus | Pattern/technique design from researcher's output |
| [researcher](collections/harness-framework/.claude/agents/researcher.md) | opus | Deep investigation of relevant patterns/techniques |
| [reviewer](collections/harness-framework/.claude/agents/reviewer.md) | opus | Quality review of artifacts |
| [qa](collections/harness-framework/.claude/agents/qa.md) | opus | Phase-level verification |
| [worker](collections/harness-framework/.claude/agents/worker.md) | sonnet | Atomic-task implementation |
| [document-writer](collections/harness-framework/.claude/agents/document-writer.md) | sonnet | Final documentation |

### What changed in 1.1.0 (vs 1.0.x)

| 1.0.x (`harness-marketplace`) | 1.1.0 (`harness-collections`) |
|---|---|
| `/harness` meta-skill only — you had to design every agent and skill from scratch | `/harness` **+ the actually running reference harness team**: `/pm` orchestration skill, 7 sub-agents, and 5 harness-family helper skills (`create-agent`, `create-skill`, `harness-benchmark`, `clean-commit`, `update-from-phase`) |
| Meta-skill referenced no user template | `/harness` auto-loads `references/user-template/harness-skill-template.md` (v0.5.0) — your team-building principles, PM behavior, and skill-authoring conventions take precedence over the generic workflow |
| Separate repos for marketplace and other assets | One repo, one marketplace, one plugin. Daily utility skills (`commit`, `telegram-channel-setup`) ship in the same bundle. |

## Repository layout

```
harness-collections/
├── .claude-plugin/
│   └── marketplace.json                            # marketplace manifest
├── plugins/
│   └── harness/                                    # plugin view layer (all symlinks → SoT)
│       ├── .claude-plugin/plugin.json
│       ├── skills/<name>                           # → SoT (collections/.../skills/<name> or claude-skills/<name>)
│       └── agents/<name>.md                        # → collections/harness-framework/.claude/agents/<name>.md
├── claude-skills/                                  # SoT for utility skills (commit, telegram-channel-setup)
├── claude-agents/                                  # reserved for future utility agents (currently empty)
├── collections/
│   └── harness-framework/                          # the actively developed R&D harness
│       ├── .claude/
│       │   ├── skills/                             # SoT for harness-family skills (7)
│       │   │   └── harness/references/user-template/  # synced from harness-skill-template.md
│       │   └── agents/                             # SoT for harness sub-agents (7)
│       ├── harness-skill-template.md               # user-template SoT (v0.5.0)
│       ├── harness-skill-template/references/      # 4 progressive-disclosure references
│       ├── CLAUDE.md                               # operational principles
│       └── docs/phase_NNN/                         # session history
└── scripts/
    ├── install-harness.sh                          # worktree+symlink install (local dev)
    ├── sync-user-template.sh                       # rsync harness-skill-template → /harness references
    ├── auto-refresher.sh
    └── configure-attribution.sh
```

### Source-of-truth ↔ plugin view layer

| Asset | SoT location | Plugin view |
|---|---|---|
| Harness-family skills (7) | `collections/harness-framework/.claude/skills/<name>/SKILL.md` | `plugins/harness/skills/<name>` → symlink |
| Sub-agents (7) | `collections/harness-framework/.claude/agents/<name>.md` (single .md) | `plugins/harness/agents/<name>.md` → symlink |
| Utility skills (2) | `claude-skills/<name>/SKILL.md` | `plugins/harness/skills/<name>` → symlink |
| user-template | `collections/harness-framework/harness-skill-template.md` (+ `harness-skill-template/references/`) | Copy under `collections/.../skills/harness/references/user-template/` — keep synced via `scripts/sync-user-template.sh` |

**Adding a new global skill**:
```bash
# 1. Author SKILL.md (utility → claude-skills/<name>/; harness-family → collections/harness-framework/.claude/skills/<name>/)
# 2. Add the view-layer symlink:
ln -sf ../../../claude-skills/<name> plugins/harness/skills/<name>
#    or for harness-family:
ln -sf ../../../collections/harness-framework/.claude/skills/<name> plugins/harness/skills/<name>
# 3. Bump version in plugins/harness/.claude-plugin/plugin.json and .claude-plugin/marketplace.json
```

**After editing `collections/harness-framework/harness-skill-template.md`**:
```bash
bash scripts/sync-user-template.sh           # update the copy
bash scripts/sync-user-template.sh --check   # CI: fail if drifted
```

## Alternative install: worktree + symlink (local dev)

For when you want a **per-project git branch** to customize harness assets and selectively pull upstream updates. Plugin install (above) is recommended for everything else.

```bash
git clone https://github.com/hnts03/harness-collections
bash /path/to/harness-collections/scripts/install-harness.sh           # from your project root
bash /path/to/harness-collections/scripts/install-harness.sh --gitignore
bash /path/to/harness-collections/scripts/install-harness.sh --dry-run
bash /path/to/harness-collections/scripts/install-harness.sh --force
```

What happens:

1. Creates a git branch named `<project-name>` and a worktree at `harness-collections/worktrees/<project-name>/`.
2. Symlinks 9 skills and 7 agents into your project's `.claude/skills/` and `.claude/agents/`.

Customize on the project branch; merge `main` when you want upstream changes.

## Scripts

| Script | Description |
|--------|-------------|
| [install-harness.sh](scripts/install-harness.sh) | Per-project worktree + symlink install (`--force`, `--dry-run`, `--gitignore`) |
| [sync-user-template.sh](scripts/sync-user-template.sh) | Sync `harness-skill-template.md` SoT into the plugin copy (`--check` for CI) |
| [auto-refresher.sh](scripts/auto-refresher.sh) | Keep-alive loop refreshing Claude sessions every 5 hours |
| [configure-attribution.sh](scripts/configure-attribution.sh) | Patch Claude co-author attribution strings at user or project scope |

## Conventions

- Skills under `claude-skills/`: `<name>/{SKILL.md, README.md}` (utility skills).
- Skills under `collections/harness-framework/.claude/skills/`: `<name>/SKILL.md` (harness-family).
- Agents: single `.md` file with frontmatter (`collections/harness-framework/.claude/agents/<name>.md`).
- See [CLAUDE.md](CLAUDE.md) for the full SoT ↔ plugin view layer rules and versioning.
- The R&D framework's own operating principles live in [`collections/harness-framework/CLAUDE.md`](collections/harness-framework/CLAUDE.md).
