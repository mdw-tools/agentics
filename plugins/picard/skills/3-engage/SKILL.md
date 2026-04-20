---
name: engage
description: Phase 3 of the agentic coding workflow. Executes the approved proposal checklist one task at a time, marking each item complete in the proposal document as it is finished.
---

The user has approved a proposal and wants you to implement it.

## Before starting

Locate the proposal document in `<git-repo-root>/doc/work-sessions/`. If not obvious, ask the user which proposal to implement.

Read the entire proposal, especially the **Implementation Checklist**, before writing any code.

## Execution rules

- Work through checklist items **one at a time, in order**. Do not skip to later checklist items. Do not combine checklist items.
- For each checklist item, follow this exact sequence:
  1. Do the work (write/edit code, run tests, etc.)
  2. **Immediately call the Edit tool to mark that item `[x]` in the proposal document.** This Edit call must happen in the same response as the work, before any tool calls for the next item. Do not batch mark-offs.
- Do not stop to ask for feedback mid-implementation unless you hit a genuine blocker that requires a decision. Terse corrections from the user ("wider," "wrong file") are fine to act on immediately.
- Run tests continuously throughout. Do not let a phase accumulate failures.
- Write minimal comments — only where the logic is non-obvious.

## When the user takes over a step

If the user denies a tool call or says they'll perform a step themselves
(e.g., "I'll run the tests and paste the output"), treat that as a hard stop:

- Do not proceed to subsequent checklist items, even ones that look independent.
- Do not run other commands or edit other files in the meantime.
- Do not mark the deferred item `[x]` until the user provides the result.
- Reply briefly acknowledging you're waiting, then stop.

The reason: their result may invalidate later steps. A failed test means the
production code needs revision before the next phase makes sense; continuing
past their checkpoint risks work that has to be undone.

A user taking over a step is the only acknowledged break in the "one item at
a time, in order" cadence. Resume only after they hand back control with the
output.

## TDD discipline

Follow the red/green cycle prescribed in the checklist:

1. Write or modify the test first
2. Run — confirm it fails for the right reason (compile error is acceptable when production code doesn't exist yet; once it compiles, expect a runtime assertion failure)
3. Write or modify production code
4. Run — confirm tests pass before proceeding

## When you finish

Report which checklist items were completed, note any deviations from the proposal (and why), and flag anything that should be cleaned up or followed up on.
