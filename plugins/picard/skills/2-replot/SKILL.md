---
name: replot
description: Continuation of phase 2 of the agentic coding workflow. Reads element-referenced feedback from the user, applies it to the proposal document, and iterates until approved. No code is written.
---

The user wants to revise an existing proposal based on some feedback. Your job is to read their corrections, apply them, overwrite the file, and iterate until the user approves. Do **not** write any production or test code.

## Locate the proposal

Locate the proposal document (`.html`) in `<git-repo-root>/doc/work-sessions/`. If not obvious, ask the user which proposal to revise.

## Collect feedback

Search for HTML comments in the document. These will have user feedback. Or perhaps the user will have provided feedback in the prompt that invoked this skill.

## Resolve feedback

For each referenced item of feedback:

- **If the intent is clear** — queue the change; no need to ask.
- **If the intent is ambiguous** — do not guess. Collect all ambiguous items and ask the user about them in a single message before proceeding. Do not ask one question per item.

## Apply changes

Apply every queued change to the proposal, removing the feedback comments as you go.

## Iterate

Tell the user the file has been updated. Emit the full path on its own line, then emit a `file://` URL on the next line. Ask them to review it. If they have more feedback, repeat the cycle — collect, resolve, apply, overwrite. Continue until the user explicitly approves the proposal or invokes `/engage`.

## Hard constraints

- Do **not** write any production or test code at any point, except as snippets in this document.
- Do **not** start implementation even if the user says the proposal looks good in passing — wait for an unambiguous approval or an explicit `/engage` invocation.
