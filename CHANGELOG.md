# Changelog

All notable changes to this integration guide and helper scripts will be documented in this file.

## [1.1.1] — 2026-06-16

### Changed

- **Header auth is now the recommended method:** All test scripts and the integration guide now lead with the `X-Webhook-Token` request header rather than the `?token=` query parameter. Query tokens appear in proxy and web server access logs; the header does not. The `?token=` parameter remains supported as a legacy fallback for tools that cannot set custom headers.
- **INTEGRATION_GUIDE.md:** *Using the token* section reordered — header example first, `?token=` demoted to "legacy fallback" note; upgrade guidance updated accordingly.
- **README.md:** Quick start step 4 updated to show header; endpoint table auth column updated; trailing note updated.
- **test/send_test_alert.ps1:** Sends `X-Webhook-Token` header via `-Headers` hash; removes `?token=` URL suffix.
- **test/send_batch_alerts.ps1:** Same.
- **test/stress_test.ps1:** Same.
- **test/send_test_alert.sh:** Uses a curl args array with a conditional `-H "X-Webhook-Token: …"` append; removes `TOKEN_QUERY` variable.

---

## [1.1.0] — 2026-06-05

### Changed

- **Token authentication required (NetDoc Pro 1.14.0+):** The webhook server now requires a per-install secret token on all POST endpoints. Update all PRTG notification URLs from `http://localhost:9741/prtg` to `http://localhost:9741/prtg?token=YOUR_TOKEN`. The token is shown in **Network Tools → Discover → PRTG WEBHOOK SERVER** with a copy button. The `/health` endpoint remains unauthenticated.
- **INTEGRATION_GUIDE.md:** New *Authentication* section added covering how to find and use the token, plus a note for users upgrading from v1.12/v1.13.
- **README.md:** Quick start updated to include the token copy step; endpoint table updated to show auth requirement.
- **test/send_test_alert.ps1:** Added `-Token` parameter; alert POST now includes `?token=` in the URL.
- **test/send_batch_alerts.ps1:** Added `-Token` parameter; batch POST now includes `?token=` in the URL.
- **test/stress_test.ps1:** Added `-Token` parameter; all stress POSTs now include `?token=` in the URL.
- **test/send_test_alert.sh:** Added `WEBHOOK_TOKEN` environment variable; curl POST now includes `?token=` in the URL.

---

## [1.0.1] — 2026-06-02

### Fixed

- **PRTG toggle location:** All documentation corrected from "API menu → PRTG Webhook" to the accurate location: **Network Tools drawer → Discover tab → PRTG WEBHOOK SERVER**
- **Payload variable:** `%host` corrected to `%device` in `prtg/notification_template.json` and all guide references, matching the variable substitution shown in the NetDoc Pro in-app PRTG setup instructions
- **XML sensor import:** `prtg/sample_http_advanced.xml` clarified as a reference document only — PRTG does not support importing HTTP Advanced sensor configs via XML; file now includes manual setup steps instead

---

## [1.0.0] — 2026-06-02

### Added

- Initial integration guide for connecting PRTG Network Monitor to NetDoc Pro v1.12
- PowerShell test scripts for single and batch alert verification
- Bash test script for WSL environments
- Stress test script for load verification
- Sample PRTG notification template (`prtg/notification_template.json`)
- Sample PRTG HTTP Advanced sensor configuration (`prtg/sample_http_advanced.xml`)
- Example payloads for full and minimal alert formats

### Tested against

- NetDoc Pro 1.12.0
- PRTG Network Monitor 23.x and 24.x
- Windows 10, Windows 11, Windows Server 2019, Windows Server 2022
