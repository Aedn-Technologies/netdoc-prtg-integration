<#
.SYNOPSIS
    Send 100 alerts in rapid succession to test webhook stability under load.
.DESCRIPTION
    Useful for confirming the webhook can keep up with bursty PRTG notifications.
    Not necessary for normal setup — only run this if you suspect performance issues.
.PARAMETER WebhookHost
    The NetDoc Pro webhook URL. Defaults to http://localhost:9741.
.PARAMETER Count
    Number of alerts to send. Defaults to 100.
.EXAMPLE
    .\stress_test.ps1

    Send 100 alerts to the local webhook.
.EXAMPLE
    .\stress_test.ps1 -Count 50

    Send 50 alerts.
#>

param(
    [string]$WebhookHost = "http://localhost:9741",
    [int]$Count          = 100
)

Write-Host "Stress test: sending $Count alerts to $WebhookHost/prtg" -ForegroundColor Cyan

$succeeded = 0
$failed    = 0
$startTime = Get-Date

for ($i = 1; $i -le $Count; $i++) {
    $payload = @{
        device  = "192.168.1.$($i % 254 + 1)"
        status  = @("Up","Down","Warning","Unusual")[$i % 4]
        sensor  = "Stress test $i"
        message = "Alert $i of $Count"
    } | ConvertTo-Json

    try {
        Invoke-RestMethod -Uri "$WebhookHost/prtg" `
                          -Method POST `
                          -ContentType "application/json" `
                          -Body $payload `
                          -TimeoutSec 5 | Out-Null
        $succeeded++
    }
    catch {
        $failed++
    }

    if ($i % 10 -eq 0) {
        Write-Host "  Sent $i / $Count..." -ForegroundColor Gray
    }
}

$elapsed = (Get-Date) - $startTime
Write-Host ""
Write-Host "Stress test complete:" -ForegroundColor Green
Write-Host "  Succeeded : $succeeded"
Write-Host "  Failed    : $failed"
Write-Host "  Duration  : $($elapsed.TotalSeconds.ToString('F2'))s"
Write-Host "  Rate      : $(($Count / $elapsed.TotalSeconds).ToString('F1')) alerts/sec"
