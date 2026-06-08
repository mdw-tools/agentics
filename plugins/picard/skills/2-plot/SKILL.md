---
name: plot
description: Phase 2 of the agentic coding workflow. Collaborates with the user on a written proposal (approach, trade-offs, implementation checklist) before any code is written.
---

The user wants to plan a coding task. Your job is to produce a proposal document and iterate on it with the user until they approve it. Do **not** write any production or test code until the user explicitly says to proceed.

## Output document

Determine the git repo root (use `git rev-parse --show-toplevel`), then create the proposal at:

```
<git-repo-root>/doc/work-sessions/<yyyy>/<yyyy-mm-dd_hh-mm-ss>-proposal-<terse-description>.html
```

- `<yyyy>` — the current four-digit year
- `<yyyy-mm-dd_hh-mm-ss>` — run `date '+%Y-%m-%d_%H-%M-%S'` to get the current date and time
- `<terse-description>` — a short, hyphen-separated description matching the topic (e.g. `user-auth-flow`)

If a research document for this topic exists in the same `doc/work-sessions/<yyyy>/` directory, read it before writing the proposal.

## Suggested Document Contents

- Background (Why this work is needed; relevant context.)
- Approach (Detailed description of the chosen approach.)
- Trade-offs (Honest assessment of downsides, open questions, or unknowns.)
- Implementation checklists

Present the information in whatever way or style feels appropriate. Use rich content like images, diagrams, code snippets, appropriate fonts, etc.

## Implementation Checklist requirements

The checklist must be detailed and actionable. Each item should be a concrete, verifiable step. **Organize steps using a red/green TDD cycle wherever applicable:**

1. Write or modify a test that captures the desired behavior
2. Run the test — confirm it fails for the **right reason** (a compile error is acceptable if the production code doesn't exist yet; a runtime assertion failure is expected once the code compiles)
3. Write or modify production code to make the test pass
4. Run the tests again — confirm they pass

Group related steps into named phases.

## Your Turn section

Most proposals should designate a portion of the work for the human user to implement. Choose a portion of that work that is:

- **Interesting** — the core logic, a non-trivial algorithm, or the most semantically meaningful production-code contribution.
- **Not too difficult or time-consuming** - The user wants to get their 'hands dirty' in code, but not at the cost of too much delay.

Make sure there's a section in the document that includes some explanation about the user's portion of the work. Don't write the code for the user. Supply information about what behavior to build/model, perhaps method signatures of collaborating components that should be used, a description of what tests need to pass, etc.

**Opt-out:** If the user says "skip the your-turn step" when requesting the proposal, or later, then omit the "your-turn" section entirely. In that case that portion of work becomes a normal agent-implemented step.

## Iteration

After writing the document, emit the full path on its own line, then emit a `file://` URL on the next line. Ask the user to review it and provide feedback in chat.
