<#
.SYNOPSIS
    Send a single test alert to the NetDoc Pro webhook server.
.DESCRIPTION
    Verifies the NetDoc Pro PRTG webhook is responding correctly.
    Run this before configuring PRTG to confirm the integration works.
.PARAMETER WebhookHost
    The NetDoc Pro webhook URL. Defaults to http://localhost:9741.
.PARAMETER Token
    The webhook secret token shown in NetDoc Pro (Network Tools → Discover → PRTG WEBHOOK SERVER).
    Required from NetDoc Pro 1.14.0 onwards.
.PARAMETER DeviceIp
    The IP address to send the alert for. Defaults to 192.168.1.1.
.PARAMETER Status
    The status value. Up, Down, Warning, or Unusual. Defaults to Down.
.EXAMPLE
    .\send_test_alert.ps1 -Token "ab3f1c2dexample9c21"

    Send a default Down alert for 192.168.1.1.
.EXAMPLE
    .\send_test_alert.ps1 -Token "ab3f1c2dexample9c21" -DeviceIp "10.0.99.1" -Status "Up"

    Send a recovery alert for a specific device.
#>

param(
    [string]$WebhookHost = "http://localhost:9741",
    [string]$Token       = "",
    [string]$DeviceIp    = "192.168.1.1",
    [ValidateSet("Up","Down","Warning","Unusual")]
    [string]$Status      = "Down"
)

$headers = @{ 'Content-Type' = 'application/json' }
if ($Token) { $headers['X-Webhook-Token'] = $Token }
else { Write-Warning "No -Token provided. Requests will return 401 on NetDoc Pro 1.14.0+. Copy the token from Network Tools → Discover → PRTG WEBHOOK SERVER." }

# Step 1 — verify the webhook is running
try {
    $health = Invoke-RestMethod -Uri "$WebhookHost/health" -TimeoutSec 5
    Write-Host "Webhook health check: $($health.status)" -ForegroundColor Green
}
catch {
    Write-Error "Webhook server not reachable at $WebhookHost. Is the PRTG toggle enabled in NetDoc Pro?"
    Write-Error "Error detail: $_"
    exit 1
}

# Step 2 — send the test alert
$payload = @{
    device  = $DeviceIp
    status  = $Status
    sensor  = "Test sensor"
    message = "Test alert sent at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
} | ConvertTo-Json

Write-Host "Sending test alert to $DeviceIp (status: $Status)..." -ForegroundColor Cyan

try {
    $response = Invoke-RestMethod -Uri "$WebhookHost/prtg" `
                                  -Method POST `
                                  -Headers $headers `
                                  -Body $payload `
                                  -TimeoutSec 5
    Write-Host "Server response: { received: $($response.received), dropped: $($response.dropped) }" -ForegroundColor Green

    if ($response.received -ge 1) {
        Write-Host "✓ Test alert accepted. Check the NetDoc Pro canvas for the status change on device $DeviceIp." -ForegroundColor Green
    }
}
catch {
    Write-Error "Failed to send test alert: $_"
    exit 1
}
