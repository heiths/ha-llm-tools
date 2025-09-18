# HA LLM Tools (Claude)

Claude Code CLI + ripgrep/jq/yq for AI-assisted Home Assistant YAML management.

## Options

| Option | Description | Default |
|--------|-------------|---------|
| `default_model` | Claude model to use (default/opus/sonnet/opus-plan) | `default` |

## Usage

First-time setup:
```bash
docker exec -it addon_ha_llm_tools claude /login
```

Examples:
```bash
# AI assistance
docker exec -it addon_ha_llm_tools addonctl claude "explain my automations"

# Search configs
docker exec -it addon_ha_llm_tools addonctl search "sensor" --ext yaml

# Read YAML values
docker exec -it addon_ha_llm_tools addonctl get .homeassistant.name /config/configuration.yaml

# Update YAML
docker exec -it addon_ha_llm_tools addonctl set .logger.default '"info"' /config/configuration.yaml

# Compare files
docker exec -it addon_ha_llm_tools addonctl diff /config/automations.yaml /config/automations.yaml.backup
```