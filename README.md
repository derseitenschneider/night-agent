# Night Agent

Autonomous overnight dev agent for [Claude Code](https://docs.anthropic.com/en/docs/claude-code).
Drains a priority work queue while you sleep, writes a morning report, leaves
everything in PRs.

## What is this?

Night Agent is a thin orchestrator that runs Claude Code autonomously in a tmux
session. It works through a priority queue — Sentry errors first, then declined
PRs, in-progress features, and finally planned features — producing a morning
report you can review when you wake up.

It is project-agnostic: all project-specific values (repo, Sentry project,
preview server, etc.) live in a single `config.json`.

## File Structure

```
~/bin/
  night-agent                   ← the command you type

~/.night-agent/
  config.json                   ← your values (do not commit)
  config.example.json           ← template to copy
  prompt.md                     ← orchestrator brain
  session-state.json            ← reset each night automatically
  morning-report.md             ← read this when you wake up
  session.log                   ← raw output for debugging
  scripts/
    restart-preview.sh          ← branch preview server
```

## Prerequisites

- Claude Code installed and authenticated
- GitHub CLI: `gh auth login`
- Sentry MCP configured in Claude Code
- tmux: `brew install tmux` or `apt install tmux`
- jq: `brew install jq` or `apt install jq`

## Installation

```bash
# 1. Clone
git clone https://github.com/derseitenschneider/night-agent.git
cd night-agent

# 2. Copy files into place
cp bin/night-agent ~/bin/night-agent
chmod +x ~/bin/night-agent

mkdir -p ~/.night-agent/scripts
cp prompt.md ~/.night-agent/
cp config.example.json ~/.night-agent/
cp session-state.json ~/.night-agent/
cp morning-report.md ~/.night-agent/
cp scripts/restart-preview.sh ~/.night-agent/scripts/
chmod +x ~/.night-agent/scripts/restart-preview.sh

# 3. Configure
cp ~/.night-agent/config.example.json ~/.night-agent/config.json
# Edit config.json with your actual values

# 4. Make sure ~/bin is in your PATH
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

## Configuration

Edit `~/.night-agent/config.json`:

| Key | What to fill in |
|-----|----------------|
| `github.repo` | e.g. `your-org/your-repo` |
| `sentry.org` | your Sentry org slug |
| `sentry.project` | your Sentry project slug |
| `preview.dir` | where to check out branch previews |
| `preview.tailscale_hostname` | from `tailscale status` |
| `agent.wakeup_time` | when you want it to stop picking up new work |

## Preview Server

Edit `~/.night-agent/scripts/restart-preview.sh` and uncomment the
block that matches your stack (PHP, Node, WordPress, etc.).

Preview will be accessible from any Tailscale device at:
```
http://{tailscale_hostname}:8081
```

## Usage

```bash
night-agent              # start it, go to sleep
tmux attach -t night-agent-YYYYMMDD   # check on it
cat ~/.night-agent/morning-report.md  # read report on wakeup
```

## GitHub Issue Labels

Make sure these labels exist in your repo (create them in GitHub if not):

- `planned` — features ready to be built
- `in-progress` — features currently being worked on
- `priority` — used alongside planned to signal next pick

## Priority Queue

The agent works through this order each night:

1. **Sentry errors** → always a PR, parks if migration needed
2. **Declined PRs** → acts on specific comments, parks ambiguous ones
3. **In-progress issues** → drains task checklists, PR when all done
4. **Planned issues** → picks one, writes tests, builds, opens PR
