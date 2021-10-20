![MSIX](https://user-images.githubusercontent.com/946652/138101650-bf934b21-ced7-4836-a197-2e424ee1f86c.png)

[![pub package](https://img.shields.io/pub/v/msix.svg?color=blue)](https://pub.dev/packages/msix) [![MSIX toolkit package](https://img.shields.io/github/v/tag/microsoft/MSIX-Toolkit?color=blue&label=MSIX-Toolkit)](https://github.com/microsoft/MSIX-Toolkit) [![issues-closed](https://img.shields.io/github/issues-closed/YehudaKremer/msix?color=green)](https://github.com/YehudaKremer/msix/issues?q=is%3Aissue+is%3Aclosed) [![issues-open](https://img.shields.io/github/issues-raw/YehudaKremer/msix)](https://github.com/YehudaKremer/msix/issues)

# <span style="color:#0078d7">Msix<span>
A command-line tool that create Msix installer from your flutter windows-build files.

## :clipboard: Install
In your `pubspec.yaml`, add `msix` as a new dependency:
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  msix: ^2.4.2
```

## :package: Create Msix
Run the commands:
```bash
PS c:\src\flutter_project\> flutter build windows
PS c:\src\flutter_project\> flutter pub run msix:create
```
The `flutter build windows` is required to build the executable that
`flutter pub run msix:create` bundles up in the MSIX install file.

## :gear: Configuration <span style="color:gray;font-size:18px">(Optional)</span>
This package have default configuration values, but you can configure it to suit your needs by adding `msix_config:` at the end of your `pubspec.yaml` file:
```yaml
msix_config:
  display_name: MyAppName
  publisher_display_name: MyName
  identity_name: MyCompany.MySuite.MyApp
  msix_version: 1.0.0.0
  logo_path: C:\<PathToIcon>\<Logo.png>
  capabilities: 'internetClient,location,microphone,webcam'
```

See [full list of available configurations](#clipboard-available-configuration-fields).

## ![MSIX](https://user-images.githubusercontent.com/946652/138161113-c905ec10-78f1-4d96-91ac-1295ae3d2a8c.png) Windows Store
To generate msix file for publish to the Windows Store, use the `--store` flag or add `store: true` 
in msix configuration section in your `pubspec.yaml`.

###### Note:
For Windows Store publication the configuration values: `publisher_display_name`, `identity_name`, `msix_version`, `publisher` must be valid,
you can find those values in your windows store [dashboard](https://partner.microsoft.com/dashboard) (`Product` > `Product identity`).

For more information about publish to the Windows Store see: [How to publish your MSIX package to the Microsoft Store](https://www.advancedinstaller.com/msix-publish-microsoft-store.html)

## :black_nib: Signing Options
The created installer file (.msix) is automatically sign with default **test** certificate. for publishing, the Windows Store will automatically sign it for you.

If you need, you can use your own certificate using the configuration fields:`certificate_path, certificate_password, publisher` or `signtool_options`

## :file_folder: .dll Files And Assets <span style="color:gray;font-size:18px">(FFI Library)</span>
To include your *.dll* and other third party assets in your msix installer, you can use the configuration field: `assets_directory_path`:
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
Note: <span style="color:red">don't</span> use absolute-path like this:
```dart
var absolutePath = path.join(Directory.current.path, 'myAssets/hello.dll');
var helloLib = ffi.DynamicLibrary.open(absolutePath);
```

## :clipboard: Available Configuration Fields:
Configuration Name | Description (from [microsoft docs](https://docs.microsoft.com/en-us/uwp/schemas/appxpackage/appxmanifestschema/schema-root "microsoft docs")) | Example
--- | --- | ---
|  display_name | A friendly name that can be displayed to users. | `MyAppName` |
|  publisher_display_name | A friendly name for the publisher that can be displayed to users. | `MyName` |
|  identity_name | Defines a globally unique identifier for a package. | `com.flutter.MyApp` |
|  msix_version | The version number of the package. | `1.0.0.0`<br />*(must be this format)* |
|  store | The installer *(.msix)* is for publish to Windows Store | `false` |
|  logo_path | Path to the app logo | `C:/<PathToIcon>/<Logo.png>` |
|  start_menu_icon_path |  Path to logo that will used in start-menu.<br />if not specified will use `logo_path` | `C:/<PathToIcon>/<Icon.png>` |
|  tile_icon_path | Path to logo used as the app tile logo. *(win10)*<br />if not specified will use `logo_path` | `C:/<PathToIcon>/<Icon.png>` |
|  vs_generated_images<br />_folder_path | Visual Studio can generate for you optimized icons *(logo, tile and more)*, [see Thomas's explanation](https://github.com/YehudaKremer/msix/issues/19). This is an alternative for `logo_path`, `start_menu_icon_path`, `tile_icon_path` |  `C:\<PathToFolder>\icons` |
|  icons_background_color | Specifies the background color of the app icons, can be `transparent` or hex color like: `'#ffffff'` *(win10)* | `transparent` |
|  assets_directory_path | Path to assets folder *(.dll files)* to include in the installer |  `C:\<PathToFolder>\myAssets` |
|  languages | Declares a language for resources contained in the package | `en-us, ja-jp` |
|  capabilities | List of the capabilities the application requires.<br />see [full capabilities list](https://docs.microsoft.com/en-us/windows/uwp/packaging/app-capability-declarations) | `internetClient,location,microphone,bluetooth,webcam` |
|  architecture | Describes the architecture of the code contained in the package, one of:<br />`x86`, `x64`, `arm`, `neutral` | `x64` |
|  certificate_path | Path to your certificate file | `C:/<PathToCertificate>/<MyCertificate.pfx>` |
|  certificate_password | The certificate password | `1234` |
|  publisher | Describes the publisher information. The Publisher attribute **must match** the publisher subject information of the certificate used to sign a package. | `CN=My Company, O=My Company, L=Berlin, S=Berlin, C=DE` |
|  signtool_options | *Signtool* use the syntax: *[command] [options] [file_name]*, so you can provide here the **[options]** part, [see full documentation](https://docs.microsoft.com/en-us/dotnet/framework/tools/signtool-exe)<br /><br />this **overwriting** the fields: `certificate_path`, `certificate_password` | `/v /fd SHA256 /f C:/Users/me/Desktop/my.cer` |
|  file_extension | File extensions that the app will used to open | `.txt, .myFile, .test1` |
|  protocol_activation | Protocol activation that will open the app | `http` |

#####  Command-Line Arguments
You can use also the CLI arguments to set the configuration value, for example:
```bash
flutter pub run msix:create --v 1.0.3.3 --c C:/Users/me/Desktop/test_certificate.pfx --p 1234 --pu "CN=Msix Testing, O=Msix Testing Corporation, C=US"
```

###### Available Arguments Options:
- package version: `--v` (must be in the format: **1.0.0.0**)
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
package tags: `msi` `windows` `win10` `win11` `windows10` `windows11` `windows store` `windows installer` `windows packaging` `appx` `AppxManifest` `SignTool` `MakeAppx`
