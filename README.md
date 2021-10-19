![MSIX](https://raw.githubusercontent.com/YehudaKremer/msix/main/documentation/logo/pub-logo.png)

[![pub package](https://img.shields.io/pub/v/msix.svg?color=blue)](https://pub.dev/packages/msix) [![MSIX toolkit package](https://img.shields.io/github/v/tag/microsoft/MSIX-Toolkit?color=blue&label=MSIX-Toolkit)](https://github.com/microsoft/MSIX-Toolkit) [![issues-closed](https://img.shields.io/github/issues-closed/YehudaKremer/msix?color=green)](https://github.com/YehudaKremer/msix/issues?q=is%3Aissue+is%3Aclosed) [![issues-open](https://img.shields.io/github/issues-raw/YehudaKremer/msix)](https://github.com/YehudaKremer/msix/issues)

# Msix
A command-line tool that create Msix installer from your flutter windows-build files.

## :clipboard: Install
In your `pubspec.yaml`, add `msix` as a new dependency.
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  msix: ^2.4.0
```

## :package: Create Msix
Run:
```bash
PS c:\src\flutter_project\> flutter build windows
PS c:\src\flutter_project\> flutter pub run msix:create
```
The `flutter build windows` is required to build the executable that
`flutter pub run msix:create` bundles up in the MSIX install file.

## :gear: Configuration (Optional)
This plugin come with default configuration (test values), you can configure it to suit your needs.

For full list of available configurations and samples see: [available-configuration-fields](#available-configuration-fields).

Add `msix_config:` configuration at the end of your `pubspec.yaml` file:
```yaml
msix_config:
  display_name: MyApp
  publisher_display_name: MyName
  identity_name: MyCompany.MySuite.MyApp
  msix_version: 1.0.0.0
  logo_path: C:\<PathToIcon>\<Logo.png>
  vs_generated_images_folder_path: C:\<PathToFolder>\icons
  capabilities: 'internetClient,location,microphone,webcam'
```

## :label: Windows Store
To generate msix file for publish to the Windows Store, use the `--store` flag or add `store: true` 
in msix configuration section in your `pubspec.yaml`.

###### Note:
For Windows Store publication the configuration values: `publisher_display_name`, `identity_name`, `msix_version`, `publisher` must be valid,
you can find those values in your windows store account: `Windows Store Dashboard` > `Product` > `Product identity`.

For more information about publish to the Windows Store see: [How to publish your MSIX package to the Microsoft Store](https://www.advancedinstaller.com/msix-publish-microsoft-store.html)

## :black_nib: Signing Options
This plugin automatically sign the .msix installer with default **test** certificate, also, if you publish it the Windows Store will automatically sign it for you.

If you need, you can use your own certificate by configure the fields:
- certificate_path
- certificate_password
- publisher
- signtool_options

## :file_folder: .dll Files And Assets (FFI Library)
To include your *.dll* and other third party assets in your msix installer, you can use the configuration field: `assets_directory_path`, for example:
```yaml
assets_directory_path:  'C:\Users\me\flutter_project_name\myAssets'
```

1. create new folder in your root project folder (where `pubspec.yaml` is located)
2. put there all your assets (*.dll* etc.)
3. in your application code, use the [FFI](https://pub.dev/packages/ffi "FFI package") package like so:
```dart
var helloLib = ffi.DynamicLibrary.open('myAssets/hello.dll');
var helloLib2 = ffi.DynamicLibrary.open('myAssets/subFolder/hello2.dll');
```
**Important**: **don't** use absolute path like this:
```dart
var absolutePath = path.join(Directory.current.path, 'myAssets/hello.dll');
var helloLib = ffi.DynamicLibrary.open(absolutePath);
```

## :clipboard: Available Configuration Fields:
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
|  capabilities | List of the capabilities that the application requires. available capabilities can be found here: [App capability declarations](https://docs.microsoft.com/en-us/windows/uwp/packaging/app-capability-declarations) | `internetClient,location,microphone,bluetooth,webcam` (string) | No |
|  store | If the msix file is intended for publish in Windows Store | false (boolean) | require if uploading to windows store |

#####  Command-Line Arguments
You can use also the CLI arguments to set the configuration value, for example:
```bash
flutter pub run msix:create --v 1.0.3.3 --c C:/Users/me/Desktop/test_certificate.pfx --p 1234 --pu "CN=Msix Testing, O=Msix Testing Corporation, C=US"
```

###### Available Arguments Options:
- package version: `--v` (must be in the format: **0.0.0.0**)
- certificate path: `--c`
- certificate password: `--p`
- debug signing problems: `--d`
- display name: `--dn`
- publisher display name: `--pdn`
- identity name: `--in`
- publisher: `--pu`
- logo path: `--lp`
- start_menu icon path: `--smip`
- tile icon path: `--tip`
- assets directory path: `--adp`
- vs generated images folder path: `--vsi`
- icons background color: `--ibc`
- signtool options: `--so`
- protocol activation: `--pa`
- file extension: `--fe`
- architecture: `--a`
- capabilities: `--cap`
- languages: `--l`

###### Available Arguments Flags:
- store: `--store`
- debug: `--debug`

---
package tags: `msi` `windows` `win10` `windows10` `windows store` `windows installer` `windows packaging` `appx` `AppxManifest` `SignTool` `MakeAppx`
