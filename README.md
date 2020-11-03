![Flutter Community: flutter_launcher_icons](https://news.thewindowsclub.com/wp-content/uploads/2018/07/MSIX.jpg)

# Msix
A command-line tool that create Msix installer for your flutter windows-build files.
## Install
Add `msix: ` under `dependencies:`
## :package: Create Msix
Run `flutter build windows` then run: **`flutter pub run msix:create`**
## :gear:Configuration (Optional)
Add `msix_config:` configuration at the end of your `pubspec.yaml` file:
```yaml
#msix_config:
  #display_name: MyApp
  #publisher_name: MyName
  #identity_name: MyCompany.MySuite.MyApp
  #msix_version: 1.0.0.0
  #certificate_path: C:/<PathToCertificate>/<MyCertificate.pfx>
  #certificate_password: 1234 (require if using .pfx certificate)
  #certificate_subject: CN=MyName
  #logo_path: C:\<PathToIcon>\<Logo.png>
  #start_menu_icon_path: C:\<PathToIcon>\<Icon.png>
  #tile_icon_path: C:\<PathToIcon>\<Icon.png>
  #icons_background_color: ffffff
  #architecture: x64
```
tags: `msi` `windows` `win10` `windows10` `windows installer` `windows packaging` `appx` `AppxManifest` `SignTool` `MakeAppx`