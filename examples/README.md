# Example payloads

Sample JSON payloads showing the full and minimal valid formats accepted by the NetDoc Pro webhook.

## Files

- **`prtg_to_netdoc_full.json`** — Complete payload with all supported fields
- **`prtg_to_netdoc_minimal.json`** — Minimum valid payload (device + status only)

## Field reference

| Field | Required | Accepted keys | Example |
|-------|----------|--------------|---------|
| Device | Yes | `device`, `host`, `name` | `"192.168.1.1"` |
| Status | Yes | `status`, `state` | `"Down"` |
| Sensor | No | `sensor`, `type` | `"Ping"` |
| Message | No | `message`, `text` | `"No response"` |

## Status values

| Value | Canvas behaviour |
|-------|-----------------|
| `Up` | Device shown as online (green) |
| `Down` | Device shown as offline (red) |
| `Warning` | Non-fatal issue (amber) |
| `Unusual` | Anomaly detected (amber) |

Any other status value is accepted but won't trigger a colour change on the canvas.

## Using these payloads in PRTG

PRTG admins typically don't write JSON by hand — see [`prtg/notification_template.json`](../prtg/notification_template.json) for the variable-substitution version that PRTG fills in automatically. The examples here are for testing the webhook directly with `curl` or PowerShell.

## Testing a payload directly

```powershell
$body = Get-Content examples\prtg_to_netdoc_full.json -Raw
Invoke-RestMethod -Uri http://localhost:9741/prtg -Method POST -ContentType "application/json" -Body $body
```

Expected response: `{ "received": 1, "dropped": 0 }`
