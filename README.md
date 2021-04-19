![MSIX](https://raw.githubusercontent.com/YehudaKremer/msix/v2.0/documentation/logo/pub-logo.png)

[![pub package](https://img.shields.io/pub/v/msix.svg?color=blue&style=for-the-badge)](https://pub.dev/packages/msix) [![MSIX toolkit package](https://img.shields.io/github/v/tag/microsoft/MSIX-Toolkit?color=blue&label=MSIX-Toolkit&style=for-the-badge)](https://github.com/microsoft/MSIX-Toolkit) [![issues-closed](https://img.shields.io/github/issues-closed/YehudaKremer/msix?color=green&style=for-the-badge)](https://github.com/YehudaKremer/msix/issues?q=is%3Aissue+is%3Aclosed) [![issues-open](https://img.shields.io/github/issues-raw/YehudaKremer/msix?style=for-the-badge)](https://github.com/YehudaKremer/msix/issues)

# Msix
A command-line tool that create Msix installer for your flutter windows-build files.

## :clipboard: Install
In your `pubspec.yaml`, add `msix` as a new dependency.
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  msix: ^2.0.0
```

## :package: Create Msix
Run:
```bash
PS c:\src\flutter_project\> flutter build windows
PS c:\src\flutter_project\> flutter pub run msix:create
```
The `flutter build windows` is required to build the executable that
`flutter pub run msix:create` bundles up in the MSIX install file.

## :mag: Configuration (Optional)
This plugin comes with default configuration (test values),
you can configure it to suit your needs,
see full list of configuration fields and example on this [page](https://github.com/YehudaKremer/msix/blob/main/documentation/configuration.md)

### Signing Options
before using the msix file, we sign it with **certificate**,
this plugin use `signtool` to sign the file with default **test** certificate.
you can use your own certificate, see the documentation on the [configuration](https://github.com/YehudaKremer/msix/blob/main/documentation/configuration.md) fields:
- certificate_path
- certificate_password
- publisher
- signtool_options

## :label: Windows Store
To upload the MSIX file to Windows Store the configuration values `publisher_display_name`, `identity_name`, `msix_version`, `publisher` must be valid.

For more information, please see this tutorial: [How to publish your MSIX package to the Microsoft Store](https://www.advancedinstaller.com/msix-publish-microsoft-store.html)

## :gear: Command-Line Arguments
You can configuration values with command-line arguments instead of `pubspec.yaml` or combine them,
see full list of arguments and example on this [page](https://github.com/YehudaKremer/msix/blob/main/documentation/command-line-arguments.md)

## :question: Signing Error
For signing problems (signtool) try to get help on this [page](https://github.com/YehudaKremer/msix/blob/main/documentation/troubleshoot-signing-errors.md)

---
package tags: `msi` `windows` `win10` `windows10` `windows store` `windows installer` `windows packaging` `appx` `AppxManifest` `SignTool` `MakeAppx`