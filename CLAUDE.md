# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

Night Agent is a shell-based orchestrator that runs Claude Code autonomously in a tmux session overnight. It drains a priority work queue (Sentry errors → declined PRs → in-progress features → planned features), dispatches sub-agent chains (Planner → Test → Executor → Reviewer), and produces a morning report with PR links.

It is **project-agnostic** — all project-specific values live in `~/.night-agent/config.json`.

## Architecture

- **`bin/night-agent`** — Bash entry point. Resets session state, writes a launcher script, and starts a tmux session running `claude --dangerously-skip-permissions` with the prompt from `prompt.md`.
- **`prompt.md`** — The full orchestrator prompt fed to Claude Code. Defines the loop, priority queue phases, sub-agent roster (Planner, Test, Executor, Reviewer), parking rules, morning report format, and hard limits.
- **`config.example.json`** — Template for `~/.night-agent/config.json`. Keys: `github.repo`, `sentry.*`, `preview.*`, `agent.*` (wakeup time, runtime limits, park-if-touches globs).
- **`session-state.json`** — Rewritten on each run. Tracks current phase, completed/parked items, active preview branch.
- **`morning-report.md`** — Appended to during the session. Template is reset by the launcher.
- **`scripts/restart-preview.sh`** — Stub script for serving a branch on a preview port. User uncomments the block matching their stack.

## Runtime Layout

The repo contains source files. At install time, everything is copied to `~/.night-agent/` (plus `~/bin/night-agent`). The agent reads config and writes state/reports in `~/.night-agent/`, not in this repo.

## Development

There is no build step, no tests, and no linter. The codebase is shell scripts and markdown. To test changes, copy modified files into `~/.night-agent/` and run `night-agent`.

## Key Constraints (from prompt.md)

- Never commits to main — everything goes through branches and PRs
- Never runs DB migrations or modifies `.env` files
- Parks anything ambiguous rather than guessing
- Only one preview server runs at a time (each PR replaces the previous)
- Sub-agents are stateless — orchestrator manages all state via `session-state.json`
