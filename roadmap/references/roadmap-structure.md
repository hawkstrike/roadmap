# Roadmap structure

## Contents

- [Adapt to an existing project](#adapt-to-an-existing-project)
- [Default structure for a new roadmap](#default-structure-for-a-new-roadmap)
- [Active roadmap and archives](#active-roadmap-and-archives)
- [Discovery and sequencing approval](#discovery-and-sequencing-approval)
- [Shared execution rules](#shared-execution-rules)
- [Session prompt policy](#session-prompt-policy)
- [Session fields](#session-fields)
- [Session sizing](#session-sizing)
- [Parallel-track decision](#parallel-track-decision)

## Adapt to an existing project

1. Prefer the canonical roadmap named by project instructions.
2. When a parent index and child roadmaps exist, keep current position and direct links to every child and archive document in the parent, and keep detailed sessions in the children.
3. When the canonical file cannot be identified, ask one question for the exact path.
4. When no roadmap exists, propose `docs/roadmap.md` and create it only after approval.
5. Preserve existing headings, status markers, session identifiers, and change-history conventions whenever possible.
6. Add missing execution or prompt-policy information within the existing structure instead of replacing it unnecessarily.

## Default structure for a new roadmap

Replace every brace-delimited slot with a real project value when using this structure.

```text
# {Project name} roadmap

> Document authority and update conditions

## Goal and non-goals
## Current state and evidence
## Constraints, dependencies, and risks
## Shared execution rules
## Session prompt policy
## Priority and sequencing decisions
## Phases and work tracks
## Session plan
## Current and next sessions
## Completed work archives
## Change history
```

Record which claims come from current code or verification, project instructions, documentation, Git history, or memory. Treat memory and historical handoffs as leads that require confirmation when the state can change.

## Active roadmap and archives

Keep the canonical roadmap authoritative for current state and usable as the navigation entry point for the whole plan. Keep active and pending work detailed there or in linked child roadmaps. Move older completed-session details into archive documents so routine session history does not dominate the active plan.

- Keep a compact `Completed work archives` index in the canonical roadmap. The index must link directly to every archive document and state each archive's phase or track, session range, and primary outcome.
- Group archived sessions by a coherent phase or track. Do not create one file per session unless a session needs a standalone incident report, decision record, or similarly durable artifact.
- Give every archive document a link back to the canonical roadmap and an internal session index. Preserve each archived session's outcome, concise verification result, and commit, pull request, or other durable evidence reference.
- Link directly to an archived session heading when active work depends on its result. Do not make later sessions search an entire archive for a prerequisite.
- Keep exhaustive command output, file lists, and implementation detail in Git, continuous-integration artifacts, or dedicated reports. Record only the result and durable reference in the roadmap archive.
- Archive only completed work. Keep in-progress, blocked, and immediately upcoming sessions in the active roadmap until their state changes.

Change history records material changes to the plan, such as scope, priority, sequencing, dependencies, or architecture decisions. Routine session completion belongs in completion evidence and, when moved, the archive; do not repeat every closeout in change history.

## Discovery and sequencing approval

Before drafting a full roadmap, resolve only missing information that can materially change it. Consider the goal and success criteria, primary users and flows, required and excluded scope, constraints, external dependencies, and release or verification expectations. Ask one topic per message, starting with the highest-impact unresolved topic.

After scope is clear, propose an order using these considerations.

1. Prerequisites that unblock other work
2. Shared schemas, interfaces, or resources needed by multiple tracks
3. High uncertainty, failure cost, or external lead time
4. Independently testable user value
5. Safe parallel work
6. Integration, regression verification, and documentation consistency

Explain material alternatives and obtain user approval before locking the sequence. Do not invent alternatives when project evidence leaves only one reasonable order; present that order and ask for approval.

## Shared execution rules

Write durable rules in the canonical roadmap so later prompts do not require this skill again. They must continue to use relevant skills available in the current environment when those skills apply.

- Read relevant implementation, tests, configuration, and similar existing patterns before changing files.
- State assumptions and material tradeoffs before making hard-to-reverse choices.
- Confirm the current session goal and completion criteria before implementation.
- Make the smallest change that satisfies the current session; avoid adjacent cleanup, speculative abstraction, and unrelated reformatting.
- Reproduce bugs before fixing them when practical, and test behavior rather than implementation details.
- Run the project's required focused and regression verification. Do not invent commands that cannot be confirmed from project evidence.
- Investigate root causes instead of adding unverified workarounds.
- Add dependencies only when current project capabilities cannot meet the requirement, and record the reason.
- Preserve user-owned changes and distinguish them from session changes.
- Do not claim completion without fresh evidence for every required check.

Project instructions override these defaults when they are more specific. Separate design approval from implementation when a decision is broad, shared, security-sensitive, externally constrained, or difficult to reverse. Keep small, reversible work in one session when it can be implemented and verified independently.

## Session prompt policy

If no policy exists, ask the user to choose one format as a separate topic after scope and sequencing are approved.

- **Detailed**: Repeat the shared execution rules, completion decision, closeout order, and handoff requirements in every prompt. Prefer this when portability matters or project instructions are sparse.
- **Compact**: Keep durable rules in the canonical roadmap and include only session-specific scope, evidence, verification, closeout, and handoff instructions in each prompt. Prefer this when the roadmap is reliably maintained.

Ask with a concise choice that explains the tradeoff: Detailed prompts are longer and more portable; compact prompts are shorter and depend on the canonical roadmap's shared rules. Do not combine this choice with discovery or sequencing approval.

Record the selected format, state that it applies to completed-session and continuation prompts, and change it only after explicit user approval.

## Session fields

Include these fields for every session.

Show every session status with both its emoji and text label. Use only `⏳ Pending`, `🔄 In progress`, `❌ Blocked`, or `✅ Complete`; do not replace the label with an emoji alone.

| Field | Content |
| --- | --- |
| Status | `⏳ Pending`, `🔄 In progress`, `❌ Blocked`, or `✅ Complete` |
| ID | A unique identifier that follows project conventions |
| Track | A sequential or parallel workstream |
| Goal | One user-facing or technical outcome |
| Included and excluded scope | Work this session will and will not perform |
| Prerequisites | Artifacts that must exist before the session starts |
| Shared boundaries | Files, data, roadmap sections, or external resources another track may also change |
| Completion criteria | Observable evidence required to finish |
| Planned verification | Exact test, type, build, live, or visual checks to perform |
| Completion evidence | Results, artifacts, and commit or Git state recorded after the checks run |

## Session sizing

- Does the session produce one primary outcome?
- Can implementation, verification, related documentation, and required commit work close in the session?
- Can a new conversation start from the roadmap and generated prompt without previous conversation history?
- When design approval is required, are design and implementation separated?
- Are setup, implementation, and live-verification boundaries explicit for external dependencies?

Split the session further when any answer is no.

## Parallel-track decision

Place work in the same parallel window only when every condition is true.

- Neither track requires the other's unfinished output.
- Owned files, data, and roadmap update boundaries are separate.
- Concurrent changes to shared external resources cannot conflict.
- Each track can be verified and committed independently.

When tracks share a core file, data structure, or roadmap section, assign one owner or move the shared change into a prerequisite session. A track may update its owned child roadmap, but one owner or the convergence session must update shared parent state. Add an integration session for full regression verification and documentation consistency where parallel tracks converge.

When multiple next tracks are safe to run concurrently, provide one complete prompt per track and state that they may run in parallel. Include ownership, shared boundaries, roadmap update responsibility, and the convergence session in every prompt. Follow project instructions for branches, worktrees, and agents; do not create execution environments merely because the roadmap shows parallel work.
