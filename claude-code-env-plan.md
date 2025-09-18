# Claude Code Environment Plan for HA-LLM-Tools

## Executive Summary
This document outlines strategic implementation patterns for leveraging Claude Code's advanced features within the Home Assistant LLM Tools addon, focusing on automation workflows, YAML management, and AI-assisted configuration.

## Core Integration Opportunities

### 1. Custom Slash Commands for Home Assistant

#### Implementation Strategy
Create project-specific commands in `.claude/commands/` for common HA tasks:

```markdown
# .claude/commands/ha/automation.md
---
allowed-tools: Read, Write, Grep, Edit
argument-hint: [automation_name]
description: Create a Home Assistant automation
---

Generate a Home Assistant automation YAML for: $ARGUMENTS
- Follow HA best practices
- Include proper triggers, conditions, actions
- Add meaningful entity_id references
- Output to /config/automations/
```

```markdown
# .claude/commands/ha/validate.md
---
allowed-tools: Bash(yamllint:*), Read
description: Validate all HA configuration files
---

!find /config -name "*.yaml" | head -20
Validate these Home Assistant configuration files for syntax and best practices
```

#### Directory Structure
```
.claude/
├── commands/
│   ├── ha/
│   │   ├── automation.md      # Create automations
│   │   ├── scene.md           # Build scenes
│   │   ├── script.md          # Generate scripts
│   │   ├── dashboard.md       # Design dashboards
│   │   └── validate.md        # Validate configs
│   ├── yaml/
│   │   ├── merge.md          # Merge YAML files
│   │   ├── diff.md           # Compare configs
│   │   └── optimize.md       # Optimize YAML
│   └── ai/
│       ├── suggest.md        # AI suggestions
│       └── analyze.md        # Config analysis
```

### 2. Hooks System for Automated Workflows

#### Pre/Post Tool Hooks Configuration
```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Write",
        "hooks": [
          {
            "type": "command",
            "command": "if [[ \"$CLAUDE_TOOL_ARG_file_path\" == *.yaml ]]; then yamllint \"$CLAUDE_TOOL_ARG_file_path\" 2>/dev/null || true; fi"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Edit",
        "hooks": [
          {
            "type": "command",
            "command": "if [[ \"$CLAUDE_TOOL_ARG_file_path\" == /config/*.yaml ]]; then ha core check_config 2>/dev/null || echo 'Config check pending'; fi"
          }
        ]
      }
    ],
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "echo \"[HA Context] Working dir: /config | Entities: $(find /config -name '*.yaml' | wc -l) files\""
          }
        ]
      }
    ]
  }
}
```

#### Security-First Hook Patterns
```bash
#!/bin/bash
# hooks/validate-yaml.sh
set -euo pipefail

FILE="${1:-}"
[[ -z "$FILE" ]] && exit 0
[[ "$FILE" != *.yaml ]] && exit 0

# Prevent path traversal
if [[ "$FILE" == *".."* ]]; then
  echo '{"continue": false, "stopReason": "Path traversal detected"}'
  exit 1
fi

# Validate YAML syntax
if ! yamllint -d relaxed "$FILE" 2>/dev/null; then
  echo '{"continue": true, "systemMessage": "Warning: YAML validation failed"}'
fi
```

### 3. Multi-Agent Orchestration for Complex Tasks

#### Specialized Subagents Configuration

```markdown
# .claude/agents/ha-automation-builder.md
---
name: ha-automation-builder
tools: Read, Write, Grep, Edit
model: claude-3-5-haiku-20241022
---

You are a Home Assistant automation specialist. Your role:
1. Analyze entity states and device capabilities
2. Generate optimized automation YAML
3. Follow HA naming conventions
4. Include proper error handling
5. Document complex logic with comments
```

```markdown
# .claude/agents/yaml-validator.md
---
name: yaml-validator
tools: Bash(yamllint:*), Read
---

You validate Home Assistant YAML configurations:
1. Check syntax with yamllint
2. Verify entity_id references exist
3. Ensure proper indentation
4. Validate schema compliance
5. Report issues with line numbers
```

#### Orchestration Workflow Example
```python
# Pseudo-code for multi-agent automation creation
async def create_ha_automation(description):
    # Phase 1: Research
    entities = await subagent("entity-scanner").scan_devices()

    # Phase 2: Design (parallel)
    tasks = [
        subagent("trigger-designer").design_triggers(entities),
        subagent("condition-builder").build_conditions(description),
        subagent("action-planner").plan_actions(entities)
    ]
    components = await asyncio.gather(*tasks)

    # Phase 3: Build
    yaml = await subagent("ha-automation-builder").generate(components)

    # Phase 4: Validate
    validation = await subagent("yaml-validator").validate(yaml)

    # Phase 5: Deploy
    if validation.passed:
        await subagent("config-deployer").deploy(yaml)
        await subagent("test-runner").verify_automation()

    return yaml
```

### 4. CLAUDE.md Configuration Strategy

#### Root CLAUDE.md
```markdown
# HA-LLM-Tools Environment

## Context
This is a Home Assistant addon providing AI-powered configuration management.
Working directory: /config (Home Assistant configuration root)

## Key Patterns
- All YAML files must pass yamllint validation
- Entity IDs follow pattern: domain.object_id
- Automations stored in /config/automations/
- Scripts in /config/scripts/
- Scenes in /config/scenes/

## Available Commands
- `/ha:automation [description]` - Create automation
- `/ha:validate` - Validate all configs
- `/yaml:optimize` - Optimize YAML structure

## Validation Rules
1. Always validate YAML before writing
2. Check entity_id references exist
3. Ensure unique IDs for all items
4. Follow 2-space indentation
```

