# onx-skill

An Agent Skill adhering to the [Agent Skills Specification](https://agentskills.io) enabling AI agents to interact with the Onspring platform via the [`onx`](https://github.com/StevanFreeborn/onx) CLI.

## Overview

This skill equips agents with the instructions, progressive documentation, and bootstrap scripts necessary to perform Onspring operations.

## Installation

### Using `skills` Package Manager

Install directly using [`skills`](https://skills.sh) to automatically configure the skill for any of your installed agents:

```bash
# Install to your project
npx skills add StevanFreeborn/onx-skill

# Or install globally for all sessions
npx skills add StevanFreeborn/onx-skill -g
```

To update the skill to the latest version:

```bash
npx skills update onx-skill
```

### Manual Installation

Clone or symlink the repository into your agent's skills directory:

```bash
git clone https://github.com/StevanFreeborn/onx-skill.git <path-to-agent-skills>/onx-skill
```

Packaged `.tar.gz` and `.zip` archives are also available on the [Releases](https://github.com/StevanFreeborn/onx-skill/releases) page.

> [!NOTE]
> The skill includes automated bootstrap scripts in `scripts/` to install the `onx` CLI binary on Windows, Linux, and macOS if it is not already present in `PATH`.

## Configuration

`onx` authenticates with the Onspring API using credentials resolved in the following priority order:

1. **Command-line options**: `--api-key <KEY> --base-url <URL>`
2. **Configuration file**: `~/.config/onx/config.json` (or via `--config <PATH>`)
3. **Environment variables**: `ONSPRING_API_KEY`, `ONSPRING_BASE_URL`

### Environment Variables

```bash
export ONSPRING_API_KEY="your-api-key"
export ONSPRING_BASE_URL="https://api.onspring.com"
```

### Configuration File (`~/.config/onx/config.json`)

```json
{
  "apiKey": "your-api-key",
  "baseUrl": "https://api.onspring.com",
  "pretty": true
}
```
