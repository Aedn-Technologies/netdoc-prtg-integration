<#
.SYNOPSIS
    Send a batch of test alerts to verify the array payload format.
.DESCRIPTION
    Sends 5 alerts in a single POST to test that the webhook handles
    array payloads correctly. Useful before integrating PRTG bulk notifications.
.PARAMETER WebhookHost
    The NetDoc Pro webhook URL. Defaults to http://localhost:9741.
.PARAMETER Token
    The webhook secret token shown in NetDoc Pro (Network Tools → Discover → PRTG WEBHOOK SERVER).
    Required from NetDoc Pro 1.14.0 onwards.
.EXAMPLE
    .\send_batch_alerts.ps1 -Token "ab3f1c2dexample9c21"
#>

param(
    [string]$WebhookHost = "http://localhost:9741",
    [string]$Token       = ""
)

$headers = @{ 'Content-Type' = 'application/json' }
if ($Token) { $headers['X-Webhook-Token'] = $Token }

$alerts = @(
    @{ device = "192.168.1.1";   status = "Down";    sensor = "Ping";      message = "Gateway unreachable" },
    @{ device = "192.168.1.10";  status = "Up";      sensor = "CPU Load";  message = "CPU recovered to normal" },
    @{ device = "192.168.1.20";  status = "Warning"; sensor = "Disk Free"; message = "Disk space at 85%" },
    @{ device = "192.168.1.30";  status = "Unusual"; sensor = "Latency";   message = "RTT spike to 250ms" },
    @{ device = "192.168.1.100"; status = "Up";      sensor = "Ping";      message = "Device online" }
)

$body = $alerts | ConvertTo-Json

Write-Host "Sending batch of $($alerts.Count) test alerts to $WebhookHost/prtg..." -ForegroundColor Cyan

try {
    $response = Invoke-RestMethod -Uri "$WebhookHost/prtg" `
                                  -Method POST `
                                  -Headers $headers `
                                  -Body $body `
                                  -TimeoutSec 5
    Write-Host "Server response: received=$($response.received), dropped=$($response.dropped)" -ForegroundColor Green

    if ($response.received -eq $alerts.Count) {
        Write-Host "✓ All $($alerts.Count) alerts accepted." -ForegroundColor Green
    } else {
        Write-Warning "Only $($response.received) of $($alerts.Count) alerts were accepted."
    }
}
catch {
    Write-Error "Batch alert failed: $_"
    exit 1
}
