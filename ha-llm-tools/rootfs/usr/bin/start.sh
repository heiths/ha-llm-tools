#!/usr/bin/env bash
set -e

echo "==============================================="
echo " HA LLM Tools (Claude) - Starting"
echo "==============================================="

# Log versions
echo "Tool versions:"
echo "  - Claude Code: $(claude --version 2>/dev/null || echo 'not installed')"
echo "  - ripgrep: $(rg --version | head -1)"
echo "  - jq: $(jq --version)"
echo "  - yq: $(yq --version)"

# Check model setting
MODEL="${DEFAULT_MODEL:-default}"
echo ""
echo "Configuration:"
echo "  - Default model: $MODEL"
echo "  - Config mount: /config"

# Login status
echo ""
echo "Claude Code login status:"
if claude doctor 2>&1 | grep -q "logged in"; then
    echo "  - Logged in successfully"
else
    echo "  - Not logged in. Run: docker exec -it addon_ha_llm_tools claude /login"
fi

echo ""
echo "==============================================="
echo " READY"
echo "==============================================="

# Keep container running
exec tail -f /dev/null