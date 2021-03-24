![MSIX](https://news.thewindowsclub.com/wp-content/uploads/2018/07/MSIX.jpg)

[![pub package](https://img.shields.io/pub/v/msix.svg?color=blue&style=for-the-badge)](https://pub.dev/packages/msix) [![MSIX toolkit package](https://img.shields.io/github/v/tag/microsoft/MSIX-Toolkit?color=blue&label=MSIX-Toolkit&style=for-the-badge)](https://github.com/microsoft/MSIX-Toolkit) [![issues-closed](https://img.shields.io/github/issues-closed/YehudaKremer/msix?color=green&style=for-the-badge)](https://github.com/YehudaKremer/msix/issues?q=is%3Aissue+is%3Aclosed) [![issues-open](https://img.shields.io/github/issues-raw/YehudaKremer/msix?style=for-the-badge)](https://github.com/YehudaKremer/msix/issues)

# Msix

A command-line tool that create Msix installer for your flutter windows-build files.

## :clipboard: Install

In your `pubspec.yaml`, add `msix` as a new dependency.

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  msix: ^1.0.1
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
  vs_generated_images_folder_path: C:\<PathToFolder>\Images
  icons_background_color: transparent (or some color like: '#ffffff')
  architecture: x64
  capabilities: 'internetClient,location,microphone,webcam'
```
Configuration Name | Description (from [microsoft docs](https://docs.microsoft.com/en-us/uwp/schemas/appxpackage/appxmanifestschema/schema-root "microsoft docs")) | Example Value And Type | Required
--- | --- | --- | --- 
|  display_name | A friendly name that can be displayed to users. | MyApp (string) | No |
|  publisher_display_name | A friendly name for the publisher that can be displayed to users. | MyName (string) | require if uploading to windows store |
|  identity_name | Describes the contents of the package. | com.flutter.MyApp (string) | require if uploading to windows store |
|  msix_version | The version number of the package. | 1.0.0.0 (must be four numbers with dots) | require if uploading to windows store |
|  certificate_path | `C:/<PathToCertificate>/<MyCertificate.pfx>` |  | No |
|  certificate_password | the certificate password | 1234 (string) | require if using .pfx certificate |
|  publisher | Describes the publisher information. The Publisher attribute must match the publisher subject information of the certificate used to sign a package. | CN=My Company, O=My Company, L=Berlin, S=Berlin, C=DE (string) | require if uploading to windows store |
|  logo_path | An image used as the app logo, sample: `C:/<PathToIcon>/<Logo.png>` |  | No |
|  start_menu_icon_path |  An image used as the app logo in the start-menu, sample: `C:/<PathToIcon>/<Icon.png>` |  | No |
|  tile_icon_path | An image used as the app tile logo in the start-menu, sample: `C:/<PathToIcon>/<Icon.png>` |  | No |
|  vs_generated_images_folder_path | Visual Studio can generate for you optimized icons (logo/tile and more) [see Thomas's explanation](https://github.com/YehudaKremer/msix/issues/19). This is an alternative for `logo_path`, `start_menu_icon_path`, `tile_icon_path`. sample: `C:\<PathToFolder>\Images` |  | No |
|  icons_background_color | Specifies the background color of the app icons, can be `transparent` or some color like: `#ffffff` | transparent (string) | No |
|  architecture | Describes the architecture of the code contained in the package, one of: x86, x64, arm,, neutral | x64 (string) | No |
|  capabilities | Declares the access to protected user resources that the package requires. availables capabilities: `internetClient` `internetClientServer` `privateNetworkClientServer` `allJoyn` `codeGeneration` `objects3D` `chat` `voipCall` `voipCall` `phoneCall` `removableStorage` `userAccountInformation` `sharedUserCertificates` `blockedChatMessages` `appointments` `contacts` `musicLibrary` `videosLibrary` `picturesLibrary` `enterpriseAuthentication` `phoneCallHistoryPublic` `spatialPerception` `userNotificationListener` `remoteSystem` `backgroundMediaPlayback` `offlineMapsManagement` `userDataTasks` `graphicsCapture` `globalMediaControl` `gazeInput` `systemManagement` `lowLevelDevices` `documentsLibrary` `accessoryManager` `allowElevation` `location` `microphone` `webcam` `radios` | `internetClient,location,microphone,webcam` (string) | No |

## :label: Windows Store

To upload the MSIX file to Windows Store the configuration values `publisher_display_name`, `identity_name`, `msix_version`, `publisher` must be valid.

For more information, please see this tutorial: [How to publish your MSIX package to the Microsoft Store?](https://www.advancedinstaller.com/msix-publish-microsoft-store.html)

## :gear: Command-Line Arguments

If you using Continuous Deployment (CD) you can set the some configurations values via the command-line arguments.

available arguments:
- package version: `--version` (must be in the format: **0.0.0.0**)
- certificate path: `--certificate` or `-c`
- certificate password: `--password` or `-p`

example:
```bash
flutter pub run msix:create --version 1.0.0.1 --certificate <your certificate path> --password <your certificate password>
```

## :question: Signing Error 
If you getting certificate sign error `"Error: Store::ImportCertObject() failed."` or `"Error: SignerSign() failed."`
1. Check the configuration values of `certificate_path`, `certificate_password` and `publisher`
2. Try use Marcel`s solution: [#17](https://github.com/YehudaKremer/msix/issues/17 "#17")
------------
package tags: `msi` `windows` `win10` `windows10` `windows store` `windows installer` `windows packaging` `appx` `AppxManifest` `SignTool` `MakeAppx`
