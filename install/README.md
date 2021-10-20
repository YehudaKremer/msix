In your `pubspec.yaml`, add `msix` as a new dependency:
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  msix: ^2.4.1
```
Then run the commands:
```bash
PS c:\src\flutter_project\> flutter build windows
PS c:\src\flutter_project\> flutter pub run msix:create
```