---
name: plot
description: Phase 2 of the agentic coding workflow. Collaborates with the user on a written proposal (approach, trade-offs, implementation checklist) before any code is written.
---

The user wants to plan a coding task. Your job is to produce a proposal document and iterate on it with the user until they approve it. Do **not** write any production or test code until the user explicitly says to proceed.

## Output document

Determine the git repo root (use `git rev-parse --show-toplevel`), then create the proposal at:

```
<git-repo-root>/doc/work-sessions/<yyyy>/<yyyy-mm-dd_hh-mm-ss>-proposal-<terse-description>.md
```

- `<yyyy>` — the current four-digit year
- `<yyyy-mm-dd_hh-mm-ss>` — run `date '+%Y-%m-%d_%H-%M-%S'` to get the current date and time
- `<terse-description>` — a short, hyphen-separated description matching the topic (e.g. `user-auth-flow`)

If a research document for this topic exists in the same `doc/work-sessions/<yyyy>/` directory, read it before writing the proposal.

## Document structure

```
# Proposal: <Topic>

## Background
Why this work is needed; relevant context.

## Approach
Detailed description of the chosen approach. Include:
- Key design decisions and why they were made
- Alternatives considered and why they were rejected
- Relevant code snippets, interfaces, or pseudocode
- File paths that will be created or modified

## Trade-offs & Risks
Honest assessment of downsides, open questions, or unknowns.

## Implementation Checklist
(See requirements below)
```

## Implementation Checklist requirements

The checklist must be detailed and actionable. Each item should be a concrete, verifiable step. **Organize steps using a red/green TDD cycle wherever applicable:**

1. Write or modify a test that captures the desired behavior
2. Run the test — confirm it fails for the **right reason** (a compile error is acceptable if the production code doesn't exist yet; a runtime assertion failure is expected once the code compiles)
3. Write or modify production code to make the test pass
4. Run the tests again — confirm they pass

Group related steps into named phases (e.g. `### Phase 1: Data model`). Use GitHub-flavored markdown task list syntax:

```markdown
## Implementation Checklist

### Phase 1: <name>
- [ ] Write test for <behavior> — expect failure: <reason>
- [ ] Run tests, confirm failure
- [ ] Implement <behavior>
- [ ] Run tests, confirm passing
...
```

## Iteration (annotation cycle)

After writing the document, ask the user to review it and add inline notes or corrections.

**In-session feedback** — if the user types corrections directly in chat, update the proposal document to reflect their notes, do **not** start implementing, and repeat until they explicitly approve.

**Out-of-session feedback** — the preferred path is for the user to edit the proposal file directly, marking each note with an `UPPERCASE_WORD:` annotation (e.g. `PROBLEM:`, `CORRECTION:`, `QUESTION:`, `TODO:`). When they return, they invoke `/replot`, which reads all annotations, resolves any ambiguous ones through a clarification loop, rewrites the proposal in place, and returns to a wait-for-approval state.
