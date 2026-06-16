# NetDoc Pro — PRTG Webhook Integration Guide

> **For sample notification templates, test scripts, and helper code, see [the repository README](README.md).**

NetDoc Pro runs a local webhook server on port **9741** that accepts alert payloads from PRTG (or any compatible monitoring tool). When an alert arrives, the matching device node on the canvas updates its status badge in real time — no manual refresh required.

---

## Prerequisites

- **Business tier** licence activated
- PRTG Network Monitor with notification/trigger access
- NetDoc Pro and PRTG running on the same machine, **or** PRTG able to reach the NetDoc Pro machine on port 9741

---

## 1. Enable the Webhook Server

1. Open the **Network Tools drawer** (toolbar button)
2. Go to the **Discover** tab
3. Scroll to **PRTG WEBHOOK SERVER** and enable the toggle
4. The status bar at the bottom of the app shows **`:9741`** in teal when the server is active

> The webhook server is **off by default**. It must be explicitly enabled each session, or it restores its last state on relaunch.

---

## Authentication

From NetDoc Pro **1.14.0**, all POST endpoints require a secret token. This prevents other software running on the same machine from injecting fake alerts into your topology diagram.

### Finding your token

1. Open **Network Tools drawer → Discover tab → PRTG WEBHOOK SERVER**
2. Below the server status indicator you will see `Token: ab3f1c2d…9c21`
3. Click the **copy icon** to copy the full token to the clipboard

### Using the token

Pass the token as a request header — this is the recommended method because headers are not recorded in proxy logs or web server access logs:

```text
X-Webhook-Token: ab3f1c2dexample9c21
```

As a legacy fallback, the token can also be appended as a query parameter. Use this only if your monitoring tool cannot set custom headers:

```text
http://localhost:9741/prtg?token=ab3f1c2dexample9c21
```

The token is generated once per installation and persists across restarts. The `/health` endpoint does **not** require a token.

> **Upgrading from v1.12 or v1.13:** Existing PRTG notification URLs (`http://localhost:9741/prtg`) will now return `401 Unauthorized`. Update your PRTG notification to send the `X-Webhook-Token` header, or append `?token=<your-token>` to the URL if your PRTG version does not support custom headers.

---

## 2. Verify the Server is Running

From PowerShell:

```powershell
Invoke-RestMethod http://localhost:9741/health
```

**Expected response:**

```json
{ "status": "ok", "service": "NetDoc Pro webhook", "port": 9741 }
```

---

## 3. Webhook Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | `/health` | Health check — no auth required |
| POST | `/prtg` | Primary PRTG alert endpoint |
| POST | `/alert` | Generic alias — same behaviour as `/prtg` |
| POST | `/webhook` | Generic alias — same behaviour as `/prtg` |

All three POST endpoints behave identically. Use `/prtg` for PRTG-specific integrations and `/alert` or `/webhook` for other monitoring tools.

---

## 4. Payload Format

The webhook server accepts a JSON object or a JSON array of objects. Field names are flexible — the server tries multiple common key names automatically.

> A ready-to-paste version of this payload is available in [`prtg/notification_template.json`](prtg/notification_template.json). You can copy its contents directly into the PRTG notification body field.

### Recognised field names

| Field | Accepted keys | Values |
|-------|--------------|--------|
| Device / host | `device`, `host`, `name` | IP address or device name matching a canvas node |
| Status | `status`, `state` | `Up`, `Down`, `Warning`, `Unusual` |
| Sensor | `sensor`, `type` | Sensor name (optional) |
| Message | `message`, `text` | Alert detail text (optional) |

### Minimum valid payload

```json
{
  "device": "192.168.1.1",
  "status": "Down"
}
```

### Full payload example

```json
{
  "device": "192.168.1.1",
  "status": "Down",
  "sensor": "Ping",
  "message": "No response from device"
}
```

### Batch payload (array)

```json
[
  { "device": "192.168.1.1",  "status": "Down",    "sensor": "Ping" },
  { "device": "192.168.1.10", "status": "Up",      "sensor": "CPU Load" },
  { "device": "192.168.1.20", "status": "Warning", "sensor": "Disk Free" }
]
```

Maximum batch size: **100 items**. Maximum payload size: **512 KB**.

---

## Testing without PRTG

You can verify the webhook works before configuring PRTG. From the test folder in this repository:

```powershell
.\test\send_test_alert.ps1
```

This sends a single fake alert to the NetDoc Pro webhook and prints the server response. If you see `received: 1, dropped: 0` and a device status change on the canvas, the webhook is working. If not, check section 9 (Troubleshooting) for common causes.

