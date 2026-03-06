# agentics

A marketplace of Claude Code plugins for agentic coding workflows.

## Plugins

### [picard](plugins/picard/README.md)

Three skills implementing a deliberate, phase-based coding workflow. The discipline: never let the agent write code until a written plan has been reviewed and approved.

| Skill  | Command          | Purpose                                              |
|--------|------------------|------------------------------------------------------|
| scan   | `/picard:scan`   | Deep research; produces a findings document          |
| plot   | `/picard:plot`   | Proposal with TDD checklist; iterated until approved |
| engage | `/picard:engage` | Executes the approved checklist, one step at a time  |

## Structure

```
.claude-plugin/marketplace.json   # Marketplace manifest
plugins/
  <name>/
    .claude-plugin/plugin.json    # Plugin manifest
    skills/<N>-<name>/SKILL.md    # Skill prompt (frontmatter + body)
```
