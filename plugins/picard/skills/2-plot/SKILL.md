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

Design the document for **light mode** (dark text on a light background) unless the user invoking the skill specifies otherwise.

### Writing style: ASD-STE100 (Simplified Technical English)

Write all prose in the document according to the principles of ASD-STE100:

- Use simple, common words, each with one clear meaning. Prefer the shortest word that works.
- Use the active voice and name the doer: "The parser rejects empty input," not "Empty input is rejected."
- Use the present tense wherever possible.
- Keep sentences short: at most 20 words for instructions (e.g. checklist items), at most 25 words for descriptive text.
- Write one instruction per sentence, and one topic per sentence.
- Keep each paragraph to one topic and at most 6 sentences.
- Use articles ("a", "the") and demonstratives ("this", "these") — do not drop them telegraphically.
- Break up noun clusters of more than three nouns.
- Use the same term for the same thing throughout the document — no elegant variation.
- Use vertical lists in place of long, complex sentences.
- Avoid idioms, slang, and unnecessary jargon.

Exact technical names (types, functions, commands, file paths) are exempt from vocabulary rules — always write them precisely.

### Diagrams

The output is HTML, so **do not draw diagrams as ASCII/Unicode box art inside `<pre>` blocks.** Hand-drawn ASCII boxes reliably come out misaligned — edges don't line up, arrows drift, and the result looks garbled. Instead, use the actual capabilities of the medium:

- **Prefer inline SVG** for boxes-and-arrows diagrams (architecture, data flow, state machines, sequence relationships). Draw `<rect>`/`<text>`/`<line>`/`<path>` (with marker-based arrowheads) at explicit coordinates so every edge is exactly straight and every connector lands precisely. This is the most reliable option for anything with connected nodes.
- **Use styled HTML elements** (`<div>`/`<table>` with CSS borders, flexbox, or grid) for simpler layouts: a row of stages, a layered stack, a comparison grid. Let the browser align the edges instead of trying to align characters yourself.
- **Only use a `<pre>` block** for content that is genuinely text: code snippets, file trees, directory listings, terminal output — not for boxes or arrows.

When in doubt, reach for SVG. The goal is that every line is straight and every box is square without depending on monospace character alignment.

## Implementation Checklist requirements

The checklist must be detailed and actionable. Each item should be a concrete, verifiable step. **Organize steps using a red/green TDD cycle wherever applicable:**

1. Write or modify a test that captures the desired behavior
2. Run the test — confirm it fails for the **right reason** (a compile error is acceptable if the production code doesn't exist yet; a runtime assertion failure is expected once the code compiles)
3. Write or modify production code to make the test pass
4. Run the tests again — confirm they pass

Group related steps into named phases.

## Iteration

After writing the document, emit the full path on its own line, then emit a `file://` URL on the next line. Ask the user to review it and provide feedback in chat.
