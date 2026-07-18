# Roadmap Skill

[한국어](README.ko.md)

`roadmap` is a reusable [Agent Skills](https://agentskills.io/)-compatible skill for Codex, Claude Code, OpenClaw, and other compatible agents. It can inspect an existing roadmap without changing it or bootstrap a canonical roadmap with independently verifiable work sessions after resolving material planning questions.

Invoke the skill for a read-only inspection or when creating or materially revising the roadmap. The generated session prompts are self-contained: each one updates the roadmap and produces the following prompt, so later sessions do not need to invoke the skill again.

## What it does

- Reads applicable user and project instructions, available project memory, documentation, Git state, implementation, tests, and verification configuration before planning.
- Reports prioritized findings and stops without changing files when the request is inspection-only.
- Treats memory and historical handoffs as discovery leads, then rechecks changeable claims against current evidence.
- Asks only the highest-impact unresolved question, one topic per message, instead of drafting a roadmap from material assumptions.
- Proposes dependency- and risk-aware session sequencing and obtains user approval before locking priorities.
- Splits work into sessions with one primary outcome, explicit scope, prerequisites, shared boundaries, completion criteria, and verification.
- Models safe parallel work with ownership boundaries, roadmap update responsibility, and convergence points.
- Lets the user choose Detailed or compact self-contained prompts and preserves that project-level policy.
- Keeps incomplete work in the same session when required evidence is missing.
- Applies concise read-first, minimal-change, test, debugging, dependency, and verification defaults when project instructions do not provide more specific rules.

## Installation

### Prerequisites

- Git
- Bash
- Codex, Claude Code, OpenClaw, or another Agent Skills-compatible agent

### Install for Codex, Claude Code, and OpenClaw

Clone the repository and run the installer:

```bash
git clone https://github.com/hawkstrike/roadmap.git
cd roadmap
bash roadmap/scripts/install.sh
```

The installer copies the same skill to two shared user-level locations. OpenClaw discovers the Codex installation through its supported personal-agent skill root, so it does not need a duplicate copy under `~/.openclaw/skills`.

| Client | Installation path | Initial invocation |
| --- | --- | --- |
| Codex | `~/.agents/skills/roadmap` | `$roadmap` or the skill picker |
| Claude Code | `~/.claude/skills/roadmap` | `/roadmap` |
| OpenClaw | `~/.agents/skills/roadmap` | `/roadmap` |

Start a new client session after installation so the agent can discover the skill. See the [OpenClaw skills documentation](https://docs.openclaw.ai/tools/skills) for its loading order, visibility controls, and additional installation scopes.

The installer can be run again to update an existing installation. It validates both destinations before replacing them and refuses to overwrite a directory that is not identifiable as the `roadmap` skill. If either installation cannot be updated, it restores the previous state of both destinations.

### Install for another compatible agent

If an Agent Skills-compatible client does not load `~/.agents/skills`, copy the complete `roadmap` directory into that client's documented skill root:

```bash
cp -R roadmap /path/to/agent/skills/roadmap
```

Keep `SKILL.md`, `references/`, and any other files together because the skill uses relative references. Use the invocation method documented by the client; clients that expose the frontmatter `name` as a slash command typically use `/roadmap`.

### Update

From the cloned repository:

```bash
git pull
bash roadmap/scripts/install.sh
```

## Usage

Invoke the skill explicitly to perform a read-only inspection, create a new roadmap, or reconsider a roadmap's goals, priorities, or structure. You may write the request in any language supported by the client; the skill follows the user and project instructions.

For a read-only inspection, ask the skill to compare an existing roadmap with current project evidence. It reports findings without requesting sequencing or prompt-format approval and does not modify the roadmap unless you subsequently request a revision.

### Codex

```text
$roadmap Inspect this repository and create a roadmap for adding team-based access control. Resolve material questions one topic at a time, then split the approved scope into independently verifiable sessions.
```

### Claude Code

```text
/roadmap Inspect this repository and create a roadmap for adding team-based access control. Resolve material questions one topic at a time, then split the approved scope into independently verifiable sessions.
```

### OpenClaw

```text
/roadmap Inspect this repository and create a roadmap for adding team-based access control. Resolve material questions one topic at a time, then split the approved scope into independently verifiable sessions.
```

### Other compatible agents

Invoke the installed `roadmap` skill using the client's skill picker, slash command, or explicit skill syntax. The skill itself does not depend on Codex- or Claude-specific tools.

## Creation and revision workflow

1. Inspect current instructions, memory, documentation, Git, implementation, tests, and verification evidence.
2. Ask one material discovery question at a time until the goal and scope are clear.
3. Propose session sequencing and parallel tracks, explain material tradeoffs, and obtain approval.
4. Ask the user to choose Detailed or compact prompts when the roadmap has no prompt policy.
5. Create or revise the canonical roadmap and generate the first self-contained session prompt.
6. Let each session update the roadmap and generate the following prompt.

The later prompts read the canonical roadmap and carry their own scope, verification, completion, closeout, and handoff rules. They do not need another skill invocation or previous conversation history.

## Prompt formats

### Detailed

Detailed prompts repeat shared execution rules, completion decisions, closeout order, and handoff requirements. They are longer but more portable when project instructions are sparse or environments differ.

### Compact

Compact prompts read durable rules from the canonical roadmap and carry the current session's scope, evidence, closeout, and handoff details. They are shorter but depend on careful roadmap maintenance.

The selected format applies to completed-session and continuation prompts until the user explicitly changes it.

## Session behavior

A session prompt identifies the working path, applicable instructions, canonical roadmap, previous result, current goal, included and excluded scope, prerequisites, shared ownership, completion criteria, and required verification. It preserves user-owned changes and requires fresh evidence before completion.

At closeout, the session reports implementation, verification, Git state, and risks; updates roadmap evidence, status, current and next sessions, and change history; then generates another self-contained prompt. Failed or missing verification produces a continuation prompt for the same session instead of advancing.

Parallel prompts declare separate file, data, external-resource, and roadmap-update ownership. One owner or a convergence session updates shared parent-roadmap state.

## Project structure

```text
roadmap/
├── SKILL.md
├── agents/
│   └── openai.yaml
├── references/
│   ├── roadmap-structure.md
│   └── session-closeout.md
└── scripts/
    └── install.sh
```

- `SKILL.md` defines discovery, approval, and bootstrap workflow.
- `references/roadmap-structure.md` defines durable roadmap rules, session sizing, sequencing, and parallel ownership.
- `references/session-closeout.md` defines completion decisions plus Detailed and compact self-contained prompt templates.
- `agents/openai.yaml` provides Codex-specific display metadata.
- `scripts/install.sh` safely installs or updates the shared paths used by Codex, Claude Code, and OpenClaw.

## Development and verification

Run the portable installation and content regression tests plus structural checks from the repository root:

```bash
bash tests/install-roadmap-skill.sh
bash tests/validate-roadmap-content.sh
bash -n roadmap/scripts/install.sh
git diff --check
```

In Codex development environments, also run the upstream skill structure validator:

```bash
python3 "${CODEX_HOME:-$HOME/.codex}/skills/.system/skill-creator/scripts/quick_validate.py" roadmap
```
