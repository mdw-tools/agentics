---
name: scan
description: Phase 1 of the agentic coding workflow. Conducts deep research on a topic and produces a research document for human review before any planning or implementation begins.
---

The user has asked you to research a topic in preparation for a coding task.

## Your job

Research the topic **deeply and in great detail**, exploring all relevant aspects: existing code, patterns, dependencies, constraints, edge cases, and any other context that would inform a good implementation plan.

Do **not** propose solutions, write plans, or implement anything. Your only output is a research document.

## Output document

Determine the git repo root (use `git rev-parse --show-toplevel`), then write the research findings to:

```
<git-repo-root>/doc/work-sessions/<yyyy>/<yyyy-mm-dd_hh-mm-ss>-research-<terse-description>.html
```

- `<yyyy>` — the current four-digit year
- `<yyyy-mm-dd_hh-mm-ss>` — run `date '+%Y-%m-%d_%H-%M-%S'` to get the current date and time
- `<terse-description>` — a short, hyphen-separated description of the topic (e.g. `user-auth-flow`)

## Design

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

Tell the user where the file was written. Emit the full path on its own line, then emit a `file://` URL on the next line. Ask them to review the document before proceeding to the proposal phase.
