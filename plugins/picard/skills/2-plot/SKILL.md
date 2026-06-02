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

## Document structure

Assign a sequential integer `id` to every block element (`<h1>`, `<h2>`, `<h3>`, `<p>`, `<li>`, `<pre>`, `<blockquote>`), starting at `1` and incrementing without gaps. Use this structure as a template:

```html
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Proposal: <Topic></title>
<style>
  body { font-family: sans-serif; max-width: 900px; margin: 2em auto; padding: 0 1em; }
  [id]::before { content: "#" attr(id) " "; font-size: 0.75em; color: #aaa; }
  li[id] { list-style: none; }
  pre { background: #f5f5f5; padding: 1em; overflow-x: auto; }
  .done { opacity: 0.5; text-decoration: line-through; }
</style>
</head>
<body>
<h1 id="1">Proposal: <Topic></h1>

<h2 id="2">Background</h2>
<p id="3">Why this work is needed; relevant context.</p>

<h2 id="4">Approach</h2>
<p id="5">Detailed description of the chosen approach.</p>
<!-- Include key design decisions, alternatives considered, code snippets, file paths. -->

<h2 id="6">Trade-offs &amp; Risks</h2>
<p id="7">Honest assessment of downsides, open questions, or unknowns.</p>

<h2 id="8">Implementation Checklist</h2>

<h3 id="9">Phase 1: <name></h3>
<ul>
  <li id="10"><input type="checkbox"> Write test for &lt;behavior&gt; — expect failure: &lt;reason&gt;</li>
  <li id="11"><input type="checkbox"> Run tests, confirm failure</li>
  <li id="12"><input type="checkbox"> Implement &lt;behavior&gt;</li>
  <li id="13"><input type="checkbox"> Run tests, confirm passing</li>
</ul>
<!-- Repeat phase blocks as needed; keep all IDs sequential. -->
</body>
</html>
```

## Implementation Checklist requirements

The checklist must be detailed and actionable. Each item should be a concrete, verifiable step. **Organize steps using a red/green TDD cycle wherever applicable:**

1. Write or modify a test that captures the desired behavior
2. Run the test — confirm it fails for the **right reason** (a compile error is acceptable if the production code doesn't exist yet; a runtime assertion failure is expected once the code compiles)
3. Write or modify production code to make the test pass
4. Run the tests again — confirm they pass

Group related steps into named phases (`<h3>` headings). Each checklist item is an `<li>` with `<input type="checkbox">` and a unique sequential `id`.

## Iteration

After writing the document, ask the user to review it and provide feedback.

**In-session feedback** — the user references elements by their `#ID` numbers in chat (e.g., "#12: change this to use Y instead"). Update the proposal document to reflect their feedback, renumber all block elements sequentially from `1`, overwrite the file, and repeat until they explicitly approve. Do **not** start implementing.

**Out-of-session feedback** — the user invokes `/replot`, which reads their chat-referenced corrections, applies them, renumbers, and returns to a wait-for-approval state.
