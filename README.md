# NetDoc Pro — PRTG Integration

This repository contains the integration guide, sample PRTG configurations, and helper scripts for connecting [PRTG Network Monitor](https://www.paessler.com/prtg) to [NetDoc Pro](https://aedntech.com)'s built-in webhook server.

NetDoc Pro accepts PRTG alert notifications on a local webhook endpoint and updates the matching device on the topology diagram in real time. No polling, no agents, no cloud — alerts arrive in NetDoc Pro within seconds of PRTG detecting a state change.

## What's in this repository

- **[INTEGRATION_GUIDE.md](INTEGRATION_GUIDE.md)** — Full step-by-step setup guide for connecting PRTG to NetDoc Pro
- **[prtg/](prtg/)** — Ready-to-use PRTG notification templates and HTTP Advanced sensor configurations
- **[test/](test/)** — Test scripts to verify the webhook is working before configuring PRTG
- **[examples/](examples/)** — Sample payloads showing the full and minimal valid formats

## Quick start

1. Enable the PRTG webhook in NetDoc Pro (**Network Tools drawer → Discover tab → PRTG WEBHOOK SERVER**). The status bar shows `:9741` in teal when active.
2. Run `test/send_test_alert.ps1` from PowerShell to send a fake alert and confirm the webhook server is responding.
3. Configure PRTG to POST notifications to `http://localhost:9741/prtg` (or the IP of your NetDoc Pro machine if PRTG runs separately). Use the payload template from `prtg/notification_template.json`.
4. Trigger a sensor in PRTG and watch the device status badge update on the NetDoc Pro canvas.

The full integration guide covers each step in detail, including PRTG-side notification setup, firewall configuration for multi-host deployments, and troubleshooting common issues.

## Requirements

- **NetDoc Pro Business tier** — the webhook server is a Business-tier feature
- **PRTG Network Monitor** — any edition with notification triggers
- Windows 10 / 11 (NetDoc Pro is Windows only)

## Webhook endpoints

| Method | Path | Purpose |
|--------|------|---------|
| GET | `/health` | Health check, no auth required |
| POST | `/prtg` | PRTG-specific alert endpoint |
| POST | `/alert` | Generic alias for any monitoring tool |
| POST | `/webhook` | Generic alias for any monitoring tool |

All three POST endpoints behave identically. See the integration guide for payload format.

## Connecting other monitoring tools

The webhook accepts payloads from any tool that can POST JSON over HTTP. The integration is named "PRTG" because PRTG is the most common pairing, but the same endpoints work for:

- **LibreNMS** — POST notifications via webhook transports
- **Zabbix** — Custom media type with webhook script
- **Nagios / Icinga** — Notification command with `curl`
- **Custom scripts** — Any cron job or PowerShell scheduled task

Use `/alert` or `/webhook` instead of `/prtg` for non-PRTG tools to keep your monitoring stack semantically clear. Functionally identical.

## Reporting issues

Bug in the integration scripts or sample configs: open an issue on this repository.
Bug in NetDoc Pro itself: email hello@aedntech.com.
PRTG-specific questions: see the [PRTG community](https://kb.paessler.com).

## Related

- [netdoc-api-examples](https://github.com/aedntechnologies/netdoc-api-examples) — REST API client examples in Python, PowerShell, Bash, and Ansible

## Licence

MIT. The scripts and templates in this repository are free to use, modify, and redistribute. NetDoc Pro itself is a commercial product.