#### Subdirectory CLAUDE.md Files
```markdown
# /config/automations/CLAUDE.md
Focus: Home Assistant automations
Schema: https://www.home-assistant.io/docs/automation/
Required fields: id, alias, trigger, action
Optional: condition, mode, max, variables
```

### 5. Headless Mode Integration

#### CLI Wrapper Enhancement
```bash
#!/bin/bash
# addonctl enhanced with Claude Code headless mode

claude_automation() {
    local description="$1"
    claude code --headless \
        -p "Create HA automation: $description" \
        --output-format stream-json \
        --tools "Read,Write,Edit" \
        --working-dir /config
}

claude_validate() {
    claude code --headless \
        -p "Validate all YAML in /config" \
        --output-format json \
        --tools "Bash(yamllint:*),Read"
}
```

### 6. Advanced Hook Patterns

#### Dynamic Entity Discovery Hook
```bash
#!/bin/bash
# hooks/discover-entities.sh

# Run on prompt submit to provide entity context
if [[ "$CLAUDE_USER_PROMPT" == *"automation"* ]]; then
    entities=$(ha-cli entity list --json 2>/dev/null || echo "[]")
    echo "{\"systemMessage\": \"Available entities: $entities\"}"
fi
```

#### Automatic Backup Hook
```bash
#!/bin/bash
# hooks/backup-config.sh

# Backup before any /config modifications
if [[ "$CLAUDE_TOOL_NAME" == "Write" ]] || [[ "$CLAUDE_TOOL_NAME" == "Edit" ]]; then
    if [[ "$CLAUDE_TOOL_ARG_file_path" == /config/* ]]; then
        backup_dir="/data/backups/$(date +%Y%m%d)"
        mkdir -p "$backup_dir"
        cp "$CLAUDE_TOOL_ARG_file_path" "$backup_dir/" 2>/dev/null || true
    fi
fi
```

### 7. Tool-Specific Optimizations

#### MCP Integration Points
```yaml
# Potential MCP server configuration
mcp_servers:
  - name: home-assistant
    type: rest_api
    endpoint: http://supervisor/core/api
    tools:
      - get_entities
      - validate_config
      - reload_config
      - get_device_info
```

#### Custom Tool Wrappers
```python
# tools/ha_tools.py
class HomeAssistantTools:
    @tool("ha_validate")
    def validate_yaml(self, file_path: str) -> dict:
        """Validate HA YAML with schema checking"""
        # Implementation

    @tool("ha_suggest")
    def suggest_automation(self, entities: list, goal: str) -> str:
        """AI-powered automation suggestions"""
        # Implementation
```

## Implementation Roadmap

### Phase 1: Foundation (Week 1)
- [ ] Set up `.claude/commands/` structure
- [ ] Create basic HA slash commands
- [ ] Configure essential hooks (validation, backup)
- [ ] Write root CLAUDE.md

### Phase 2: Automation (Week 2)
- [ ] Implement automation builder commands
- [ ] Add YAML optimization tools
- [ ] Create entity discovery hooks
- [ ] Set up validation pipeline

### Phase 3: Intelligence (Week 3)
- [ ] Design specialized subagents
- [ ] Implement orchestration patterns
- [ ] Add AI suggestion commands
- [ ] Create test automation

### Phase 4: Polish (Week 4)
- [ ] Optimize performance
- [ ] Add error recovery
- [ ] Document workflows
- [ ] Create demo automations

## Best Practices Summary

### Command Design
1. **Atomic Commands**: Each slash command does one thing well
2. **Composability**: Commands can be chained for complex workflows
3. **Fail-Safe**: All commands validate before modifying
4. **Idempotent**: Running twice produces same result

### Hook Philosophy
1. **Minimal Overhead**: Hooks complete in <500ms
2. **Silent Success**: Only output on warnings/errors
3. **Defensive**: Always validate inputs
4. **Contextual**: Provide relevant context without noise

### Agent Coordination
1. **Clear Boundaries**: Each agent has specific domain
2. **Parallel When Possible**: Maximize throughput
3. **Sequential When Necessary**: Respect dependencies
4. **Graceful Degradation**: Handle agent failures

### Security Considerations
1. **Path Validation**: Prevent traversal attacks
2. **Input Sanitization**: Quote all variables
3. **Permission Scoping**: Minimal tool access
4. **Audit Trail**: Log all modifications

## Success Metrics

- **Automation Creation**: <30s from prompt to deployed YAML
- **Validation Coverage**: 100% of YAML files checked
- **Error Prevention**: 90% reduction in config errors
- **Developer Velocity**: 3x faster automation development
- **Context Preservation**: <50% token usage via smart caching

## Conclusion

This plan leverages Claude Code's advanced features to create a powerful, secure, and efficient Home Assistant configuration environment. By combining slash commands, hooks, and multi-agent orchestration, we can provide an unparalleled AI-assisted smart home development experience.

The modular architecture ensures extensibility while maintaining simplicity for end users. Each component can be incrementally adopted, allowing gradual sophistication as users become comfortable with the capabilities.