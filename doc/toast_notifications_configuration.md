## Toast Notifications configuration

##### [Toast Notifications] configuration example:

```yaml
msix_config:
  display_name: Flutter App
  toast_activator: #<-- toast notifications configuration
    clsid: A1232234-1234-1234-1234-123412341234
    arguments: "1,2,3"
    display_name: "TEST"
  msix_version: 1.0.3.0
```

[toast notifications]: https://docs.microsoft.com/en-us/windows/apps/design/shell/tiles-and-notifications/