A bash equivalent is in `test/send_test_alert.sh` for WSL environments.

---

## 5. Configure PRTG

> **Note on token method:** Sections 5 and 6 use `?token=` in the URL rather than the `X-Webhook-Token` header. This is intentional — PRTG's **Execute HTTP Action** notification trigger does not support setting custom request headers, so the query parameter is the only option available within PRTG itself. The header method (recommended in the Authentication section above) applies to test scripts, Zabbix, Nagios, custom curl calls, and any tool that lets you set request headers freely.

### Step 1 — Create a notification in PRTG

1. In PRTG, go to **Setup → Notifications → Add Notification**
2. Set the notification method to **Execute HTTP Action**
3. Set the URL to:

```text
http://localhost:9741/prtg?token=YOUR_TOKEN
```

Replace `YOUR_TOKEN` with the token shown in NetDoc Pro (**Network Tools → Discover → PRTG WEBHOOK SERVER → copy icon**).

> If PRTG is on a **different machine** than NetDoc Pro, replace `localhost` with the NetDoc Pro machine's IP address (e.g. `http://192.168.1.50:9741/prtg?token=YOUR_TOKEN`). Ensure port 9741 is reachable — add a Windows Firewall inbound rule if needed.

4. Set the **HTTP Method** to `POST`
5. Set **Content-Type** to `application/json`
6. Set the **Payload** to:

```json
{
  "device": "%device",
  "status": "%status",
  "sensor": "%name",
  "message": "%message"
}
```

> A ready-to-paste version of this payload is available in [`prtg/notification_template.json`](prtg/notification_template.json). You can copy its contents directly into the PRTG notification body field.

### Step 2 — Attach the notification to a trigger

1. Open any device or sensor in PRTG
2. Go to **Notifications** → **Add State Trigger**
3. Select the notification created above
4. Set the condition (e.g. **When sensor state is Down** — send notification)
5. Save

---

## 6. Test the Webhook

Send a test payload from PowerShell without needing PRTG:

```powershell
# Single alert — device down
$token = "YOUR_TOKEN"
$body  = '{"device":"192.168.1.1","status":"Down","sensor":"Ping","message":"No response"}'
Invoke-RestMethod -Uri "http://localhost:9741/prtg?token=$token" -Method POST -ContentType "application/json" -Body $body

# Single alert — device recovered
$body = '{"device":"192.168.1.1","status":"Up","sensor":"Ping","message":"Device recovered"}'
Invoke-RestMethod -Uri "http://localhost:9741/prtg?token=$token" -Method POST -ContentType "application/json" -Body $body
```

**Expected response:**

```json
{ "received": 1, "dropped": 0 }
```

Watch the canvas — the device node matching `192.168.1.1` updates its status badge immediately. The status bar also shows a brief alert message at the bottom of the app.

### Test a batch

```powershell
$body = '[{"device":"192.168.1.1","status":"Down"},{"device":"192.168.1.10","status":"Warning"}]'
Invoke-RestMethod -Uri "http://localhost:9741/prtg?token=$token" -Method POST -ContentType "application/json" -Body $body
```

---

## 7. How Device Matching Works

The webhook matches the incoming `device` field against canvas nodes. Ensure the device name sent by PRTG (`%device`) matches the label set on the canvas node exactly.

If a device has no matching node on the canvas, the alert is accepted (returns `received: 1`) but produces no visible change.

---

## 8. Status Values

| Value | Canvas behaviour |
|-------|-----------------|
| `Up` | Node shown as online (green) |
| `Down` | Node shown as offline (red) |
| `Warning` | Node shown as warning (amber) |
| `Unusual` | Node shown as unusual (amber) |

Any unrecognised status value is stored as-is but may not produce a colour change on the canvas.

---

## 9. Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| `Could not connect` | Webhook server not running | Enable the PRTG toggle in Network Tools → Discover, check status bar for `:9741` |
| `received: 1` but no canvas change | Device name not matching a canvas node | Check the `%device` value matches the canvas node label exactly |
| `400 empty body` | POST sent with no body | Ensure PRTG is sending a JSON payload |
| `413 payload too large` | Payload exceeds 512 KB | Reduce batch size or message length |
| PRTG cannot reach port 9741 | Firewall blocking | Add Windows Firewall inbound rule for TCP 9741 |
| `401 Unauthorized` | Missing or invalid token | Add `?token=YOUR_TOKEN` to the notification URL — copy the token from Network Tools → Discover → PRTG WEBHOOK SERVER |
| PRTG on separate machine, using `localhost` | `localhost` resolves to PRTG machine | Use NetDoc Pro machine's LAN IP in the PRTG notification URL |
