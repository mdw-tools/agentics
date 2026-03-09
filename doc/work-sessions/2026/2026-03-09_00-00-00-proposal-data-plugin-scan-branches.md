# Proposal: `data` plugin with `scan-branches` skill

## Background

The agentics marketplace currently has one plugin (`picard`) focused on the agentic coding workflow. There's a need for a new plugin that provides git-oriented utilities. The first skill in this plugin will compare two git branches, summarizing differences and flagging concerns.

The plugin is named `data` after Lt. Commander Data, continuing the Star Trek naming theme established by `picard`.

## Approach

### Plugin structure

Create a new plugin at `plugins/data/` following the same conventions as the existing `picard` plugin:

```
plugins/
  data/
    .claude-plugin/plugin.json
    README.md
    skills/
      scan-branches/
        SKILL.md
```

### `plugin.json`

```json
{
  "name": "data",
  "description": "Git-oriented analysis skills: scan-branches (compare branches).",
  "version": "0.1.0"
}
```

### Marketplace registration

Add the `data` plugin to `.claude-plugin/marketplace.json`:

```json
{
  "name": "data",
  "source": "./plugins/data",
  "description": "Git-oriented analysis skills: scan-branches (compare branches).",
  "version": "0.1.0"
}
```

### `SKILL.md` for `scan-branches`

The skill prompt will instruct Claude to:

1. **Parse arguments** — accept one or two branch names. If one is given, use the current branch (`git branch --show-current`) as the base and the argument as the comparison branch. If two are given, the first is the base and the second is the comparison.
2. **Validate** — confirm both branches exist (`git rev-parse --verify`).
3. **Gather the diff** — run `git diff <base>...<compare>` (three-dot, merge-base form) and `git log --oneline <base>...<compare>` to get both the code diff and commit history.
4. **Handle large diffs** — if the diff output is very large, do not attempt to include it all. Instead, focus on a high-level summary of what changed (which files, what kinds of changes) and call out only the most important concerns.
5. **Summarize** — review the differences, summarize the changes, and flag any concerns (bugs, security, style, inconsistencies). Be concise.

The skill will be invoked as `/scan-branches <branch>` or `/scan-branches <base> <compare>`.

#### Draft SKILL.md frontmatter

```yaml
---
name: scan-branches
description: Compare two git branches. Summarizes differences and flags concerns (bugs, security, style, inconsistencies).
---
```

### README.md

A brief README describing the plugin and its skills.

## Trade-offs & Risks

- **Large diffs**: For branches with very large diffs, the context window could be overwhelmed. The skill prompt instructs the agent to fall back to a high-level summary in this case.
- **Three-dot vs two-dot diff**: Three-dot (`...`) shows changes on the comparison branch since it diverged from the base, which is typically what you want for branch comparison. Two-dot (`..`) shows symmetric difference. The proposal uses three-dot.

## Implementation Checklist

This is a content-only change (no production code to test), so TDD doesn't apply. The checklist is straightforward file creation.

### Phase 1: Plugin scaffold

- [x] Create `plugins/data/.claude-plugin/plugin.json`
- [x] Create `plugins/data/README.md`

### Phase 2: Skill definition

- [x] Create `plugins/data/skills/scan-branches/SKILL.md` with the prompt

### Phase 3: Marketplace registration

- [x] Add the `data` plugin entry to `.claude-plugin/marketplace.json`

### Phase 4: Verification

- [x] Confirm directory structure matches conventions (`ls -R plugins/data/`)
- [x] Confirm `marketplace.json` is valid JSON
