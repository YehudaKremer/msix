## Startup Task configuration

##### [Startup Task] configuration example:

```yaml
msix_config:
  display_name: Flutter App
  startup_task: # <-- Startup Task
    task_id: my_flutter_app # optional (default: derived from app name)
    enabled: true # optional (default: true)
    parameters: autostart # optional (default: null)
  msix_version: 1.0.3.0
```

[StartupTasks Documentation](https://learn.microsoft.com/en-us/uwp/schemas/appxpackage/uapmanifestschema/element-desktop-startuptasks)
[Extension Documentation](https://learn.microsoft.com/en-us/uwp/schemas/appxpackage/uapmanifestschema/element-desktop-extension)
