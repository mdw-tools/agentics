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
<git-repo-root>/doc/work-sessions/<yyyy>/<yyyy-mm-dd_hh-mm-ss>-research-<terse-description>.md
```

- `<yyyy>` — the current four-digit year
- `<yyyy-mm-dd_hh-mm-ss>` — run `date '+%Y-%m-%d_%H-%M-%S'` to get the current date and time
- `<terse-description>` — a short, hyphen-separated description of the topic (e.g. `user-auth-flow`)

## Document structure

The document should include:

1. **Topic** — one-sentence statement of what was researched
2. **Context** — why this matters; what problem it relates to
3. **Findings** — the bulk of the document; thorough notes organized by sub-topic
   - Relevant existing code (with file paths and line numbers)
   - Dependencies and interfaces
   - Constraints and gotchas
   - Related patterns already in use in the codebase
4. **Open Questions** — things that remain unclear and should be resolved during planning
5. **References** — any external docs, files, or prior decisions consulted

## After writing the document

Tell the user where the file was written and ask them to review it before proceeding to the proposal phase.
