# Future Ideas

## Pre-run hygiene
- **Clean worktree before starting** — commit or stash any uncommitted changes before the agent begins work, so it never operates on a dirty tree.
- **Run & fix existing tests first** — before touching any feature/bug work, run the project's test suite and fix any failures. Ensures the agent starts from a known-good state.

## Post-implementation hygiene
- **Run all tests after each fix/feature** — immediately after implementing a change, re-run the full test suite to catch regressions before moving on to the next item.

## New capabilities
- **Weekly GitHub security report** — periodically pull GitHub security advisories / Dependabot alerts and surface them in the morning report.

## Workflow changes
- **Single night-agent branch** — instead of creating one branch per feature, commit all work to a single `night-agent` branch with no PRs. Simplifies the workflow and avoids PR noise.
