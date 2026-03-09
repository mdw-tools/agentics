# Proposal: Fix timestamp in generated filenames

## Background

The picard skills (`scan`, `plot`) generate work-session files with a `<yyyy-mm-dd_hh-mm-ss>` pattern in the filename. However, the skills don't tell the agent how to obtain the current time. The agent only has access to the date via `# currentDate` context (e.g. `Today's date is 2026-03-09`), which lacks a time component. This results in filenames like `2026-03-09_00-00-00-proposal-...`.

## Approach

Add an explicit instruction to each skill that generates a file, telling the agent to run `date '+%Y-%m-%d_%H-%M-%S'` via the Bash tool to obtain the full timestamp for the filename.

### Files to modify

- `plugins/picard/skills/1-scan/SKILL.md` — add timestamp instruction
- `plugins/picard/skills/2-plot/SKILL.md` — add timestamp instruction

### The change

In each skill's "Output document" section, after the filename pattern, add a bullet:

```
- `<yyyy-mm-dd_hh-mm-ss>` — run `date '+%Y-%m-%d_%H-%M-%S'` to get the current date and time
```

This replaces the existing `<yyyy-mm-dd>` and `<yyyy>` bullets with a single instruction that covers the full timestamp, or augments them to make the time portion explicit.

## Trade-offs & Risks

- **Timezone**: `date` uses the system's local timezone. This is fine — the timestamps are for human readability and file ordering, not cross-timezone coordination.
- **Minimal change**: This is a one-line addition per skill. Low risk.

## Implementation Checklist

### Phase 1: Update skills

- [x] Edit `plugins/picard/skills/1-scan/SKILL.md` — replace the date/year bullets with an instruction to run `date '+%Y-%m-%d_%H-%M-%S'`
- [x] Edit `plugins/picard/skills/2-plot/SKILL.md` — same change
