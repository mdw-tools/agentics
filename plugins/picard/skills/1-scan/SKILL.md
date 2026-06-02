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

## Document structure

Use semantic `id` attributes on every heading and list item so sections can be referenced in conversation by `#id`. Use this structure as a template:

```html
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Research: <Topic></title>
<style>
  body { font-family: sans-serif; max-width: 900px; margin: 2em auto; padding: 0 1em; }
  [id]::before { content: "#" attr(id) " "; font-size: 0.75em; color: #aaa; }
  li[id] { list-style: none; }
  pre { background: #f5f5f5; padding: 1em; overflow-x: auto; }
</style>
</head>
<body>
<h1 id="title">Research: <Topic></h1>

<h2 id="topic">Topic</h2>
<p>One-sentence statement of what was researched.</p>

<h2 id="context">Context</h2>
<p>Why this matters; what problem it relates to.</p>

<h2 id="findings">Findings</h2>

<h3 id="findings-<slug>"><Sub-topic></h3>
<p>...</p>
<!-- Repeat <h3> blocks as needed. Derive each id from the sub-topic heading text. -->

<h2 id="open-questions">Open Questions</h2>
<ul>
  <li id="oq-1">...</li>
</ul>

<h2 id="references">References</h2>
<ul>
  <li id="ref-1">...</li>
</ul>
</body>
</html>
```

### ID conventions

- **Headings** (`<h1>`, `<h2>`, `<h3>`): lowercase, hyphenated slug of the heading text (e.g., `id="findings-session-tokens"`).
- **List items**: `<section-id>-N` where N counts up from 1 within the section (e.g., `id="oq-1"`, `id="ref-2"`).
- **Paragraphs** (`<p>`): no `id` needed; reference by containing section.

## After writing the document

Tell the user where the file was written and ask them to review it before proceeding to the proposal phase.
