# picard

A set of three Claude Code skills implementing a deliberate, phase-based agentic coding workflow. The approach is inspired by [Boris Tane's article "How I Use Claude Code"](https://boristane.com/blog/how-i-use-claude-code/), which advocates for keeping humans in control of key decisions while delegating mechanical execution to the agent.

## Core idea

The central discipline is simple: **never let the agent write code until a written plan has been reviewed and approved.** The first two phases produce an artifact that the human reviews before the next phase begins.

## The phases

### `/scan` — Research

The agent researches the topic deeply, exploring relevant code, dependencies, constraints, and edge cases. It produces a `scan` document in the project's work-sessions directory. No code is written. No solutions are proposed. The human reviews the findings before moving on.

### `/plot` — Proposal

The agent drafts a proposal document covering the approach, key design decisions, trade-offs, and risks. The proposal concludes with a detailed **Implementation Checklist** organized around a red/green TDD cycle. The human then enters an annotation cycle — adding inline notes to the document, asking the agent to revise it — until the proposal is approved. Still no code is written.

### `/replot` — Revise proposal from annotations

When the human has edited the proposal file directly — marking feedback with `UPPERCASE_WORD:` annotations (e.g. `PROBLEM:`, `CORRECTION:`, `QUESTION:`) — invoking `/replot` picks up those annotations, resolves any that are ambiguous through a clarification loop, and rewrites the proposal in place. The cycle repeats until the human approves. No code is written.

### `/engage` — Implementation

With the proposal approved, the agent executes the checklist one item at a time, in order, marking each item complete in the proposal document as it finishes. No skipping, no combining steps. The TDD cycle prescribed in the checklist is followed faithfully throughout.

## Naming scheme

The skills are named after *Star Trek: The Next Generation* references. **Engage** is Captain Picard's signature command — the word he uses to set the ship in motion — making it a fitting name for the implementation phase. **Scan** and **plot** follow naturally as the preparatory actions a crew takes before a captain can give that order: scanning the area, plotting a course.

The plugin itself is named **picard** in honor of the same captain.

## Work session documents

Scan and proposal documents are written to:

```
<git-repo-root>/doc/work-sessions/<yyyy>/<yyyy-mm-dd_hh-mm-ss>-<phase>-<description>.md
```

Keeping these documents in the repository creates a durable record of the reasoning behind each piece of work.

## Example workflow:

The general workflow looks something like this:

User: `/scan go analyze this code over here to learn about how such and such is done, and record your findings--ranked by how complicated they would be to implement...`

Claude: _creates a research document at ./doc/work-sessions/..._

User: `/plot implement option B from the research you just did`

Claude: _creates a proposal document with code snippets and checklists at `./doc/work-sessions/...`_

User: _annotates the proposal document with lines that start with ALLCAPS words followed by a colon (i.e. `CORRECTION: no, do it this way`)_

User: `/replot`

Claude: _rewrites the proposal according to the annotations added previously_

(rinse & repeat adding annotations to document and running `replot` until satisfied with the proposal)

User: `/engage`

Claude: _very obediently performs each task in the proposal document's checklists, one by one, no skipping, no combining, etc._