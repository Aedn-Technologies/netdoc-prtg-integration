# PRTG configuration templates

This folder contains ready-to-use PRTG configuration files for integrating with NetDoc Pro.

## Files

- **`notification_template.json`** — The payload body for a PRTG HTTP Action notification that forwards alerts to NetDoc Pro. Copy the contents directly into the Payload field when setting up your PRTG notification.

- **`sample_http_advanced.xml`** — Reference configuration for a PRTG HTTP Advanced sensor that monitors the NetDoc Pro webhook server's health endpoint. **This is a reference document only** — PRTG does not support importing HTTP Advanced sensors via XML. Use it as a guide when configuring the sensor manually in the PRTG interface.

## Using the notification template

1. In PRTG, go to **Setup → Notifications → Add Notification**
2. Set the notification method to **Execute HTTP Action**
3. URL: `http://localhost:9741/prtg` (or the IP of your NetDoc Pro machine)
4. HTTP Method: `POST`
5. Content-Type: `application/json`
6. Payload: paste the contents of `notification_template.json`
7. Save and attach the notification to your sensors via state triggers

## Variable substitution

PRTG substitutes the following placeholders in the payload at notification time:

| Placeholder | Substitution                              |
|-------------|-------------------------------------------|
| `%device`   | Device name as shown in PRTG              |
| `%status`   | Sensor state (Up, Down, Warning, Unusual) |
| `%name`     | Sensor name                               |
| `%message`  | Alert message text                        |

## Enabling the webhook in NetDoc Pro

The PRTG webhook toggle is in **Network Tools drawer → Discover tab → PRTG WEBHOOK SERVER**. The webhook server is off by default — enable it before testing.

See the main [INTEGRATION_GUIDE.md](../INTEGRATION_GUIDE.md) for full setup instructions and troubleshooting.
