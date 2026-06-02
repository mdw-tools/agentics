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
  body { font-family: system-ui, -apple-system, sans-serif; max-width: 860px; margin: 3em auto; padding: 0 1.5em; color: #1a1a1a; line-height: 1.65; }
  h1 { font-size: 1.8em; border-bottom: 2px solid #e0e0e0; padding-bottom: 0.3em; }
  h2 { font-size: 1.2em; color: #333; margin-top: 2em; border-bottom: 1px solid #eee; padding-bottom: 0.2em; }
  h3 { font-size: 1em; color: #555; font-weight: 600; margin-top: 1.5em; }
  pre { background: #f6f8fa; border: 1px solid #e1e4e8; border-radius: 6px; padding: 1em 1.2em; overflow-x: auto; font-size: 0.9em; }
  code { background: #f0f0f0; padding: 0.15em 0.35em; border-radius: 3px; font-size: 0.9em; }
  pre code { background: none; padding: 0; }
  ul, ol { padding-left: 1.5em; }
  li { margin: 0.4em 0; }
  .done { opacity: 0.45; text-decoration: line-through; }
  .user-turn { border-left: 3px solid #f90; padding-left: 0.75em; background: #fffcf0; border-radius: 0 4px 4px 0; }
  .anchor { font-size: 0.7em; color: #bbb; margin-left: 0.5em; font-weight: normal; display: none; text-decoration: none; user-select: text; cursor: copy; }
  [id]:hover > .anchor { display: inline; }
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

<h2 id="your-turn">Your Turn</h2>
<p>
  The step marked &#x1F91D; in the checklist is reserved for you to implement.
  It was chosen because it is the most interesting production-code contribution
  in this proposal — the kind of work worth doing yourself.
</p>
<h3 id="your-turn-task">What to implement</h3>
<p><!-- Describe exactly what needs to be written: function signature, struct fields, algorithm, etc. --></p>
<h3 id="your-turn-context">Context and interfaces</h3>
<p><!-- Key types, functions, or patterns already in the codebase that this code must fit into. Include file paths and line numbers. --></p>
<h3 id="your-turn-success">What success looks like</h3>
<p><!-- The test that will pass once the implementation is correct. What assertions it makes. --></p>

<h2 id="checklist">Implementation Checklist</h2>

<h3>Phase 1: <name></h3>
<ul>
  <li data-step="1"><input type="checkbox"> Write test for &lt;behavior&gt; — expect failure: &lt;reason&gt;</li>
  <li data-step="2"><input type="checkbox"> Run tests, confirm failure</li>
  <li data-step="3" class="user-turn"><input type="checkbox"> &#x1F91D; Implement &lt;behavior&gt; — see #your-turn for guidance</li>
  <li data-step="4"><input type="checkbox"> Run tests, confirm passing</li>
</ul>
<!-- Repeat phase blocks as needed. data-step values are globally unique and never renumbered. -->
<script>
document.querySelectorAll('[id]').forEach(el => {
  const a = document.createElement('a');
  a.href = '#' + el.id;
  a.className = 'anchor';
  a.textContent = '#' + el.id;
  el.appendChild(a);
});
</script>
</body>
</html>
```

### ID conventions

- **Section headings** (`<h2>`, `<h3>` under `#your-turn`): fixed semantic IDs — `title`, `background`, `approach`, `tradeoffs`, `your-turn`, `your-turn-task`, `your-turn-context`, `your-turn-success`, `checklist`.
- **Phase headings** (`<h3>` inside the checklist): no `id` — they are structural groupings only.
- **Checklist steps** (`<li>` inside the checklist): `data-step="N"` where N is a globally unique integer assigned in order at document creation. **Never renumber existing steps.** When steps are added later, assign the next available number.
- **Paragraphs** (`<p>`): no `id` needed; reference by containing section.

## Implementation Checklist requirements

The checklist must be detailed and actionable. Each item should be a concrete, verifiable step. **Organize steps using a red/green TDD cycle wherever applicable:**

1. Write or modify a test that captures the desired behavior
2. Run the test — confirm it fails for the **right reason** (a compile error is acceptable if the production code doesn't exist yet; a runtime assertion failure is expected once the code compiles)
3. Write or modify production code to make the test pass
4. Run the tests again — confirm they pass

Group related steps into named phases (`<h3>` headings).

## Your Turn section

Every proposal should designate exactly one checklist step as the user's to implement. Choose the step that is:

- **Interesting** — the core logic, a non-trivial algorithm, or the most semantically meaningful production-code contribution
- **Production code, not test code** — tests are boilerplate; the user's step should be the thing the tests are testing
- **Scoped to one step** — don't bundle multiple steps; pick the single most valuable one

Mark that step with `class="user-turn"` and the 🤝 emoji prefix in the checklist. Fill in the `#your-turn` section with enough detail that the user can succeed without additional research: exact function signatures, relevant types and file paths, and a description of what the passing test will assert.

**Opt-out:** If the user says "skip the your-turn step" when requesting the proposal, or later via `#your-turn: remove this`, omit the `#your-turn` section entirely and remove the `class="user-turn"` designation from the checklist. The step becomes a normal agent-implemented step.

## Iteration

After writing the document, ask the user to review it and provide feedback in chat.

The user references elements by `#id` (e.g., `#approach: rewrite to explain the caching strategy`, `#step-3: remove this step`). Apply their feedback to the document, assign IDs to any newly-added elements following the conventions above, and overwrite the file. Do **not** renumber existing elements. Repeat until they explicitly approve.
