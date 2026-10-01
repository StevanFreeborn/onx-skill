# Onx CLI Reference

This reference documents the exact top-level commands, subcommands, arguments, and options provided by the `onx` CLI, grounded in the CLI implementation and the [Onspring API v2 Specification](https://onspringapidocs.stevanfreeborn.com/).

> [!TIP]
> **Source of Truth**: Always run `onx <command> --help` to inspect live command options and subcommands in real-time.

## Global Options

The following flags are available on the top-level command:

| Option                  | Short | Description                                                                |
| :---------------------- | :---- | :------------------------------------------------------------------------- |
| `--api-key <API_KEY>`   | `-k`  | The API key for the Onspring instance                                      |
| `--base-url <BASE_URL>` | `-u`  | The base URL for the Onspring API (defaults to `https://api.onspring.com`) |
| `--config <CONFIG>`     | `-c`  | Path to a configuration JSON file                                          |
| `--pretty`              | `-p`  | Pretty-print JSON output                                                   |
| `--help`                | `-h`  | Print help                                                                 |
| `--version`             | `-V`  | Print version                                                              |

> [!NOTE]
> Global flags (such as `--pretty`, `--api-key`, `--base-url`, `--config`) must precede the subcommand in invocation:
>
> ```bash
> onx --pretty ping
> onx --pretty records list --app 195
> ```

## `ping`

Check connectivity to the Onspring API.

```bash
onx ping
```

**Output on Success:**

```json
{
  "ok": true
}
```

## `apps`

Perform operations against the apps in the instance.

### `onx apps list`

Get a paged list of apps in the instance.

- `--page-number <PAGE_NUMBER>`, `-n`: The page number to retrieve (default: 1)
- `--page-size <PAGE_SIZE>`, `-s`: The size of the page to retrieve (default: 50, max: 1000)

**Output:**

```json
{
  "pageNumber": 1,
  "pageSize": 50,
  "totalPages": 1,
  "totalRecords": 2,
  "items": [
    {
      "href": "https://api.onspring.com/apps/id/195",
      "id": 195,
      "name": "Projects"
    }
  ]
}
```

### `onx apps get`

Get information about a specific app by ID.

- `--app <APP_ID>`, `-a`: App ID to get (required, positive integer)

### `onx apps batch-get`

Get information for a batch of apps.

- `--apps <APP_IDS>`, `-a`: Comma-separated list of app IDs to get (required, e.g. `--apps 195,196`)

## `fields`

Perform operations against the fields in the instance.

### `onx fields list`

Get a paged list of fields in an app.

- `--app <APP_ID>`, `-a`: App ID whose fields will be retrieved (required)
- `--page-number <PAGE_NUMBER>`, `-n`: Page number
- `--page-size <PAGE_SIZE>`, `-s`: Page size

### `onx fields get`

Get detailed metadata about a field (type, multiplicity, list values, formula output type).

- `--field <FIELD_ID>`, `-f`: Field ID to get (required)

### `onx fields batch-get`

Get information for a batch of fields by IDs (maximum 100).

- `--fields <FIELD_IDS>`, `-f`: Comma-separated list of field IDs to get (required, e.g. `--fields 6983,6986`)

## `records`

Perform operations against records in the instance.

### `onx records list`

Get a paged list of records from an app.

- `--app <APP_ID>`, `-a`: App ID whose records will be retrieved (required)
- `--fields <FIELD_IDS>`, `-f`: Comma-separated list of field IDs to include in the response
- `--data-format <raw|formatted>`: Format of data in the response (default: `raw`)
- `--page-number <PAGE_NUMBER>`, `-n`: Page number
- `--page-size <PAGE_SIZE>`, `-s`: Page size

### `onx records get`

Get information for a single record.

- `--app <APP_ID>`, `-a`: App ID (required)
- `--record <RECORD_ID>`, `-r`: System Record ID (required)
- `--fields <FIELD_IDS>`, `-f`: Comma-separated list of field IDs to include
- `--format <raw|formatted>`, `-d`: Format of data in response (default: `raw`)

### `onx records save`

Add or update a record.

- Input body source (choose one):
  - `--json <JSON>`, `-j`: Inline JSON request body
  - `--file <FILE>`, `-f`: Path to a JSON request body file
  - `--stdin`: Read JSON request body from stdin

**Request Format:**

```json
{
  "appId": 195,
  "recordId": null,
  "fields": {
    "6983": "New Task",
    "6986": "4118d53a-9121-4345-8682-07f23d606daa"
  }
}
```

### `onx records query`

Query for records using a filter expression.

- Input body source (choose one):
  - `--json <JSON>`, `-j`: Inline JSON request body
  - `--file <FILE>`, `-f`: Path to a JSON request body file
  - `--stdin`: Read JSON request body from stdin
- Pagination options:
  - `--page-number <PAGE_NUMBER>`, `-n`: Page number
  - `--page-size <PAGE_SIZE>`, `-s`: Page size

### `onx records delete`

Delete a single record.

- `--app <APP_ID>`, `-a`: App ID (required)
- `--record <RECORD_ID>`, `-r`: System Record ID (required)

### `onx records batch-get`

Get information for a batch of records (maximum 100).

- `--json <JSON>`, `-j` / `--file <FILE>`, `-f` / `--stdin`: JSON body `{ "appId": 195, "recordIds": [1, 2], "fieldIds": [...], "dataFormat": "Raw" }`

### `onx records batch-delete`

Delete a batch of records (maximum 100).

- `--json <JSON>`, `-j` / `--file <FILE>`, `-f` / `--stdin`: JSON body `{ "appId": 195, "recordIds": [138, 139] }`

## `files`

Perform operations against files held in `Attachment` and `Image` fields.

### `onx files info`

Get metadata info for a file.

- `--record <RECORD_ID>`, `-r`: Record ID where the file is held (required)
- `--field <FIELD_ID>`, `-f`: Field ID where the file is held (required)
- `--file <FILE_ID>`, `-l`: The ID of the file (required)

### `onx files get`

Download the content of a file.

- `--record <RECORD_ID>`, `-r`: Record ID (required)
- `--field <FIELD_ID>`, `-f`: Field ID (required)
- `--file <FILE_ID>`, `-l`: File ID (required)
- `--output <PATH>`, `-o`: Optional output path to write the downloaded file to disk (if omitted, writes binary to stdout)

### `onx files upload`

Upload a file to a field on a record.

- `--record <RECORD_ID>`, `-r`: Record ID (required)
- `--field <FIELD_ID>`, `-f`: Field ID (required)
- File source (choose one):
  - `--input <PATH>`, `-i`: Path of local file to upload
  - `--stdin`, `-s`: Read file data from stdin
- Optional metadata:
  - `--name <NAME>`, `-n`: File name (required if reading from stdin; defaults to filename if `--input` is used)
  - `--type <MIME>`, `-t`: Content MIME type (e.g. `application/pdf`; inferred if omitted)
  - `--notes <NOTES>`: Optional notes to attach to the file
  - `--modified-date <TIMESTAMP>`: Optional last modified date as RFC3339 timestamp (e.g. `2026-10-01T12:00:00Z`)

### `onx files delete`

Delete a file from an attachment/image field on a record.

- `--record <RECORD_ID>`, `-r`: Record ID (required)
- `--field <FIELD_ID>`, `-f`: Field ID (required)
- `--file <FILE_ID>`, `-l`: File ID (required)

## `lists`

Perform operations against custom lists and list values in the instance.

### `onx lists save-item`

Add or update an item for a specific list.

- `--list <LIST_ID>`, `-l`: List ID where the item should be saved (required)
- `--json <JSON>`, `-j` / `--file <FILE>`, `-f` / `--stdin`: JSON body:
  ```json
  {
    "id": null,
    "name": "In Review",
    "numericValue": 1.5,
    "color": "#ffaa00"
  }
  ```
  _(Omit `id` or pass `null` to create; provide item GUID to update)_

### `onx lists delete-item`

Delete a list item from a list.

- `--list <LIST_ID>`, `-l`: List ID (required)
- `--item <ITEM_ID>`, `-i`: GUID of the item to delete (required, e.g. `4118d53a-9121-4345-8682-07f23d606daa`)

## `reports`

Perform operations against reports in an app or survey.

### `onx reports list`

List reports available in an app or survey.

- `--app <APP_ID>`, `-a`: App ID (required)
- `--page-number <PAGE_NUMBER>`, `-n`: Page number
- `--page-size <PAGE_SIZE>`, `-s`: Page size

### `onx reports get`

Get the tabular or chart data for a specific report.

- `--report <REPORT_ID>`, `-r`: Report ID (required)
- `--format <raw|formatted>`, `-f`: Format of report data (`raw` or `formatted`, default: `raw`)
- `--type <reportData|chartData>`, `-t`: Type of report data to retrieve (`reportData` or `chartData`, default: `reportData`)
- `--page-number <PAGE_NUMBER>`, `-n`: Page number
- `--page-size <PAGE_SIZE>`, `-s`: Page size
