# PRTG configuration templates

This folder contains ready-to-use PRTG configuration files for integrating with NetDoc Pro.

## Files

- **`notification_template.json`** — The payload body for a PRTG HTTP Action notification that forwards alerts to NetDoc Pro. Copy the contents directly into the Payload field when setting up your PRTG notification.

- **`sample_http_advanced.xml`** — Reference configuration for a PRTG HTTP Advanced sensor that monitors the NetDoc Pro webhook server's health endpoint. Useful for being alerted when NetDoc Pro is offline.

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

| Placeholder | Substitution |
|-------------|-------------|
| `%host` | Device IP or hostname |
| `%status` | Sensor state (Up, Down, Warning, Unusual) |
| `%name` | Sensor name |
| `%message` | Alert message text |

See the main [INTEGRATION_GUIDE.md](../INTEGRATION_GUIDE.md) for full setup instructions and troubleshooting.
