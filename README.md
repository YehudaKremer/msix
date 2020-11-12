![MSIX](https://news.thewindowsclub.com/wp-content/uploads/2018/07/MSIX.jpg)

# Msix
A command-line tool that create Msix installer for your flutter windows-build files.

## Install

In your `pubspec.yaml`, add `msix` as a new dependency.

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  msix: ^0.1.1  # Or the latest version
```


## Create Msix
Run:

```bash
PS c:\src\flutter_project\> flutter build windows
PS c:\src\flutter_project\> flutter pub run msix:create
```

The `flutter build windows` is required to build the executable that
`flutter pub run msix:create` bundles up in the MSIX install file.

## Configuration (Optional)
Add `msix_config:` configuration at the end of your `pubspec.yaml` file:
```yaml
msix_config:
  display_name: MyApp
  publisher_name: MyName
  identity_name: MyCompany.MySuite.MyApp
  msix_version: 1.0.0.0
  certificate_path: C:/<PathToCertificate>/<MyCertificate.pfx>
  certificate_password: 1234 (require if using .pfx certificate)
  certificate_subject: CN=MyName
  logo_path: C:\<PathToIcon>\<Logo.png>
  start_menu_icon_path: C:\<PathToIcon>\<Icon.png>
  tile_icon_path: C:\<PathToIcon>\<Icon.png>
  icons_background_color: transparent (or some color like: '#ffffff')
  architecture: x64
  capabilities: 'documentsLibrary,internetClient,location,microphone,webcam'
```
tags: `msi` `windows` `win10` `windows10` `windows installer` `windows packaging` `appx` `AppxManifest` `SignTool` `MakeAppx`
