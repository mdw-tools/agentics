# riker

Branch-surgery skills, named after Commander William T. Riker.

## Skills

### separate

Split a branch with many changes into a sequence of smaller branches. Each branch builds on the one before it. The sequence can be submitted as stacked pull requests, so a large, risky change ships as several small, reviewable, deployable steps.

The skill studies the full diff, proposes a separation plan (stages, branch names, ordering, rationale), and waits for approval. It creates no branches until the user approves the plan. After execution, it verifies that the final branch's tree is identical to the original branch's tree, and writes a separation report to the project's `doc/work-sessions/` directory.

**Usage:**

- `/separate` — splits the current branch against the inferred base branch (`main` or `master`)
- `/separate <base-branch>` — splits the current branch against the specified base
- `/separate <base-branch> <branch-to-split>` — splits the specified branch against the specified base

Extra words are treated as grouping guidance, e.g. `/separate main split this into 3 parts, keep the schema changes first`.

**Guarantees:**

- The original branch is never modified.
- Nothing is pushed, deleted, or force-applied.
- The final stage branch's tree must match the original branch's tree exactly.

## Naming scheme

The plugin continues this marketplace's *Star Trek: The Next Generation* naming scheme. When the Enterprise-D faces danger too great to confront as one unit, it performs a **saucer separation** — splitting into independent sections, each able to operate on its own. Commander Riker is the officer most associated with executing that maneuver, which makes him the natural namesake for a plugin that separates one risky branch into independently deployable parts.

Riker is also the ship's **"Number One"** — fitting, for a skill whose whole output is a numbered sequence of branches.
