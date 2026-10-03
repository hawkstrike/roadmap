# Roadmap structure

## Contents

- [Adapt to an existing project](#adapt-to-an-existing-project)
- [Default structure for a new roadmap](#default-structure-for-a-new-roadmap)
- [Startable sessions and copyable prompts](#startable-sessions-and-copyable-prompts)
- [Phase placement for new sessions](#phase-placement-for-new-sessions)
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
5. Preserve existing headings, session identifiers, and change-history conventions whenever possible. Move the current-session and copyable-prompt sections to the top and normalize status markers to the colored emoji and text labels below when revising an existing roadmap.
6. Add missing execution or prompt-policy information within the existing structure instead of replacing it unnecessarily.

## Default structure for a new roadmap

Replace every brace-delimited slot with a real project value when using this structure.

```text
# {Project name} roadmap

> Document authority and update conditions

## Current and next sessions
## Copyable session prompts

## Goal and non-goals
## Current state and evidence
## Constraints, dependencies, and risks
## Shared execution rules
## Session prompt policy
## Priority and sequencing decisions
## Phases and work tracks
## Session plan
## Completed work archives
## Change history
```

Record which claims come from current code or verification, project instructions, documentation, Git history, or memory. Treat memory and historical handoffs as leads that require confirmation when the state can change.

## Startable sessions and copyable prompts

Keep `Current and next sessions` and `Copyable session prompts` as the first body sections after the title and brief authority note, before goals, background, phase details, archives, or change history. Apply this order on creation and every revision or closeout, including existing roadmaps. A parent index must expose startable child sessions and their prompts at the top too.

- List the current resumable session first, followed by approved pending sessions whose prerequisites are satisfied and which have no unresolved blocker. Give each entry its phase, session ID, colored status, short goal, and direct link to its prompt.
- Distinguish sessions that can start now from blocked or future work. Keep blocked work visible with its reason and unblocking action, but do not present it as startable. If no session is startable, state that explicitly; if all work is complete, link to the completed-work archive index without inventing a next session.
- Store one full self-contained prompt per startable session in a separate fenced `text` code block under a heading containing its ID and goal. Match the recorded prompt policy, replace all placeholders, and avoid list prefixes or commentary inside the block so the user can copy it directly.
- An incomplete resumable session gets a continuation prompt with the same ID. Replace stale prompts when state changes and remove completed-session launch prompts from the top. Do not advertise a blocked continuation as immediately executable.
- Keep full session scope and verification details below or in linked child roadmaps. The top sections are the maintained entry point, not a second historical log.

## Phase placement for new sessions

Before adding any session, inspect existing phases and their archive index for related goals, scope, dependencies, and shared boundaries. Read relevant archived outcomes when a completed phase may fit.

- Reuse a related phase when its goal covers the new work. Add a new unique session ID within that phase and preserve existing phase and session identifiers.
- A related completed phase can be reopened: keep its historical sessions in its existing archive, restore only the new active scope to the roadmap, and link both locations. Do not renumber or duplicate archived sessions.
- Create a new phase only when no existing phase fits the work's goal or scope. Record the placement reason briefly; distinguish work that belongs to a phase from work that merely depends on it.
- Preserve approved priorities and dependencies. Phase reuse does not authorize changing goals or sequencing; obtain approval when placement materially changes them.

## Active roadmap and archives

Keep the canonical roadmap authoritative for current state and usable as the navigation entry point for the whole plan. Keep active and pending work detailed there or in linked child roadmaps. At every closeout or revision, move completed work that now serves only as history into one Markdown archive file per phase; do not wait for the roadmap to become large or the entire phase to finish.

- Keep a compact `Completed work archives` index in the canonical roadmap. The index must link directly to every archive document and state each archive's phase, session range or IDs, colored status, and primary outcome. Keep only a concise outcome and evidence link for completed work still relevant to active decisions.
- Group archived sessions by a coherent phase or track within their owning phase's file. Prefer `roadmap-archives/{phase-id}.md` relative to the canonical roadmap, unless project conventions already name an archive location. Reuse that file when later sessions in the same phase finish; do not create a new archive per session or closeout.
- Archive completed sessions from a still-active phase once their details are history-only. Keep that phase's pending, in-progress, and blocked sessions in the active roadmap. A fully completed phase leaves only its compact archive index entry.
- Give every archive document a relative Markdown link back to the canonical roadmap and an internal session index. Preserve each archived session's ID, outcome, concise verification result, relevant decisions, and commit, pull request, or other durable evidence reference.
- Link directly to an archived session heading when active work depends on its result. Do not make later sessions search an entire archive for a prerequisite.
- Before removing details from the active roadmap, write or update the archive and confirm every moved session and its evidence is present. Check that archive index links, backlinks, and prerequisite anchors resolve from the documents containing them; update links affected by the move.
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
- Maintain the top session and prompt sections on every update, check existing phases before adding sessions, and move history-only completed details into the linked per-phase archives. Verify moved evidence and links before removing the original details.

Project instructions override these defaults when they are more specific. Separate design approval from implementation when a decision is broad, shared, security-sensitive, externally constrained, or difficult to reverse. Keep small, reversible work in one session when it can be implemented and verified independently.

## Session prompt policy

If no policy exists, ask the user to choose one format as a separate topic after scope and sequencing are approved.

- **Detailed**: Repeat the shared execution rules, completion decision, closeout order, and handoff requirements in every prompt. Prefer this when portability matters or project instructions are sparse.
- **Compact**: Keep durable rules in the canonical roadmap and include only session-specific scope, evidence, verification, closeout, and handoff instructions in each prompt. Prefer this when the roadmap is reliably maintained.

Ask with a concise choice that explains the tradeoff: Detailed prompts are longer and more portable; compact prompts are shorter and depend on the canonical roadmap's shared rules. Do not combine this choice with discovery or sequencing approval.

Record the selected format, state that it applies to completed-session and continuation prompts, and change it only after explicit user approval.

## Session fields

Include these fields for every session.

Show every session and phase status with both its colored emoji and text label in summaries, tables, and archives. Use only `🟡 Pending`, `🔵 In progress`, `🔴 Blocked`, or `🟢 Complete`; do not replace the label with an emoji alone. Translate the text label to the document language while keeping the same color mapping: yellow pending, blue in progress, red blocked, green complete. Phase completion requires all its sessions to be complete; show a blocking reason when a required session blocks the phase.

| Field | Content |
| --- | --- |
| Status | `🟡 Pending`, `🔵 In progress`, `🔴 Blocked`, or `🟢 Complete` |
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
