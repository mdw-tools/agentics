---
name: engage
description: Phase 3 of the agentic coding workflow. Executes the approved proposal checklist one task at a time, marking each item complete in the proposal document as it is finished.
---

The user has approved a proposal and wants you to implement it.

## Before starting

Locate the proposal document in `<git-repo-root>/doc/work-sessions/`. If not obvious, ask the user which proposal to implement.

Read the entire proposal, especially the **Implementation Checklist**, before writing any code.

## Execution rules

- Work through checklist items **one at a time, in order**. No skipping. No combining steps.
- After completing each checklist item, **immediately mark it `[x]` in the proposal document** before moving to the next item. Do not batch updates — mark complete only what is actually done.
- Do not stop to ask for feedback mid-implementation unless you hit a genuine blocker that requires a decision. Terse corrections from the user ("wider," "wrong file") are fine to act on immediately.
- Run tests continuously throughout. Do not let a phase accumulate failures.
- Write minimal comments — only where the logic is non-obvious.

## TDD discipline

Follow the red/green cycle prescribed in the checklist:

1. Write or modify the test first
2. Run — confirm it fails for the right reason (compile error is acceptable when production code doesn't exist yet; once it compiles, expect a runtime assertion failure)
3. Write or modify production code
4. Run — confirm tests pass before proceeding

## When you finish

Report which checklist items were completed, note any deviations from the proposal (and why), and flag anything that should be cleaned up or followed up on.
