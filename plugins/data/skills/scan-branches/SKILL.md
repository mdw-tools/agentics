---
name: scan-branches
description: Compare two git branches. Summarizes differences and flags concerns (bugs, security, style, inconsistencies).
---

The user wants to compare two git branches.

## Parse arguments

- If **one** branch name is provided, use the current branch (`git branch --show-current`) as the **base** and the provided branch as the **compare** branch.
- If **two** branch names are provided, the first is the **base** and the second is the **compare** branch.
- If no branch name is provided, ask the user which branch to compare against.

## Validate

Confirm both branches exist using `git rev-parse --verify <branch>`. If either branch does not exist, tell the user and stop.

## Gather the diff

Run both of the following:

```
git log --oneline <base>...<compare>
git diff <base>...<compare>
```

This uses the three-dot (merge-base) form, which shows changes on the compare branch since it diverged from the base.

## Handle large diffs

If the diff output is very large, do not attempt to review every line. Instead, focus on a high-level summary: which files changed, what kinds of changes were made (new features, refactors, deletions, config changes, etc.), and call out only the most important concerns.

## Summarize

Review the differences between the two branches. Summarize the changes and flag any concerns (bugs, security, style, inconsistencies). Be concise. Do NOT try to gather context about the changes from previous sessions/conversations. Take the position of an unbiased reviewer.

## Output document

Determine the git repo root (use `git rev-parse --show-toplevel`), then write the review to:

```
<git-repo-root>/doc/work-sessions/<yyyy>/<yyyy-mm-dd_hh-mm-ss>-branch-scan-<base>-vs-<compare>.html
```

- `<yyyy>` — the current four-digit year
- `<yyyy-mm-dd_hh-mm-ss>` — run `date '+%Y-%m-%d_%H-%M-%S'` to get the current date and time
- `<base>` and `<compare>` — the branch names

## HTML format

Use semantic `id` attributes on every heading and list item so sections and findings can be referenced in conversation by `#id`. Use this structure as a template:

```html
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Branch Scan: <base> vs <compare></title>
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
  .anchor { font-size: 0.7em; color: #bbb; margin-left: 0.5em; font-weight: normal; display: none; text-decoration: none; user-select: text; cursor: copy; }
  [id]:hover > .anchor { display: inline; }
</style>
</head>
<body>
<h1 id="title">Branch Scan: <base> vs <compare></h1>

<h2 id="summary">Summary</h2>
<p><!-- high-level summary of what changed --></p>

<h2 id="changed-files">Changed Files</h2>
<ul>
  <li id="change-1"><!-- one entry per changed file with a brief note --></li>
</ul>

<h2 id="concerns">Concerns</h2>
<!-- Omit this section entirely if there are no concerns. -->
<ul>
  <li id="concern-1"><!-- one concern per item --></li>
</ul>
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

- **Headings** (`<h1>`, `<h2>`, `<h3>`): lowercase, hyphenated slug of the heading text (e.g., `id="changed-files"`).
- **List items**: `<section-id>-N` where N counts up from 1 within the section (e.g., `id="concern-1"`).
- **Paragraphs** (`<p>`): no `id` needed; reference by containing section.

Tell the user where the file was written.
