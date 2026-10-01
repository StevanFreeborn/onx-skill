# Configuration Reference for `onx`

`onx` can be configured using command-line arguments, a JSON configuration file, or environment variables.

## Precedence

Settings are resolved in the following priority order (highest to lowest):

1. **Command-line flags** (`--api-key`, `--base-url`, `--pretty`, `--config`)
2. **Configuration file** (`~/.config/onx/config.json` or path specified by `--config`)
3. **Environment variables** (`ONSPRING_API_KEY`, `ONSPRING_BASE_URL`)

## Environment Variables

Recommended for automated agent sessions, CI/CD, and containers:

| Variable            | Description                                                                 | Example                    |
| :------------------ | :-------------------------------------------------------------------------- | :------------------------- |
| `ONSPRING_API_KEY`  | Your Onspring API Key                                                       | `abcd-1234-efgh-5678`      |
| `ONSPRING_BASE_URL` | Base URL of your Onspring instance (defaults to `https://api.onspring.com`) | `https://api.onspring.com` |

### Setting in Unix (Bash / Zsh)

```bash
export ONSPRING_API_KEY="your-api-key"
export ONSPRING_BASE_URL="https://api.onspring.com"
```

### Setting in Windows (PowerShell)

```powershell
$env:ONSPRING_API_KEY = "your-api-key"
$env:ONSPRING_BASE_URL = "https://api.onspring.com"
```

---

## Configuration File

By default, `onx` checks for a configuration file at:

- **Unix / macOS**: `~/.config/onx/config.json`
- **Windows**: `%USERPROFILE%\.config\onx\config.json`

### Format

```json
{
  "apiKey": "your-api-key",
  "baseUrl": "https://api.onspring.com",
  "pretty": true
}
```

### Custom Config Location

You can supply a custom config file path to any command with `--config`:

```bash
onx apps list --config ./my-onspring-config.json
```

## Command-Line Options

Every command supports passing credentials directly:

```bash
onx ping --api-key "your-api-key" --base-url "https://api.onspring.com" --pretty
```
