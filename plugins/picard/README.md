# picard

A set of three Claude Code skills implementing a deliberate, phase-based agentic coding workflow. The approach is inspired by [Boris Tane's article "How I Use Claude Code"](https://boristane.com/blog/how-i-use-claude-code/), which advocates for keeping humans in control of key decisions while delegating mechanical execution to the agent.

## Core idea

The central discipline is simple: **never let the agent write code until a written plan has been reviewed and approved.** The first two phases produce an artifact that the human reviews before the next phase begins.

## The phases

### `/scan` — Research

The agent researches the topic deeply, exploring relevant code, dependencies, constraints, and edge cases. It produces a `research` document in the project's work-sessions directory. No code is written. No solutions are proposed. The human reviews the findings before moving on.

### `/plot` — Proposal

The agent drafts a proposal document covering the approach, key design decisions, trade-offs, and risks. The proposal concludes with a detailed **Implementation Checklist** organized around a red/green TDD cycle.

The proposal also includes a **Your Turn** section designating one checklist step — the most interesting production-code contribution — for the human to implement. The section provides enough context (function signatures, relevant types, file paths, what the passing test asserts) to succeed without additional research. The Your Turn step can be omitted if the user prefers fully automated execution.

The human reviews the proposal and provides feedback in chat, referencing sections and steps by their `#id` (e.g. `#approach: add a note about rollback`, `#step-3: remove this`). The agent applies the changes and overwrites the file. This cycle repeats until the proposal is approved. No code is written.

### `/replot` — Revise proposal

When the human has additional feedback after the initial review session — or returns to a proposal in a new session — `/replot` picks up their `#id`-referenced corrections, resolves any that are ambiguous through a clarification loop, and rewrites the proposal in place. The cycle repeats until the human approves. No code is written.

### `/engage` — Implementation

With the proposal approved, the agent executes the checklist one item at a time, in order, marking each item complete in the proposal document as it finishes. No skipping, no combining steps. The TDD cycle prescribed in the checklist is followed faithfully throughout.

When the agent reaches the **Your Turn** step, it stops and hands control to the human, pointing them to the `#your-turn` section for guidance. It resumes — and runs tests to verify — only after the human reports completion.

## Naming scheme

The skills are named after *Star Trek: The Next Generation* references. **Engage** is Captain Picard's signature command — the word he uses to set the ship in motion — making it a fitting name for the implementation phase. **Scan** and **plot** follow naturally as the preparatory actions a crew takes before a captain can give that order: scanning the area, plotting a course.

The plugin itself is named **picard** in honor of the same captain.

## Work session documents

Scan and proposal documents are written as HTML files to:

```
<git-repo-root>/doc/work-sessions/<yyyy>/<yyyy-mm-dd_hh-mm-ss>-<phase>-<description>.html
```

Every heading and list item carries a semantic `id` attribute (e.g. `id="approach"`, `id="step-3"`) rendered as a `#id` label in the browser, matching the reference syntax used in chat. IDs are stable — they are never renumbered after assignment.

Keeping these documents in the repository creates a durable record of the reasoning behind each piece of work.

## Example workflow

The general workflow looks something like this:

User: `/scan go analyze this code over here to learn about how such and such is done, and record your findings`

Claude: *creates a research document at `./doc/work-sessions/...`*

User: `/plot implement option B from the research you just did`

Claude: *creates a proposal document at `./doc/work-sessions/...` with approach, trade-offs, a Your Turn section, and a TDD checklist*

User: `#approach: add a note about the retry budget` and `#step-5: split this into two steps`

Claude: *applies the feedback, overwrites the proposal*

(rinse & repeat until satisfied)

User: `/engage`

Claude: *executes each checklist item one by one — pausing at the Your Turn step for the user to implement — marking each complete as it goes*
