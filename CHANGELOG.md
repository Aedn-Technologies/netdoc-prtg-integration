# Changelog

All notable changes to this integration guide and helper scripts will be documented in this file.

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
