---
name: replot
description: Continuation of phase 2 of the agentic coding workflow. Reads annotations from an existing proposal document, resolves them with the user, and rewrites the proposal in place. No code is written.
---

The user wants to revise an existing proposal by processing inline annotations. Your job is to read the annotations, resolve any that are ambiguous, rewrite the proposal in place, and iterate until the user approves. Do **not** write any production or test code.

## Locate the proposal

Locate the proposal document in `<git-repo-root>/doc/work-sessions/`. If not obvious, ask the user which proposal to implement.

## Extract annotations

Read the proposal file in full. Collect every occurrence of the pattern `UPPERCASE_WORD:` — one or more uppercase letters followed by a colon — anywhere in the document.

Common examples:

```
PROBLEM: this won't work if the service is unavailable
QUESTION: should we use X or Y here?
CORRECTION: wrong file path — it lives under src/api/
TODO: add a rollback step
NOTE: double-check this with the team
```

## Resolve annotations

For each annotation found:

- **If the intent is clear** — queue the change; no need to ask.
- **If the intent is ambiguous** — do not guess. Collect all ambiguous annotations and ask the user about them in a single message before proceeding. Do not ask one question per annotation.

Once all annotations are understood, apply every change to the proposal. Revisions may touch any section: Background, Approach, Trade-offs & Risks, or the Implementation Checklist. Remove each resolved annotation from the document after incorporating it.

## Rewrite and iterate

After applying all changes, write the revised proposal back to the same file (overwrite in place).

Then ask the user to review the updated proposal and add new annotations if needed. Repeat this cycle — extract, resolve, rewrite — until the user explicitly approves the proposal. Approval can be a statement in chat or an invocation of `/engage`.

## Hard constraints

- Do **not** write any production or test code at any point.
- Do **not** start implementation even if the user says the proposal looks good in passing — wait for an unambiguous approval or an explicit `/engage` invocation.
