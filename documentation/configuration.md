## :mag: Configuration (Optional)
This tool come with default configuration (test values), you can configure it to suit your needs.

###### Example:
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
|  vs_generated_images_folder_path | Visual Studio can generate for you optimized icons (logo/tile and more) [see Thomas's explanation](https://github.com/YehudaKremer/msix/issues/19). This is an alternative for `logo_path`, `start_menu_icon_path`, `tile_icon_path`. sample: `C:\<PathToFolder>\icons` |  | No |
|  icons_background_color | Specifies the background color of the app icons, can be `transparent` or some color like: `'#ffffff'` | transparent (string) | No |
|  languages | Declares a language for resources contained in the package. sample: `en-us, ja-jp` | en-us (string) | No |
|  architecture | Describes the architecture of the code contained in the package, one of: x86, x64, arm,, neutral | x64 (string) | No |
|  signtool_options | Signtool using this syntax: [command] [options] [file_name], you can provide here the `[options]` part, see full documentation here: https://docs.microsoft.com/en-us/dotnet/framework/tools/signtool-exe **this option is overwriting the fields: `certificate_path`, `certificate_password`** | /v /fd SHA256 /f C:/Users/me/Desktop/my.cer (string) | No |
|  capabilities | Declares the access to protected user resources that the package requires. availables capabilities: `internetClient` `internetClientServer` `privateNetworkClientServer` `allJoyn` `codeGeneration` `objects3D` `chat` `voipCall` `voipCall` `phoneCall` `removableStorage` `userAccountInformation` `sharedUserCertificates` `blockedChatMessages` `appointments` `contacts` `musicLibrary` `videosLibrary` `picturesLibrary` `enterpriseAuthentication` `phoneCallHistoryPublic` `spatialPerception` `userNotificationListener` `remoteSystem` `backgroundMediaPlayback` `offlineMapsManagement` `userDataTasks` `graphicsCapture` `globalMediaControl` `gazeInput` `systemManagement` `lowLevelDevices` `documentsLibrary` `accessoryManager` `allowElevation` `location` `microphone` `webcam` `radios` | `internetClient,location,microphone,webcam` (string) | No |
|  store | If the msix file is intended for publish in Windows Store | false (boolean) | require if uploading to windows store |