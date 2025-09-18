# CLAUDE.md — ha-llm-tools

## Purpose
Home Assistant add-on providing a unified CLI environment with **Claude Code**, **Codex (ChatGPT CLI)**, and **Gemini CLI**, plus essential developer tools (`ripgrep`, `jq`, `yq`).

**Core Functions:**
- Create and modify YAML configs under `/config`
- Provide AI-assisted developer shell inside Home Assistant
- Maintain minimal, multi-arch, portable image

## Design Principles

### Signal > Noise
- Essential files only — no drafts, temp scripts, or duplicate functions
- Delete unused code immediately
- Keep documentation concise and actionable

### Research First
- Consult Home Assistant add-on dev docs before implementation
- Verify CLI installation and usage from authoritative sources
- Document decisions with references

### One True Path
- Single method for each CLI: `addonctl claude|codex|gemini`
- No parallel or duplicate tooling
- Clear, consistent interface

### Validation-First
- Run `yamllint`, `shellcheck`, `docker buildx` before commits
- Ensure startup logs show tool versions + single `READY` line
- Test all changes locally

### Minimalism
- README ≤50 lines
- No marketing fluff
- Single CI workflow for multi-arch build/push

## Architecture

### Stack
- **Base:** HA base image (Alpine/Debian slim)
- **Tools:**
  - `claude` (Claude Code CLI, pinned)
  - `codex` (ChatGPT CLI, pinned)
  - `gemini` (Gemini CLI, pinned)
  - `ripgrep`, `jq`, `yq` (pinned binaries, checksummed)

### Interface
- **Wrapper:** `addonctl` with subcommands:
  ```bash
  addonctl claude "<prompt>"
  addonctl codex "<prompt>"
  addonctl gemini "<prompt>"
  addonctl search|get|set|diff  # operate on /config
  ```

### Configuration
- **Options schema:**
  - API keys: `openai_api_key`, `gemini_api_key`, `claude_api_key`
  - Login mode: `openai_use_login`, `gemini_use_login`, `claude_use_login`
  - Default model: `default_model`
- **Mounts:** `/config:rw` for YAML access
- **Supervisor:** s6 run → `start.sh` (logs versions, blocks)

## Authentication

### Two modes per provider:

1. **API Key (classic)**
   - Environment variables: `OPENAI_API_KEY`, `GEMINI_API_KEY`, `ANTHROPIC_API_KEY`
   - Good for automation, CI/CD
   - Lowest friction for CLI use

2. **User Login (session-based)**
   - Uses monthly subscription accounts
   - Browser-based OAuth flow
   - Credentials cached in `/data/auth/<cli>`
   - Run: `addonctl <cli> login` once after install

### Runtime Behavior
- If `*_api_key` set → use key auth
- Else if `*_use_login` true → enable login flow
- If neither → fail with clear error

## Workflow Rules

1. **Before coding:** Research latest CLI releases, HA add-on guidelines
2. **Planning:** Summarize research, propose exact tasks
3. **Execution:** Implement exactly as planned, delete noise
4. **Validation:**
   ```bash
   yamllint .
   shellcheck rootfs/usr/bin/*.sh rootfs/etc/services.d/*/run
   docker buildx build --platform linux/amd64
   ```
5. **Final report:**
   - `git status`
   - Last 5 commits
   - Example `addonctl` commands
   - Install instructions

## Documentation Standards

- **README.md:** Concise usage, options, examples only
- **CLAUDE.md:** Updated for design decisions
- **CHANGELOG.md:** Version bumps only, one-line entries

## References
- [Home Assistant add-on dev docs](https://developers.home-assistant.io/docs/add-ons)
- [s6-overlay docs](https://github.com/just-containers/s6-overlay)
- Official CLI docs for Claude, Codex, Gemini
- Alpine/Debian package docs for rg/jq/yq

## Implementation Decisions

### Tool Versions
- Pin exact versions for all CLIs (latest stable)
- Use checksums for binary verification
- Document version updates in CHANGELOG.md

### Minimal vs Extended
- Stay strict-minimal for Phase 1
- Consider optional tools (fd, bat) only if justified by user demand

### Stdin Support
- `addonctl` should support piping for YAML edits
- Example: `cat config.yaml | addonctl set sensor.temperature`