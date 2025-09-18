Perfect — here’s a refined all-in-one master prompt. It’s optimized to build a single Home Assistant add-on that ships with Claude Code CLI, ChatGPT/Codex CLI, and Gemini CLI — plus deep utility tools (rg, jq, yq). The add-on is designed as a Swiss Army Knife for AI-assisted HA config work, with /config read/write access so the CLIs can generate, edit, and validate YAML directly.

⸻

MASTER PROMPT — Build the ha-llm-tools Add-on (Claude + Codex + Gemini)

Role: You are a senior engineer agent running on my Mac. Your job is to research, plan, and build a production-quality Home Assistant add-on:
ha-llm-tools — one container that exposes Claude Code, Codex (ChatGPT CLI), and Gemini CLI in a unified way, with a clean CLI wrapper and essential developer utilities.

You will operate in two phases. Prioritize signal over noise at every step.

⸻

Core Principles
	•	Signal > Noise: Only create essential files. No temp files, drafts, duplicates, one-off test scripts, or abandoned versions. If you refactor, delete old code immediately.
	•	Terse docs: README with usage + options only (≤50 lines). No fluff.
	•	CLI-first design: One wrapper (addonctl) dispatches to subcommands:
	•	addonctl claude ...
	•	addonctl codex ...
	•	addonctl gemini ...
	•	Built-in tools: Install ripgrep, jq, yq (pinned, checksummed) for searching & editing /config.
	•	Direct /config mount: The add-on must read/write host /config YAML.
	•	Small footprint: Alpine or Debian-slim, multi-arch, least privilege.
	•	Zero secrets in repo: API keys passed via HA options → env vars.
	•	Autonomy: In Phase 2, fully implement everything without me until final readiness report.

⸻

Built-in CLIs
	•	Claude Code CLI — run local workflows against config.
	•	Codex (ChatGPT CLI) — OpenAI’s CLI (npm or pip package).
	•	Gemini CLI — Google’s official or pipx CLI.
	•	All must be installed in /usr/local/bin, pinned versions.

⸻

addonctl Wrapper (must implement)
	•	addonctl claude "<prompt>" → calls Claude Code CLI.
	•	addonctl codex "<prompt>" → calls Codex CLI.
	•	addonctl gemini "<prompt>" → calls Gemini CLI.
	•	addonctl search "<pattern>" [--ext yaml|json] → ripgrep over /config.
	•	addonctl get <yaml_path> <file> → yq read.
	•	addonctl set <yaml_path> <value> <file> → yq write.
	•	addonctl diff <fileA> <fileB> → clean diff of YAML.

All must work directly on /config.

⸻

Phase 1 — Plan First (Stop for Approval)

Your required Phase 1 output:

ADD-ON OPTIONS:
	1.	<name> — <one-liner> (pros/cons, footprint)
	2.	<name> — <one-liner> (pros/cons, footprint)
	3.	<name> — <one-liner> (pros/cons, footprint)

SELECTION & RATIONALE:
Why ha-llm-tools is the right pick.

ARCHITECTURE (tight):
	•	Base image, multi-arch
	•	Services (s6 run/start.sh)
	•	CLI tools (claude, codex, gemini, rg, jq, yq)
	•	/config mapping with read/write
	•	Options schema: openai_api_key, gemini_api_key, claude_api_key, default_model
	•	Ports: none (CLI-only)
	•	Security: least privilege

REPO & FILES TO GENERATE (no extras):
	•	repository.json — repo descriptor
	•	ha-llm-tools/config.yaml — manifest (slug, version, arch, options, schema, map config:rw)
	•	ha-llm-tools/Dockerfile — pinned deps, CLIs, rg/jq/yq
	•	ha-llm-tools/rootfs/etc/services.d/llm/run — s6 launcher
	•	ha-llm-tools/rootfs/usr/bin/start.sh — prints ready + holds open
	•	ha-llm-tools/rootfs/usr/bin/addonctl — wrapper CLI
	•	ha-llm-tools/README.md — usage, options, examples (≤50 lines)
	•	.github/workflows/build.yml — buildx → GHCR multi-arch
	•	tmux.conf — minimal portable (Linux/macOS)

CI & RELEASE:
	•	Trigger on tag v*
	•	Multi-arch (amd64, aarch64, armv7)
	•	Publish to ghcr.io/<owner>/ha-llm-tools-{arch}
	•	Tag latest + semver

VALIDATION & TESTS:
	•	yamllint .
	•	shellcheck rootfs/usr/bin/*.sh rootfs/etc/services.d/*/run
	•	Local buildx build for amd64; run once, test addonctl --help and confirm READY log

TASK LIST:
	•	Scaffold repo with only listed files
	•	Implement Dockerfile with pinned CLIs + tools
	•	Implement addonctl wrapper
	•	Implement s6 run/start.sh (ready log, tail -f /dev/null)
	•	Add config.yaml with /config:rw and API key schema
	•	Add CI workflow
	•	Validate (lint, shellcheck, local build)

WAITING FOR “APPROVED ✅”.

⸻

Phase 2 — Build Exactly the Plan (Autonomous)

After I reply “APPROVED ✅”:
	•	Implement repo as defined (no extras).
	•	Verify pinned versions of CLIs/tools.
	•	addonctl must work with claude/codex/gemini CLIs, plus rg/jq/yq.
	•	Startup must log API keys presence (redacted) + tool versions + “READY”.
	•	CI builds and pushes to GHCR.
	•	Deliver readiness report with:
	•	git status
	•	Last 5 commits
	•	Example usage (addonctl claude, addonctl search)
	•	Install instructions (Add-on Store → Repositories → GitHub URL).

⸻

Minimal, Portable tmux.conf

set -g base-index 1
setw -g pane-base-index 1
set -s escape-time 0
set -g history-limit 50000
set -g default-terminal "tmux-256color"
set -ga terminal-overrides ",*256col*:Tc"
set -g focus-events on

unbind C-b
set -g prefix C-Space
bind C-Space send-prefix
bind C-Space last-window

bind b split-window -h -c '#{pane_current_path}'
bind v split-window -v -c '#{pane_current_path}'
bind c new-window -c '#{pane_current_path}'

bind -n M-h select-pane -L
bind -n M-j select-pane -D
bind -n M-k select-pane -U
bind -n M-l select-pane -R

set -g mouse on
setw -g mode-keys vi
bind -T copy-mode-vi v send -X begin-selection
bind -T copy-mode-vi V send -X select-line
bind -T copy-mode-vi y send -X copy-selection-and-cancel

unbind r
bind r source-file ~/.tmux.conf \; display-message "tmux reloaded"



---------

Think deeply about the approach, the tools to include, HA best practices, etc.  Go all out, don't hold back!

