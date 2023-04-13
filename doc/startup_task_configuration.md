## Startup Task configuration

Use the `startup_task:parameters` field to pass the app values (args) on startup or user log-in:

```yaml
msix_config:
  display_name: Flutter App
  startup_task: # <-- Startup Task
    task_id: my_flutter_app # optional (default: derived from app name)
    enabled: true # optional (default: true)
    parameters: autostart some_value # optional (default: null)
  msix_version: 1.0.3.0
```

```dart
void main(List<String> args) { // args: ['autostart', 'some_value']
  runApp(MyApp(args));
}

class MyApp extends StatelessWidget {
  final List<String> args;
  const MyApp(this.args, {super.key});

  //args...
```

[StartupTasks Documentation](https://learn.microsoft.com/en-us/uwp/schemas/appxpackage/uapmanifestschema/element-desktop-startuptasks)
[Extension Documentation](https://learn.microsoft.com/en-us/uwp/schemas/appxpackage/uapmanifestschema/element-desktop-extension)
