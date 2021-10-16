![MSIX](https://raw.githubusercontent.com/YehudaKremer/msix/main/documentation/logo/pub-logo.png)

[![pub package](https://img.shields.io/pub/v/msix.svg?color=blue)](https://pub.dev/packages/msix) [![MSIX toolkit package](https://img.shields.io/github/v/tag/microsoft/MSIX-Toolkit?color=blue&label=MSIX-Toolkit)](https://github.com/microsoft/MSIX-Toolkit) [![issues-closed](https://img.shields.io/github/issues-closed/YehudaKremer/msix?color=green)](https://github.com/YehudaKremer/msix/issues?q=is%3Aissue+is%3Aclosed) [![issues-open](https://img.shields.io/github/issues-raw/YehudaKremer/msix)](https://github.com/YehudaKremer/msix/issues)

# Msix
A command-line tool that create Msix installer for your flutter windows-build files.

## :clipboard: Install
In your `pubspec.yaml`, add `msix` as a new dependency.
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  msix: ^2.3.1
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
This tool come with default configuration (test values), you can configure it to suit your needs.

Add `msix_config:` configuration at the end of your `pubspec.yaml` file:
```yaml
msix_config:
  display_name: MyApp
  publisher_display_name: MyName
  identity_name: MyCompany.MySuite.MyApp
  msix_version: 1.0.0.0
  certificate_path: C:\<PathToCertificate>\<MyCertificate.pfx>
  certificate_password: 1234 (require if using .pfx certificate)
  publisher: CN=My Company, O=My Company, L=Berlin, S=Berlin, C=DE
  logo_path: C:\<PathToIcon>\<Logo.png>
  start_menu_icon_path: C:\<PathToIcon>\<Icon.png>
  tile_icon_path: C:\<PathToIcon>\<Icon.png>
  vs_generated_images_folder_path: C:\<PathToFolder>\icons
  icons_background_color: transparent (or some color like: '#ffffff')
  architecture: x64
  capabilities: 'internetClient,location,microphone,webcam'
```

###### Available Configuration Fields:
Configuration Name | Description (from [microsoft docs](https://docs.microsoft.com/en-us/uwp/schemas/appxpackage/appxmanifestschema/schema-root "microsoft docs")) | Example Value And Type | Required
--- | --- | --- | --- 
|  display_name | A friendly name that can be displayed to users. | MyApp (string) | No |
|  publisher_display_name | A friendly name for the publisher that can be displayed to users. | MyName (string) | require if uploading to windows store |
|  identity_name | Describes the contents of the package. | com.flutter.MyApp (string) | require if uploading to windows store |
|  msix_version | The version number of the package. | 1.0.0.0 (must be four numbers with dots) | require if uploading to windows store |
|  certificate_path | `C:/<PathToCertificate>/<MyCertificate.pfx>` |  | No |
|  certificate_password | the certificate password | 1234 (string) | require if using .pfx certificate |
|  publisher | Describes the publisher information. The Publisher attribute must match the publisher subject information of the certificate used to sign a package. | CN=My Company, O=My Company, L=Berlin, S=Berlin, C=DE (string) | require if uploading to windows store |
|  logo_path | An icon used as the app logo, sample: `C:/<PathToIcon>/<Logo.png>` |  | No |
|  start_menu_icon_path |  An icon used as the app logo in the start-menu, sample: `C:/<PathToIcon>/<Icon.png>` |  | No |
|  tile_icon_path | An icon used as the app tile logo in the start-menu, sample: `C:/<PathToIcon>/<Icon.png>` |  | No |
|  assets_directory_path | Assets folder (like .dll files) to include in the Msix installer |  `C:\<PathToFolder>\myAssets` (string) | No |
|  vs_generated_images_folder_path | Visual Studio can generate for you optimized icons (logo/tile and more) [see Thomas's explanation](https://github.com/YehudaKremer/msix/issues/19). This is an alternative for `logo_path`, `start_menu_icon_path`, `tile_icon_path` |  `C:\<PathToFolder>\icons` (string) | No |
|  icons_background_color | Specifies the background color of the app icons, can be `transparent` or some color like: `'#ffffff'` | transparent (string) | No |
|  languages | Declares a language for resources contained in the package. sample: `en-us, ja-jp` | en-us (string) | No |
|  architecture | Describes the architecture of the code contained in the package, one of: x86, x64, arm,, neutral | x64 (string) | No |
|  signtool_options | Signtool using this syntax: [command] [options] [file_name], you can provide here the `[options]` part, see full documentation here: https://docs.microsoft.com/en-us/dotnet/framework/tools/signtool-exe **this option is overwriting the fields: `certificate_path`, `certificate_password`** | /v /fd SHA256 /f C:/Users/me/Desktop/my.cer (string) | No |
|  file_extension | File extensions that the app will used to open | .txt, .myFile, .test1  (string) | No |
|  protocol_activation | Protocol activation that will open and use the app | http  (string) | No |
|  capabilities | List of the capabilities that the application requires. availables capabilities can be found here: [App capability declarations](https://docs.microsoft.com/en-us/windows/uwp/packaging/app-capability-declarations) | `internetClient,location,microphone,bluetooth,webcam` (string) | No |
|  store | If the msix file is intended for publish in Windows Store | false (boolean) | require if uploading to windows store |

### Signing Options
before using the msix file, we sign it with **certificate**,
this plugin use `signtool` to sign the file with default **test** certificate.
you can use your own certificate by configure the fields:
- certificate_path
- certificate_password
- publisher
- signtool_options

See also how to create your own certificate (pfx):
- [MSIX packaging - Create a self-signed .pfx certificate for local testing](https://flutter.dev/desktop#msix-packaging "Create a self-signed .pfx certificate for local testing")
- SahajRana's Medium [post](https://sahajrana.medium.com/how-to-generate-a-pfx-certificate-for-flutter-windows-msix-lib-a860cdcebb8 "How to generate a .pfx certificate for Flutter windows MSIX lib?")

## :file_folder: Assets And .dll Files (FFI Library)
To include your .dll and all other assets in your msix installer, you can use the configuration field: `assets_directory_path`, for exmaple:
```yaml
assets_directory_path:  'C:\Users\me\flutter_project_name\myAssets'
```

1. create new folder in your root folder (where `pubspec.yaml` is located)
2. put there all your assets (.dll etc.) files
3. in your application code, use the [FFI](https://pub.dev/packages/ffi "FFI package") package like so:
```dart
var hellolib = ffi.DynamicLibrary.open('myAssets/hello.dll');
```
or:
```dart
var hellolib2 = ffi.DynamicLibrary.open('myAssets/subFolder/hello2.dll');
```
**Important**: Dont use Absolute path like:
```dart
var absolutePath = path.join(Directory.current.path, 'myAssets/hello.dll');
var hellolib = ffi.DynamicLibrary.open(absolutePath);
```

## :label: Windows Store
If you publish your msix to Windows Store you dont need to sign it, Windows Store does it for you.
To generate msix file for Windows Store use the `--store` flag or add `store: true` in msix configuration sction in your `pubspec.yaml`.

###### Note:
the configuration values `publisher_display_name`, `identity_name`, `msix_version`, `publisher` must be valid,
you can find those values in your `Windows Store Dashboard` > `Product` > `Product identity`.

For more information, please see this tutorial: [How to publish your MSIX package to the Microsoft Store](https://www.advancedinstaller.com/msix-publish-microsoft-store.html)

## :gear: Command-Line Arguments
You can configuration values with command-line arguments instead of `pubspec.yaml` or combine them,
see full list of arguments and example on this [page](https://github.com/YehudaKremer/msix/blob/main/documentation/command-line-arguments.md)

## :question: Signing Error
For signing problems (signtool) try to get help on this [page](https://github.com/YehudaKremer/msix/blob/main/documentation/troubleshoot-signing-errors.md)

---
package tags: `msi` `windows` `win10` `windows10` `windows store` `windows installer` `windows packaging` `appx` `AppxManifest` `SignTool` `MakeAppx`
