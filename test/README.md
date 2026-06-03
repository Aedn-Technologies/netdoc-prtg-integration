# Test scripts

Scripts to verify the NetDoc Pro webhook is working before configuring PRTG.

## Scripts

| Script                  | Purpose                                            | Platform        |
|-------------------------|----------------------------------------------------|-----------------|
| `send_test_alert.ps1`   | Send a single test alert                           | PowerShell 5.1+ |
| `send_test_alert.sh`    | Send a single test alert                           | Bash (WSL)      |
| `send_batch_alerts.ps1` | Send a batch of 5 alerts (array payload format)    | PowerShell 5.1+ |
| `stress_test.ps1`       | Send 100 rapid alerts to test webhook stability    | PowerShell 5.1+ |

## Prerequisites

1. NetDoc Pro Business tier installed and licensed
2. PRTG webhook enabled (Network Tools drawer → Discover tab → PRTG WEBHOOK SERVER toggle)
3. The bottom status bar in NetDoc Pro shows `:9741` in teal

## Quick verification

From PowerShell on the same machine as NetDoc Pro:

```powershell
.\send_test_alert.ps1
```

Expected output:

```
Webhook health check: ok
Sending test alert to 192.168.1.1 (status: Down)...
Server response: { received: 1, dropped: 0 }
✓ Test alert accepted. Check the NetDoc Pro canvas for the status change on device 192.168.1.1.
```

If the device IP exists on your canvas, you'll see its status badge update to red within a second.

## What if the test alert doesn't appear on the canvas?

`received: 1, dropped: 0` means the webhook accepted the payload. If you don't see a change on the canvas, the most likely cause is that no device on the canvas has the IP `192.168.1.1`. Edit the script and change the `-DeviceIp` parameter to one that exists in your current diagram:

```powershell
.\send_test_alert.ps1 -DeviceIp "10.0.1.1"
```
