# agentics

A marketplace of Claude Code plugins for agentic coding workflows.

## Plugins

### [picard](plugins/picard/README.md)

Four skills implementing a deliberate, phase-based coding workflow. The discipline: never let the agent write code until a written plan has been reviewed and approved.

| Skill  | Command     | Purpose                                                        |
|--------|-------------|----------------------------------------------------------------|
| scan   | `/scan`     | Deep research; produces a findings document                    |
| plot   | `/plot`     | Proposal with TDD checklist; iterated until approved           |
| replot | `/replot`   | Revises proposal from inline annotations; no code written      |
| engage | `/engage`   | Executes the approved checklist, one step at a time            |

## Installation

**Add this marketplace to Claude Code:**

```
/plugin marketplace add mdw-tools/agentics
```

**Install the picard plugin:**

```
/plugin install picard@agentics
```

Plugins can be installed at user scope (default, available across all projects) or project scope (shared with collaborators via `.claude/settings.json`):

```
/plugin install picard@agentics --scope project
```

## Structure

```
.claude-plugin/marketplace.json   # Marketplace manifest
plugins/
  <name>/
    .claude-plugin/plugin.json    # Plugin manifest
    skills/<N>-<name>/SKILL.md    # Skill prompt (frontmatter + body)
```
