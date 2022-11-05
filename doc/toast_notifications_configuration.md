## Toast Notifications configuration

##### [Toast Notifications] configuration example:

```yaml
msix_config:
  display_name: Flutter App
  toast_activator: #<-- toast notifications configuration
    clsid: A1232234-1234-1234-1234-123412341234
    arguments: "1,2,3"
    display_name: "TEST"
  version: 1.0.3.0
```

| YAML name                      | Command-line argument                 | Description                               | Example                                |
| ------------------------------ | ------------------------------------- | ----------------------------------------- | -------------------------------------- |
| `clsid`                        | `--toast-activator-clsid` `-d`        | The UUID CLSID.                           | `replaced-with-your-guid-C173E6ADF0C3` |
| `arguments`                    | `--toast-activator-arguments`         | Arguments for the toast notifications.    | `----AppNotificationActivationServer`  |
| `toast_activator_display_name` | `--toast-activator-display-name` `-d` | Display name for the toast notifications. | `Toast activator`                      |

[toast notifications]: https://docs.microsoft.com/en-us/windows/apps/design/shell/tiles-and-notifications/
