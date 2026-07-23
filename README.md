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

Install only the client or clients you use. You do not need both Claude Code and Codex. Start a new client session after installation so it can discover the skill.

### Recommended: install with `/plugin`

#### Codex

1. Enter `/plugin` in Codex.
2. From marketplace management, add the GitHub repository `hawkstrike/roadmap`.
3. Select and install the **Roadmap** plugin from the new `roadmap` marketplace.
4. Start a new Codex session and invoke it with `$roadmap`.

#### Claude Code

Enter these commands in Claude Code:

```text
/plugin marketplace add hawkstrike/roadmap
/plugin install roadmap@roadmap
```

Start a new Claude Code session and invoke it with `/roadmap`.

### Alternative: GitHub with `npx skills`

The command is `npx skills`, with `skills` in the plural. The CLI reads this GitHub repository directly, records its source and skill-folder hash, and can update the installation later. It works on macOS, Windows, and Linux wherever its supported Node.js version is available.

Node.js 22.20 or later is required. Run only the command for the client you use:

```bash
npx skills add hawkstrike/roadmap --skill roadmap --global --agent codex
npx skills add hawkstrike/roadmap --skill roadmap --global --agent claude-code
```

When prompted for an installation method, choose the recommended option.

Update a project installation from that project directory, or update a global installation from any directory:

```bash
npx skills update roadmap --project
npx skills update roadmap --global
```

The `skills` CLI manages its own destination paths and lock files. Do not combine this method with a `/plugin` installation for the same client and scope.

### Install for another compatible agent

If an Agent Skills-compatible client does not load `~/.agents/skills`, copy the complete `roadmap` directory into that client's documented skill root:

```bash
cp -R roadmap /path/to/agent/skills/roadmap
```

Keep `SKILL.md`, `references/`, and any other files together because the skill uses relative references. Use the invocation method documented by the client; clients that expose the frontmatter `name` as a slash command typically use `/roadmap`.

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

At closeout, the session reports implementation, verification, Git state, and risks; updates roadmap evidence, status, current and next sessions, and change history; then generates another self-contained prompt. Session statuses always show an emoji and text label together: `✅ Complete`, `🔄 In progress`, `⏳ Pending`, or `❌ Blocked`. Failed or missing verification produces a continuation prompt for the same session instead of advancing.

Parallel prompts declare separate file, data, external-resource, and roadmap-update ownership. One owner or a convergence session updates shared parent-roadmap state.

## Project structure

```text
.agents/plugins/
└── marketplace.json
.claude-plugin/
├── marketplace.json
└── plugin.json
.codex-plugin/
└── plugin.json
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

- `.agents/plugins/marketplace.json` exposes the repository's plugin catalog to Codex.
- `.claude-plugin/marketplace.json` exposes the repository's plugin catalog to Claude Code.
- The Claude Code and Codex `plugin.json` files define plugin metadata and point to the `roadmap/` skill.
- `SKILL.md` defines discovery, approval, and bootstrap workflow.
- `references/roadmap-structure.md` defines durable roadmap rules, session sizing, sequencing, and parallel ownership.
- `references/session-closeout.md` defines completion decisions plus Detailed and compact self-contained prompt templates.
- `agents/openai.yaml` provides Codex-specific display metadata.
- `scripts/install.sh` remains available to existing copy-installer users.

## Development and verification

Run the portable installation and content regression tests plus structural checks from the repository root:

```bash
bash tests/install-roadmap-skill.sh
bash tests/validate-installation-docs.sh
bash tests/validate-roadmap-content.sh
bash -n roadmap/scripts/install.sh
git diff --check
```

In Codex development environments, also run the upstream skill structure validator:

```bash
python3 "${CODEX_HOME:-$HOME/.codex}/skills/.system/skill-creator/scripts/quick_validate.py" roadmap
```
