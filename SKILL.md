---
name: onx-skill
description: Interact with the Onspring platform via the onx CLI. Manage apps, records, fields, files, lists, and reports. Use when querying Onspring records, modifying data, fetching schema metadata, or automating Onspring operations.
license: MIT
compatibility: Requires onx CLI binary, network access to Onspring API instance, and an Onspring API Key.
metadata:
  author: Stevan Freeborn
  version: "0.0.0"
---

# Onspring Agent Skill (`onx-skill`)

Use this skill to interact with the Onspring platform using the `onx` command-line tool.

All capabilities, options, and JSON payload structures in this skill are grounded directly in the `onx` CLI source and the [Onspring API v2 Specification](https://onspringapidocs.stevanfreeborn.com/).

## Ground Truth & CLI Introspection

> **Important**: The `onx` CLI is the ultimate source of truth. Always run `onx <command> --help` to inspect real-time arguments, options, and commands if unsure of syntax:
>
> ```bash
> onx --help
> onx <subcommand> --help
> ```

---

## Prerequisites & Installation

Verify if `onx` is installed:

```bash
onx --version
```

If `onx` is not installed or not in `PATH`, install it using one of the helper scripts in `scripts/`:

### Windows (PowerShell)

```powershell
.\scripts\install-onx.ps1
```

Or directly from GitHub:

```powershell
irm https://raw.githubusercontent.com/StevanFreeborn/onx/main/scripts/install.ps1 | iex
```

### Linux & macOS (Bash)

```bash
bash scripts/install-onx.sh
```

Or directly from GitHub:

```bash
curl -fsSL https://raw.githubusercontent.com/StevanFreeborn/onx/main/scripts/install.sh | bash
```

---

## Authentication & Configuration

`onx` reads credentials using the following precedence:

1. **Command-line flags**: `--api-key <KEY> --base-url <URL>`
2. **Configuration file**: `~/.config/onx/config.json` (or `--config <PATH>`)
3. **Environment variables**: `ONSPRING_API_KEY`, `ONSPRING_BASE_URL`

### Recommended Agent Setup (Environment Variables)

```bash
export ONSPRING_API_KEY="your-api-key"
export ONSPRING_BASE_URL="https://api.onspring.com"
```

On Windows PowerShell:

```powershell
$env:ONSPRING_API_KEY = "your-api-key"
$env:ONSPRING_BASE_URL = "https://api.onspring.com"
```

For more configuration details and file templates, see [references/configuration.md](references/configuration.md).

---

## Core Workflows

> [!NOTE]
> Global flags (e.g. `--pretty`, `--api-key`) must precede subcommands:
> `onx --pretty ping` or `onx --pretty apps list`

### Connectivity Check

```bash
onx ping
```

### Schema Discovery (Apps & Fields)

Before operating on records, discover the target App ID and Field IDs:

```bash
# List all apps
onx apps list

# Get details of a specific app
onx apps get --app 195

# List fields within an app
onx fields list --app 195

# Get field metadata (type, multiplicity, list values, formula output type)
onx fields get --field 6983
```

### Querying Records

Retrieve records matching filter expressions. String values in filters must use single quotes `'`. Date filters must be preceded by `datetime` (e.g., `datetime'2026-01-01T00:00:00Z'`):

```bash
onx records query --json '{"appId": 195, "filter": "6983 eq '\''Active'\''"}'
```

With pagination and specific field IDs:

```bash
onx records query --page-number 1 --page-size 20 --json '{
  "appId": 195,
  "filter": "6983 eq '\''Active'\'' and 6987 gt 100",
  "fieldIds": [6983, 6986, 6987],
  "dataFormat": "Formatted"
}'
```

### Retrieving Records

```bash
# Get single record by system Record ID
onx records get --app 195 --record 1

# Batch get records by IDs
onx records batch-get --json '{"appId": 195, "recordIds": [1, 2]}'
```

### Creating or Updating Records

Use `records save` with a JSON payload. Pass field values mapped by string Field IDs:

```bash
# Create record (omit recordId or set to null)
onx records save --json '{
  "appId": 195,
  "recordId": null,
  "fields": {
    "6983": "New Task",
    "6986": "4118d53a-9121-4345-8682-07f23d606daa",
    "6987": [4]
  }
}'

# Update existing record
onx records save --json '{
  "appId": 195,
  "recordId": 140,
  "fields": {
    "6983": "Updated Task Title"
  }
}'
```

### Deleting Records

```bash
# Single record
onx records delete --app 195 --record 140

# Batch delete records
onx records batch-delete --json '{"appId": 195, "recordIds": [140, 141]}'
```

### Files, Lists, & Reports

- **Files**: Inspect metadata (`onx files info --record 1 --field 6989 --file 89`), download content (`onx files get --record 1 --field 6989 --file 89 --output ./download.txt`), upload attachments (`onx files upload --record 140 --field 6989 --input ./doc.pdf`), or delete (`onx files delete --record 140 --field 6989 --file 1904`).
- **Lists**: Add or update list options (`onx lists save-item --list 906 --json '{"name": "Reviewed", "numericValue": 1.0}'`), or delete list values (`onx lists delete-item --list 906 --item 4118d53a-9121-4345-8682-07f23d606daa`).
- **Reports**: List available reports in an app (`onx reports list --app 195`) or fetch report data (`onx reports get --report 613 --format formatted`).

---

## Deep-Dive References

For detailed request schemas, Onspring data types, and full command syntax, consult:

- [references/cli-reference.md](references/cli-reference.md): Complete list of commands, subcommands, and flags.
- [references/record-payloads.md](references/record-payloads.md): Exact schemas, filter operators (`eq`, `ne`, `lt`, `gt`, `contains`, `isnull`, `notnull`), date formatting in UTC, and `Raw` vs `Formatted` responses.
- [references/configuration.md](references/configuration.md): Precedence rules and config file examples.
- [Onspring API Docs](https://onspringapidocs.stevanfreeborn.com/): Official API v2 reference guide.
