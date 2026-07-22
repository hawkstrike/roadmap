# Session closeout and self-contained prompts

## Contents

- [Prompt independence](#prompt-independence)
- [Completion decision](#completion-decision)
- [Closeout order](#closeout-order)
- [Required prompt content](#required-prompt-content)
- [Detailed completed-session prompt](#detailed-completed-session-prompt)
- [Detailed continuation prompt](#detailed-continuation-prompt)
- [Compact completed-session prompt](#compact-completed-session-prompt)
- [Compact continuation prompt](#compact-continuation-prompt)
- [Parallel next sessions](#parallel-next-sessions)

## Prompt independence

Generate prompts that can start in a new conversation without previous conversation history or another invocation of this skill. Every prompt must point to the canonical roadmap, carry the current session's exact scope and evidence requirements, and require another self-contained prompt at closeout.

Replace every brace-delimited slot with a real value. Never emit unresolved placeholders.

## Completion decision

Compare the session's completion criteria, project instructions, planned verification, and actual Git state. Mark the session complete only when all required evidence exists.

Keep the current session in progress or blocked when any of these remain.

- A required test is failing.
- A required type, build, live, or visual check has not run.
- Scope required by completion criteria is not implemented.
- Completion requires a user decision or external authorization.
- The session's changes cannot be distinguished safely from user-owned changes.

## Closeout order

1. What was implemented or changed
2. Verification performed and its results
3. Commit information or current Git state
4. Remaining risks and anything not verified
5. Canonical roadmap status, completion evidence, current and next sessions, and change history
6. A copyable self-contained next-session or continuation prompt

Update the roadmap before generating the prompt so the prompt references current state. Preserve both the status emoji and text label defined by the roadmap structure whenever a session status changes. Generate the next self-contained prompt in the format recorded by the roadmap. A completed session advances to the approved next session; an incomplete session keeps the same ID and produces a continuation prompt.

## Required prompt content

Every format must include the working path; applicable instruction discovery; exact canonical roadmap and relevant guide paths; previous result; current session ID and goal; included and excluded scope; prerequisites and shared boundaries; completion criteria; planned verification; preservation of user-owned changes; completion decision; closeout order; roadmap update responsibility; and a requirement to generate the following self-contained prompt.

## Detailed completed-session prompt

```text
Work in {working path}.

Read every applicable agent instruction file recognized by the current runtime from the working path through the repository root, including AGENTS.md and CLAUDE.md when present. Use available user instructions and project memory as context, but verify changeable claims against current files and Git. Read {canonical roadmap} and {relevant guides}.

The previous session completed {completed session and outcome}. Work only on {next session ID and title}.

Goal: {goal}
Included scope: {included scope}
Excluded scope: {excluded scope}
Prerequisites: {prerequisites}
Shared boundaries and ownership: {shared boundaries and roadmap update responsibility}
Completion criteria: {completion criteria}
Required verification: {planned verification}

Before editing, read the relevant implementation, tests, configuration, and similar existing patterns. State material assumptions and tradeoffs. Make the smallest change that satisfies this session; avoid unrelated cleanup, speculative abstraction, and unrelated reformatting. Reproduce bugs before fixing them when practical, test behavior, investigate root causes, and add no dependency without a demonstrated need. Preserve user-owned changes and do not claim completion without fresh verification evidence.

At closeout, update the canonical roadmap's completion evidence, current and next sessions, and change history. If every completion criterion passes, mark this session complete and advance to the approved next session. Otherwise keep this session open. In the final response, report implementation, verification results, commit or Git state, remaining risks, and roadmap changes before the prompt.

Generate the next self-contained prompt after updating the roadmap. Use the roadmap's selected prompt format and carry forward the same scope, verification, completion, closeout, and prompt-generation rules. Do not require previous conversation history or another skill invocation.
```

## Detailed continuation prompt

```text
Work in {working path}.

Read every applicable agent instruction file recognized by the current runtime from the working path through the repository root, including AGENTS.md and CLAUDE.md when present. Use available user instructions and project memory as context, but verify changeable claims against current files and Git. Read {canonical roadmap} and {relevant guides}.

Continue {current session ID and title}. The session remains incomplete because {failure or blocking evidence}.

Goal: {goal}
Completed scope: {finished scope}
Remaining scope: {remaining scope}
Excluded scope: {excluded scope}
Prerequisites: {prerequisites}
Resume from: {next inspection or repair point}
Shared boundaries and ownership: {shared boundaries and roadmap update responsibility}
Remaining completion criteria: {remaining completion criteria}
Required verification: {remaining planned verification}
Current Git and user-owned changes: {Git state and preservation requirements}

Before editing, read the relevant implementation, tests, configuration, and similar existing patterns. State material assumptions and tradeoffs. Make the smallest change that completes this session; avoid unrelated cleanup, speculative abstraction, and unrelated reformatting. Reproduce failures, investigate root causes, test behavior, and add no dependency without a demonstrated need. Preserve user-owned changes and do not mark this session complete without fresh evidence for every remaining check.

At closeout, update the canonical roadmap's completion evidence, current and next sessions, and change history. Advance only if every remaining completion criterion passes; otherwise keep the same session ID. In the final response, report implementation, verification results, commit or Git state, remaining risks, and roadmap changes before the prompt.

Generate the next self-contained prompt after updating the roadmap. Use the roadmap's selected prompt format and carry forward the same scope, verification, completion, closeout, and prompt-generation rules. Do not require previous conversation history or another skill invocation.
```

## Compact completed-session prompt

```text
Work in {working path}. Read every applicable agent instruction file recognized by the current runtime, including AGENTS.md and CLAUDE.md when present, then read the shared execution rules, prompt policy, and current state in {canonical roadmap}. Verify changeable memory or handoff claims against current files and Git. Also inspect {relevant guides}.

The previous session completed {completed session and outcome}. Work only on {next session ID and title}.

Goal: {goal}
Included: {included scope}
Excluded: {excluded scope}
Prerequisites and shared ownership: {prerequisites, shared boundaries, and roadmap update responsibility}
Completion requires: {completion criteria}
Verify with: {planned verification}

Preserve user-owned changes. Mark the session complete only with fresh evidence for every criterion; otherwise keep it open. Update the roadmap, then report implementation, verification, Git state, risks, and roadmap changes before generating the next self-contained prompt in the recorded format with the same execution, completion, closeout, and prompt-generation rules.
```

## Compact continuation prompt

```text
Work in {working path}. Read every applicable agent instruction file recognized by the current runtime, including AGENTS.md and CLAUDE.md when present, then read the shared execution rules, prompt policy, and current state in {canonical roadmap}. Verify changeable memory or handoff claims against current files and Git. Also inspect {relevant guides}.

Continue {current session ID and title}. It remains incomplete because {failure or blocking evidence}.

Goal: {goal}
Completed: {finished scope}
Remaining: {remaining scope and next inspection or repair point}
Excluded: {excluded scope}
Prerequisites: {prerequisites}
Shared ownership: {shared boundaries and roadmap update responsibility}
Completion requires: {remaining completion criteria}
Verify with: {remaining planned verification}
Git and user-owned changes: {Git state and preservation requirements}

Preserve the same session ID until every criterion has fresh evidence. Update the roadmap, then report implementation, verification, Git state, risks, and roadmap changes before generating the next self-contained prompt in the recorded format with the same execution, completion, closeout, and prompt-generation rules.
```

## Parallel next sessions

When two or more tracks can run safely in parallel, summarize shared prerequisite state once and write a separate complete prompt block for each track. State file, data, external-resource, and roadmap-update ownership plus the convergence session in every block. Do not let parallel prompts claim the same shared roadmap section.
