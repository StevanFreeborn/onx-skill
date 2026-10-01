# Onspring Record Payloads & API Data Types Reference

This reference describes the exact JSON structures, data formats, and filter syntax used with `onx records save`, `onx records query`, `onx records batch-get`, and `onx records batch-delete`, grounded in the [Onspring API v2 Specification](https://onspringapidocs.stevanfreeborn.com/).

## `records save` Payload

Used for creating or updating records:

```bash
onx records save --json '<JSON_STRING>'
# or
onx records save --file ./record.json
# or
cat ./record.json | onx records save --stdin
```

### JSON Structure

```json
{
  "appId": 195,
  "recordId": null,
  "fields": {
    "6983": "A New Test Task",
    "6984": "<p>This is a test task.</p>",
    "6985": "2026-10-01T06:00:00Z",
    "6986": "4118d53a-9121-4345-8682-07f23d606daa",
    "6987": [4],
    "6988": 100.5
  }
}
```

### Input Fields Specification

| Property   | Type             | Description                                                                                                                            |
| :--------- | :--------------- | :------------------------------------------------------------------------------------------------------------------------------------- |
| `appId`    | `number`         | The ID of the app that contains or will contain the record (required).                                                                 |
| `recordId` | `number \| null` | The ID of the record to update. If `null` or omitted, a new record is created.                                                         |
| `fields`   | `object`         | Key-value mapping where each key is the string representation of a **Field ID**, and the value is formatted per the field's data type. |

### Field Value Types When Saving

- **Text / Multi-line Text**: `string` (e.g., `"Title"` or HTML `"<p>Description</p>"`).
- **Number / Currency**: `number` (e.g., `42`, `100.50`).
- **Date / Time**: `string` in UTC ISO 8601 format (e.g., `"2026-10-01T12:00:00Z"`). Dates are always passed back and forth in UTC.
- **List (Single-Select)**: `string` containing the GUID of the chosen list value (e.g., `"4118d53a-9121-4345-8682-07f23d606daa"`).
- **List (Multi-Select)**: Array of GUID strings `string[]` (e.g., `["4118d53a-...", "1c1c5f7e-..."]`).
- **Reference (Single-Select)**: Array with one integer record ID `[140]` or integer `140`.
- **Reference (Multi-Select)**: Array of integer record IDs (e.g., `[140, 141]`).
- **Attachment / File**: Uploaded separately via `onx files upload`.

### Output on Success (`onx records save`)

```json
{
  "id": 140,
  "warnings": []
}
```

## `records query` Payload & Filter Syntax

Used for filtering and querying records across an app:

```bash
onx records query --json '<JSON_STRING>'
```

### JSON Structure

```json
{
  "appId": 195,
  "filter": "6983 eq 'Test Task' and 6987 gt 50",
  "fieldIds": [6983, 6986, 6987],
  "dataFormat": "Formatted"
}
```

### Request Fields

| Property     | Type       | Description                                                                                  |
| :----------- | :--------- | :------------------------------------------------------------------------------------------- |
| `appId`      | `number`   | App ID containing the records (required).                                                    |
| `filter`     | `string`   | Filter expression referencing Field IDs (required).                                          |
| `fieldIds`   | `number[]` | Optional array of field IDs to include in the response. If omitted, all fields are returned. |
| `dataFormat` | `string`   | Optional: `"Raw"` or `"Formatted"` (defaults to `"Raw"`).                                    |

### Query Filter Operators & Rules

Filter expressions evaluate field values using Field IDs as identifiers.

| Operator   | Description                          | Applicable Field Types                                       |
| :--------- | :----------------------------------- | :----------------------------------------------------------- |
| `eq`       | Equals                               | Text, Number, Date, Auto-Number, Formulas (text/number/date) |
| `ne`       | Not equals                           | Text, Number, Date, Auto-Number, Formulas (text/number/date) |
| `lt`       | Less than                            | Number, Date, Auto-Number, Formulas (number/date)            |
| `gt`       | Greater than                         | Number, Date, Auto-Number, Formulas (number/date)            |
| `contains` | List contains item (by name or GUID) | List fields, List formulas                                   |
| `isnull`   | Field has no value                   | Text, Number, Date, Auto-Number, Formulas                    |
| `notnull`  | Field has a value                    | Text, Number, Date, Auto-Number, Formulas                    |

#### Literal Delimiters

- **String values**: Must be enclosed in single quotes `'` (e.g., `6983 eq 'Active'`).
- **Date values**: Must be enclosed in single quotes `'` preceded by `datetime` (e.g., `6985 gt datetime'2026-01-01T00:00:00Z'`).
- **Logical combination**: Combine with `and`, `or`, and negate with `not`. Group expressions using parentheses `( ... )`.

Example:

```text
(6983 eq 'Active' or 6983 eq 'Pending') and 6987 gt 100 and 6985 notnull
```

## `records batch-get` Payload

Used to fetch specific records in bulk (maximum 100 records per request):

```bash
onx records batch-get --json '{
  "appId": 195,
  "recordIds": [1, 2, 3],
  "fieldIds": [6983, 6986],
  "dataFormat": "Formatted"
}'
```

Output:

```json
{
  "count": 3,
  "items": [
    {
      "appId": 195,
      "recordId": 1,
      "fieldData": [
        {
          "type": "String",
          "fieldId": 6983,
          "value": "Task 1"
        }
      ]
    }
  ]
}
```

## `records batch-delete` Payload

Used to delete records in bulk (maximum 100 records per request):

```bash
onx records batch-delete --json '{
  "appId": 195,
  "recordIds": [138, 139]
}'
```

Output on success:

```json
{
  "ok": true
}
```

## Understanding `dataFormat`: `Raw` vs `Formatted`

When retrieving records (`list`, `get`, `batch-get`, `query`) or reports, `dataFormat` controls the output format:

| Field Type            | `Raw` Format                                                              | `Formatted` Format                                               |
| :-------------------- | :------------------------------------------------------------------------ | :--------------------------------------------------------------- |
| **AutoNumber**        | `number` (e.g. `1`)                                                       | Formatted `string` (e.g. `"APP-001"`)                            |
| **Date/Time**         | ISO 8601 UTC string (e.g. `"2026-10-01T06:00:00Z"`)                       | Display string with user formatting (e.g. `"10/1/2026 6:00 AM"`) |
| **List**              | Value GUID string(s)                                                      | Value name string(s) (e.g. `"In Progress"`)                      |
| **Number / Currency** | `number` (e.g. `100.5`)                                                   | Display string with symbol (e.g. `"$100.50"`)                    |
| **Text**              | HTML string (e.g. `"<p>Sample</p>"`)                                      | Plain string with HTML stripped (e.g. `"Sample"`)                |
| **TimeSpan**          | Object `{ "quantity": 10, "increment": "Minutes", "recurrence": "None" }` | Display string (e.g. `"10 Minutes"`)                             |

## Record ID vs Display Field

> [!IMPORTANT]
> The `recordId` used in `onx` CLI commands (`--record <ID>`) and API routes is the integer **system record ID** (e.g., `140`).
> Do not confuse this with the text value formatted by an **AutoNumber** or Display field in the Onspring GUI (e.g., `"INC-1002"`).
