# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A Claude Code **plugin marketplace**. The root `.claude-plugin/marketplace.json` declares the marketplace and lists plugins. Each plugin lives under `plugins/<name>/` and contains its own `.claude-plugin/plugin.json` and skills.

## Structure

```
.claude-plugin/marketplace.json        # Marketplace manifest
plugins/
  <plugin-name>/
    .claude-plugin/plugin.json         # Plugin manifest
    README.md
    skills/
      <N>-<skill-name>/
        SKILL.md                       # Skill prompt (frontmatter + instructions)
```

## Plugin and skill authoring

- **Marketplace manifest** (`marketplace.json`): lists plugins with `name`, `source` (relative path), `description`, and `version`.
- **Plugin manifest** (`plugin.json`): declares `name`, `description`, and `version` for a single plugin.
- **Skill files** (`SKILL.md`): YAML frontmatter with `name` and `description`, followed by the prompt body. Skills are numbered (`1-scan`, `2-plot`, `3-replot`, `4-engage`) to indicate execution order.
- Skills are invoked as `/scan`, `/plot`, `/replot`, `/engage`.

## The picard plugin

Three-phase agentic coding workflow — **never write code until a written plan is approved**:

1. `/scan` — Research only. Produces `doc/work-sessions/<yyyy>/<yyyy-mm-dd>-scan-<desc>.md`. No solutions proposed.
2. `/plot` — Proposal with TDD checklist. Produces `doc/work-sessions/<yyyy>/<yyyy-mm-dd>-proposal-<desc>.md`. Iterates with user until approved.
3. `/replot` — Reads `UPPERCASE_WORD:` annotations from an existing proposal, resolves them with the user, and rewrites the proposal in place. No code written.
4. `/engage` — Executes the approved checklist one item at a time, marking each `[x]` in the proposal document as it completes.

Work session documents are stored in the consuming repo's `doc/work-sessions/` tree, creating a durable record of reasoning.
