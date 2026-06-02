---
name: replot
description: Continuation of phase 2 of the agentic coding workflow. Reads element-referenced feedback from the user, applies it to the proposal document, renumbers, and iterates until approved. No code is written.
---

The user wants to revise an existing proposal using element-referenced feedback. Your job is to read their corrections (which reference `§ID` numbers), apply them, renumber the document, overwrite it, and iterate until the user approves. Do **not** write any production or test code.

## Locate the proposal

Locate the proposal document (`.html`) in `<git-repo-root>/doc/work-sessions/`. If not obvious, ask the user which proposal to revise.

## Collect feedback

Ask the user for their feedback if they haven't already provided it. The user references proposal elements by `#ID` number — for example:

```
#3: rewrite this paragraph to explain the caching strategy
#12–#14: replace these three steps with a single migration step
#7: remove this entirely
```

## Resolve feedback

For each referenced item:

- **If the intent is clear** — queue the change; no need to ask.
- **If the intent is ambiguous** — do not guess. Collect all ambiguous items and ask the user about them in a single message before proceeding. Do not ask one question per item.

## Apply changes and renumber

1. Apply every queued change to the proposal.
2. Renumber all block element `id` attributes (`<h1>`, `<h2>`, `<h3>`, `<p>`, `<li>`, `<pre>`, `<blockquote>`) sequentially from `1`, with no gaps.
3. Overwrite the proposal file in place.

## Iterate

Tell the user the file has been updated and ask them to review it. If they have more feedback, repeat the cycle — collect, resolve, apply, renumber, overwrite. Continue until the user explicitly approves the proposal or invokes `/engage`.

## Hard constraints

- Do **not** write any production or test code at any point.
- Do **not** start implementation even if the user says the proposal looks good in passing — wait for an unambiguous approval or an explicit `/engage` invocation.
