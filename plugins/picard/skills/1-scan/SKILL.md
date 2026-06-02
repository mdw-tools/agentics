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

Assign a sequential integer `id` to every block element (`<h1>`, `<h2>`, `<h3>`, `<p>`, `<li>`, `<pre>`, `<blockquote>`), starting at `1` and incrementing without gaps. Use this structure as a template:

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
<h1 id="1">Research: <Topic></h1>

<h2 id="2">Topic</h2>
<p id="3">One-sentence statement of what was researched.</p>

<h2 id="4">Context</h2>
<p id="5">Why this matters; what problem it relates to.</p>

<h2 id="6">Findings</h2>

<h3 id="7"><Sub-topic></h3>
<p id="8">...</p>
<!-- Repeat <h3>/<p>/<pre>/<ul> blocks as needed; keep all IDs sequential. -->

<h2 id="N">Open Questions</h2>
<ul>
  <li id="N+1"><!-- one question per item --></li>
</ul>

<h2 id="N+2">References</h2>
<ul>
  <li id="N+3"><!-- one reference per item --></li>
</ul>
</body>
</html>
```

## After writing the document

Tell the user where the file was written and ask them to review it before proceeding to the proposal phase.
