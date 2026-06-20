# General Coding Practices Plugin

This Codex plugin provides a skill for diagnosing root causes before adding fallbacks or workarounds.

## Contents

- `.codex-plugin/plugin.json` declares the plugin.
- `skills/root-cause-before-fallback/SKILL.md` contains the root-cause-first guidance.

## Local Marketplace Entry

This repository includes `.agents/plugins/marketplace.json` with the local plugin entry:

```json
{
  "name": "general-coding-practices",
  "source": {
    "source": "local",
    "path": "./plugins/general-coding-practices"
  },
  "policy": {
    "installation": "AVAILABLE",
    "authentication": "ON_INSTALL"
  },
  "category": "Developer Tools"
}
```
