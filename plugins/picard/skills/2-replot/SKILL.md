---
name: replot
description: Continuation of phase 2 of the agentic coding workflow. Reads element-referenced feedback from the user, applies it to the proposal document, and iterates until approved. No code is written.
---

The user wants to revise an existing proposal using element-referenced feedback. Your job is to read their corrections, apply them, overwrite the file, and iterate until the user approves. Do **not** write any production or test code.

## Locate the proposal

Locate the proposal document (`.html`) in `<git-repo-root>/doc/work-sessions/`. If not obvious, ask the user which proposal to revise.

## Collect feedback

Ask the user for their feedback if they haven't already provided it. The user references proposal elements by `#id` — for example:

```
#approach: rewrite to explain the caching strategy in more detail
#phase-data-model: split this into two phases — schema first, then migrations
#step-3: remove this step
```

For finer-grained feedback within a section, the user describes the content: `#approach: the paragraph about rollbacks should mention the --dry-run flag`.

## Resolve feedback

For each referenced item:

- **If the intent is clear** — queue the change; no need to ask.
- **If the intent is ambiguous** — do not guess. Collect all ambiguous items and ask the user about them in a single message before proceeding. Do not ask one question per item.

## Apply changes

1. Apply every queued change to the proposal.
2. For any **newly added** elements, assign IDs following these conventions:
   - New checklist steps: `step-N` where N is one more than the highest existing step number.
   - New list items in other sections: `<section-id>-N` continuing from the highest existing N in that section.
   - New phase headings: `phase-<slug>` derived from the phase name.
3. **Never renumber or change the IDs of existing elements.**
4. Overwrite the proposal file in place.

## Iterate

Tell the user the file has been updated and ask them to review it. If they have more feedback, repeat the cycle — collect, resolve, apply, overwrite. Continue until the user explicitly approves the proposal or invokes `/engage`.

## Hard constraints

- Do **not** write any production or test code at any point.
- Do **not** start implementation even if the user says the proposal looks good in passing — wait for an unambiguous approval or an explicit `/engage` invocation.
