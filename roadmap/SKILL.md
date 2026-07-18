---
name: roadmap
description: Create or materially revise project roadmaps, inspect existing roadmaps without editing, split large work into independently verifiable chat sessions, establish safe parallel workstreams, and bootstrap self-contained prompts that carry later sessions without invoking the skill again. Use when a user requests any of these project-planning workflows.
---

# Roadmap

## Core principle

Inspect current evidence first. For creation or material revision, resolve only material uncertainty and bootstrap a canonical roadmap plus self-contained session prompts. Each prompt must preserve scope, verification, closeout, and handoff rules without invoking this skill again.

## Workflow

1. Identify the current request and working path.
2. Read every applicable agent instruction file recognized by the current runtime from the working path through the repository root, including `AGENTS.md` and `CLAUDE.md` when present. Use available user-level instructions and project memories to reduce questions, but recheck time-sensitive claims against current files and verification evidence.
3. Inspect Git status and recent commits, root `README.md`, `docs/README.md`, documents named by instructions, existing roadmaps, and the implementation, tests, manifests, and verification configuration relevant to the goal.
4. When documentation and implementation disagree, prefer current files and verification evidence, then record the discrepancy.
5. When the request is inspection-only, evaluate the roadmap against current evidence, report prioritized findings, and stop. Do not modify the roadmap, seek sequencing or prompt-policy approval, or generate a session prompt unless the user asks for a revision.
6. For creation or material revision, resolve discovery gaps before drafting the full roadmap. Consider the goal and success criteria, primary users and flows, required and excluded scope, constraints, external dependencies, and release or verification expectations. Ask only the single highest-impact unresolved question, one topic per message, and do not ask for facts available in the inspected evidence.
7. Read and follow [references/roadmap-structure.md](references/roadmap-structure.md) when creating or revising the roadmap.
8. After scope is clear, propose session sequencing based on dependencies, shared boundaries, uncertainty, user value, and integration needs. Explain material tradeoffs and obtain user approval before locking goals or priorities.
9. If the canonical roadmap does not already record a prompt policy, ask the user to choose Detailed or compact prompts as one separate topic. Record the choice and keep it until the user explicitly changes it.
10. Create or revise the canonical roadmap, lock the first session, and read [references/session-closeout.md](references/session-closeout.md) to generate the first self-contained prompt. Do not require later prompts to invoke this skill.

## Instruction precedence

Follow the user's current request first. Then apply instructions nearest the affected files, repository-root instructions, project documentation, and this skill's defaults in that order.

Apply same-scope instruction files together. If they cannot all be satisfied and the result would differ, explain one conflict and ask the user instead of choosing silently.

Treat memory and historical handoffs as discovery leads rather than proof of current state. Never store or repeat sensitive values in a roadmap or session prompt.

## Stop conditions

- Ask for the exact file when the canonical roadmap cannot be identified.
- For a new project with material unanswered questions, stop after the single discovery question; do not draft a speculative full roadmap.
- Do not make a choice that materially changes goals, priorities, or sequencing without user approval.
- Do not mark a session complete while required tests fail, required live verification is missing, or an external dependency blocks completion.
- Do not revert or clean up user-owned changes.
- When completion evidence is insufficient, keep the current session open and generate a continuation prompt for that same session.

## Common failures

| Failure | Correction |
| --- | --- |
| Asking before reading project evidence | Find answers in current instructions, files, tests, Git, and available memory first |
| Drafting from unconfirmed assumptions | Ask the single highest-impact discovery question and wait |
| Letting the model silently choose priorities | Propose the order, explain tradeoffs, and obtain approval |
| Listing parallel candidates without structure | Record ownership, shared changes, and convergence points |
| Depending on this skill in every session | Put durable rules in the roadmap and generate self-contained prompts |
| Completing a failed session under schedule pressure | Preserve its status and generate a continuation prompt for the same session |
