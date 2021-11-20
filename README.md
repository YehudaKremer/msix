![MSIX](https://user-images.githubusercontent.com/946652/138101650-bf934b21-ced7-4836-a197-2e424ee1f86c.png)

[![pub package](https://img.shields.io/pub/v/msix.svg?color=blue)](https://pub.dev/packages/msix) [![MSIX toolkit package](https://img.shields.io/github/v/tag/microsoft/MSIX-Toolkit?color=blue&label=MSIX-Toolkit)](https://github.com/microsoft/MSIX-Toolkit) [![issues-closed](https://img.shields.io/github/issues-closed/YehudaKremer/msix?color=green)](https://github.com/YehudaKremer/msix/issues?q=is%3Aissue+is%3Aclosed) [![issues-open](https://img.shields.io/github/issues-raw/YehudaKremer/msix)](https://github.com/YehudaKremer/msix/issues)

# Msix
A command-line tool that create Msix installer from your flutter windows-build files.

## :clipboard: Install
In your `pubspec.yaml`, add `msix` as a new dependency:
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  msix: ^2.6.3
```

## :package: Create Msix
Run the commands:
```bash
PS c:\src\flutter_project\> flutter build windows
PS c:\src\flutter_project\> flutter pub run msix:create
```
The `flutter build windows` is required to build the executable that
`flutter pub run msix:create` bundles up in the MSIX install file.

## :gear: Configuration (Optional)
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

## :black_nib: Signing Options
**.msix** installer must be sign with certificate (.pfx)
- this package will automatically sign your app with build in **test certificate**.
- if you publish your app to the **Windows Store**, the app will automatically sign by the store.
- if you need to use **your own certificate**, use the configuration fields:`certificate_path, certificate_password`

**Note**: by default, this package will install the certificate on your machine, you can disable it by using the `--dontInstallCert` flag or the configuration: `dont_install_cert: true` 

## ![MSIX](https://user-images.githubusercontent.com/946652/138161113-c905ec10-78f1-4d96-91ac-1295ae3d2a8c.png) Windows Store
To generate msix file for publish to the Windows Store, use the `--store` flag or add `store: true` 
in msix configuration section in your `pubspec.yaml`.

###### Note:
For Windows Store publication the configuration values: `publisher_display_name`, `identity_name`, `msix_version`, `publisher` must be valid,
you can find those values in your windows store [dashboard](https://partner.microsoft.com/dashboard) (`Product` > `Product identity`) [see image](https://user-images.githubusercontent.com/946652/138753431-fa7dee7d-99b6-419c-94bf-4514c761abba.png).

For more information about publish to the Windows Store see: [How to publish your MSIX package to the Microsoft Store](https://www.advancedinstaller.com/msix-publish-microsoft-store.html)

## :file_folder: .dll Files And Assets ([FFI Library](https://pub.dev/packages/ffi "FFI package"))
To include your *.dll* and other third party assets in your msix installer, you can use the configuration:
```yaml
assets_directory_path:  'C:\Users\me\flutter_project_name\myAssets'
```

1. create new folder in your root project folder (where `pubspec.yaml` is located)
2. put there all your assets (*.dll* etc.)
3. in your application code, use the [FFI](https://pub.dev/packages/ffi "FFI package") package like so:
```dart
var helloLib = ffi.DynamicLibrary.open('myAssets/hello.dll');
var helloLib2 = ffi.DynamicLibrary.open('myAssets/subFolder/hello2.dll');

//Note: ---> DONT <--- use absolute path:
var absolutePath = path.join(Directory.current.path, 'myAssets/hello.dll');
var helloLib = ffi.DynamicLibrary.open(absolutePath);
```

## :clipboard: Available Configuration Fields:
Configuration Name &<br />CLI Arg/Flag | Description (from [microsoft docs](https://docs.microsoft.com/en-us/uwp/schemas/appxpackage/appxmanifestschema/schema-root "microsoft docs")) | Example
--- | --- | ---
|  display_name<br />`--display-name` `-d` | A friendly name that can be displayed to users. | `MyAppName` |
|  publisher_display_name<br />`--publisher-display-name` `-u` | A friendly name for the publisher that can be displayed to users. | `MyName` |
|  identity_name<br />`--identity-name` `-i` | Defines a globally unique identifier for a package. | `com.flutter.MyApp` |
|  publisher<br />`--publisher` `-b` | Describes the publisher information. | `CN=BF212345-5644-46DF-8668-014044C1B138` |
|  msix_version<br />`--version` `-v` | The version number of the package. | `1.0.0.0`<br />*(must be this format)* |
|  store<br />`--store` | The installer *(.msix)* is for publish to Windows Store | `false` |
|  output_path<br />`--output-path` `-o` | The location to create the .msix file | `C:\Users\me\Desktop\New folder\` |
|  output_name<br />`--output-name` `-n` | The name of the created .msix file | `myApp_dev` |
|  logo_path<br />`--logo-path` `-l` | Path to the app logo | `C:/<PathToIcon>/<Logo.png>` |
|  start_menu_icon_path<br />`--start-menu-icon-path` `-s` |  Path to logo that will used in start-menu.<br />if not specified will use `logo_path` | `C:/<PathToIcon>/<Icon.png>` |
|  tile_icon_path<br />`--tile-icon-path` `-t` | Path to logo used as the app tile logo. *(win10)*<br />if not specified will use `logo_path` | `C:/<PathToIcon>/<Icon.png>` |
|  vs_generated_images<br />_folder_path<br />`--vs-generated-images-path` `-g` | Visual Studio can generate for you optimized icons *(logo, tile and more)*, [see Thomas's explanation](https://github.com/YehudaKremer/msix/issues/19). This is an alternative for `logo_path`, `start_menu_icon_path`, `tile_icon_path` |  `C:\<PathToFolder>\icons` |
|  icons_background_color<br />`--icons-background-color` `-k` | Specifies the background color of the app icons, can be `transparent` or hex color like: `'#ffffff'` *(win10)* | `transparent` |
|  assets_directory_path<br />`--assets-directory-path` `-a` | Path to assets folder *(.dll files)* to include in the installer |  `C:\<PathToFolder>\myAssets` |
|  languages<br />`--languages` | Declares a language for resources contained in the package | `en-us, ja-jp` |
|  capabilities<br />`--capabilities` `-e` | List of the capabilities the application requires.<br />see [full capabilities list](https://docs.microsoft.com/en-us/windows/uwp/packaging/app-capability-declarations) | `internetClient,location,microphone,bluetooth,webcam` |
|  architecture<br />`--architecture` `-h` | Describes the architecture of the code contained in the package, one of:<br />`x86`, `x64`, `arm`, `neutral` | `x64` |
|  certificate_path<br />`--certificate-path` `-c` | Path to your certificate file | `C:/<PathToCertificate>/<MyCertificate.pfx>` |
|  certificate_password<br />`--certificate-password` `-p` | The certificate password | `1234` |
|  signtool_options<br />`--signtool-options` | *Signtool* use the syntax: *[command] [options] [file_name]*, so you can provide here the **[options]** part, [see full documentation](https://docs.microsoft.com/en-us/dotnet/framework/tools/signtool-exe)<br /><br />this **overwriting** the fields: `certificate_path`, `certificate_password` | `/v /fd SHA256 /f C:/Users/me/Desktop/my.cer` |
|  dont_install_cert<br />`--dont-install-certificate` | if `true`, the package won't try to install the certificate | `false` |
|  file_extension<br />`--file-extension` `-f` | File extensions that the app will used to open | `.txt, .myFile, .test1` |
|  protocol_activation<br />`--protocol-activation` | Protocol activation that will open the app | `http` |
|  `--debug-signing` | Showing more information about the certificate | |

---
Tags: `msi` `windows` `win10` `win11` `windows10` `windows11` `windows store` `windows installer` `windows packaging` `appx` `AppxManifest` `SignTool` `MakeAppx`
