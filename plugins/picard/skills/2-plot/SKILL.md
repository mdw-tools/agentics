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

Use semantic `id` attributes on every heading and list item so sections and checklist steps can be referenced in conversation by `#id`. Use this structure as a template:

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
<h1 id="title">Proposal: <Topic></h1>

<h2 id="background">Background</h2>
<p>Why this work is needed; relevant context.</p>

<h2 id="approach">Approach</h2>
<p>Detailed description of the chosen approach.</p>
<!-- Include key design decisions, alternatives considered, code snippets, file paths. -->

<h2 id="tradeoffs">Trade-offs &amp; Risks</h2>
<p>Honest assessment of downsides, open questions, or unknowns.</p>

<h2 id="checklist">Implementation Checklist</h2>

<h3 id="phase-<slug>">Phase 1: <name></h3>
<ul>
  <li id="step-1"><input type="checkbox"> Write test for &lt;behavior&gt; — expect failure: &lt;reason&gt;</li>
  <li id="step-2"><input type="checkbox"> Run tests, confirm failure</li>
  <li id="step-3"><input type="checkbox"> Implement &lt;behavior&gt;</li>
  <li id="step-4"><input type="checkbox"> Run tests, confirm passing</li>
</ul>
<!-- Repeat phase blocks as needed. Step IDs are globally unique and never renumbered. -->
</body>
</html>
```

### ID conventions

- **Section headings** (`<h2>`): fixed semantic IDs — `title`, `background`, `approach`, `tradeoffs`, `checklist`.
- **Phase headings** (`<h3>`): `phase-<slug>` derived from the phase name (e.g., `id="phase-data-model"`).
- **Checklist steps** (`<li>` inside the checklist): `step-N` where N is a globally unique integer assigned in order at document creation. **Never renumber existing steps.** When steps are added later, assign the next available number.
- **Paragraphs** (`<p>`): no `id` needed; reference by containing section.

## Implementation Checklist requirements

The checklist must be detailed and actionable. Each item should be a concrete, verifiable step. **Organize steps using a red/green TDD cycle wherever applicable:**

1. Write or modify a test that captures the desired behavior
2. Run the test — confirm it fails for the **right reason** (a compile error is acceptable if the production code doesn't exist yet; a runtime assertion failure is expected once the code compiles)
3. Write or modify production code to make the test pass
4. Run the tests again — confirm they pass

Group related steps into named phases (`<h3>` headings).

## Iteration

After writing the document, ask the user to review it and provide feedback in chat.

The user references elements by `#id` (e.g., `#approach: rewrite to explain the caching strategy`, `#step-3: remove this step`). Apply their feedback to the document, assign IDs to any newly-added elements following the conventions above, and overwrite the file. Do **not** renumber existing elements. Repeat until they explicitly approve.
