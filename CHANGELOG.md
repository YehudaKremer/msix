# Changelog

## 3.16.8

- update VCLibs files [#273](https://github.com/YehudaKremer/msix/pull/273)

## 3.16.7

- fix [#250](https://github.com/YehudaKremer/msix/issues/250)

## 3.16.6

- update MaxVersionTested

## 3.16.4

- permanent fix for [#235](https://github.com/YehudaKremer/msix/issues/235)

## 3.16.3

- temporary fix for [#235](https://github.com/YehudaKremer/msix/issues/235)

## 3.16.2

- fix [#232](https://github.com/YehudaKremer/msix/issues/232)

## 3.16.1

- fix [#178](https://github.com/YehudaKremer/msix/issues/178)
- update `MaxVersionTested` value

## 3.16.0

- add Context menu extension ([#208](https://github.com/YehudaKremer/msix/issues/208))

## 3.15.1

- fix [#211](https://github.com/YehudaKremer/msix/issues/211)

## 3.15.0

- add support for `arm64` build folder layout [#205](https://github.com/YehudaKremer/msix/issues/205)

### Breaking Changes

- `architecture` config field is now accepts `x64` or `arm64` (instead of `x86`)

## 3.14.2

- fix [#203](https://github.com/YehudaKremer/msix/issues/203)

## 3.14.0

- fix [#201](https://github.com/YehudaKremer/msix/issues/201): use correct flutter executable (support [fvm](https://fvm.app/))

## 3.13.3

- fix [#181](https://github.com/YehudaKremer/msix/issues/181)

## 3.13.2

- get certificate publisher if using test certificate (fix [#159](https://github.com/YehudaKremer/msix/issues/159))

## 3.13.1

- fix [#197](https://github.com/YehudaKremer/msix/issues/197): locate msix assets path from script file directory

## 3.13.0

- fix [#139](https://github.com/YehudaKremer/msix/issues/139): remove Flutter SDK constraints

## 3.12.3

- fix [#196](https://github.com/YehudaKremer/msix/issues/196)

## 3.12.2

- brings back Isolates for faster icons generation (after remove them in `3.12.0`)

## 3.12.1

- fix [#175](https://github.com/YehudaKremer/msix/issues/175): `app_installer -> publish_folder_path` config field is now support absolute-path

## 3.12.0

- fix [#193](https://github.com/YehudaKremer/msix/issues/193): remove `isolate` to support Flutter version >=3.10.0 (Dart 3v)

## 3.11.1

- fix [#159](https://github.com/YehudaKremer/msix/issues/159)

## 3.11.0

- add `os_min_version` configuration

## 3.10.1

- add [startup task](https://github.com/YehudaKremer/msix/blob/main/doc/startup_task_configuration.md) configuration

## 3.9.2

- update `cli_util` dependency to `0.4.0`

## 3.9.1

- remove padding from generated icons (fix [#179](https://github.com/YehudaKremer/msix/issues/179))
- fix pixelated icons

## 3.8.4

- add `screenshot` and `issue_tracker` to the package metadata

## 3.8.2

- fix [#180](https://github.com/YehudaKremer/msix/issues/180)

## 3.8.1

- fix [#178](https://github.com/YehudaKremer/msix/issues/178)

## 3.8.0

- update the [Image](https://pub.dev/packages/image) dependency package to version >=4.0.0
- added `windows_build_args` config option, see "Build configuration" documentation table for more details

## 3.7.0

- add full support for [SignTool](https://learn.microsoft.com/en-us/dotnet/framework/tools/signtool-exe) usage (addressing [#155](https://github.com/YehudaKremer/msix/pull/155#issue-1421291620)), see [examples page](https://github.com/YehudaKremer/msix/tree/main/example)

## 3.6.6

- replacing cli_dialog package with console package to solve transitive dependencies [https://github.com/timsneath/dart_console/issues/54](https://github.com/timsneath/dart_console/issues/54)

## 3.6.3

- fix [#134](https://github.com/YehudaKremer/msix/issues/134)

## 3.6.2

- fix [#129](https://github.com/YehudaKremer/msix/issues/129)

## 3.6.1

- added validation on field `publisher` that required when settings `sign_msix: false` ([#126](https://github.com/YehudaKremer/msix/issues/126))

## 3.6.0

- added [apps for websites](https://docs.microsoft.com/en-us/windows/uwp/launch-resume/web-to-app-linking) ([#125](https://github.com/YehudaKremer/msix/pull/125))

## 3.5.1

- added two new command `msix:build` and `msix:pack` for [unsupported features](https://github.com/YehudaKremer/msix#heavy_exclamation_mark-unsupported-features) ([#120](https://github.com/YehudaKremer/msix/issues/120))
- logs change: from single log `creating msix installer...` we have now two logs: `building msix files...` and `packing msix files...`

## 3.4.1

- fix [#119](https://github.com/YehudaKremer/msix/issues/119)

## 3.4.0

- enable multiple protocols activision in `protocol_activation` [#114](https://github.com/YehudaKremer/msix/issues/114)

### Breaking Changes

- `add_execution_alias` is change to `execution_alias` and its value is string (instead of boolean) [116#issuecomment-1067802660](https://github.com/YehudaKremer/msix/issues/116#issuecomment-1067802660)

## 3.3.2

- fix default capabilities

## 3.3.1

- no longer update the window title and company name in the main.cpp file, to avoid errors when the user has already updated it.

## 3.3.0

- Add `enable-at-startup` configuration and flag, see [Configure your app to start at log-in](https://blogs.windows.com/windowsdeveloper/2017/08/01/configure-app-start-log/).

## 3.2.0

- Automatically use the Pubspec `version` tag by default. To use auto-versioning, remove any `msix_version` fields or command line options.

## 3.1.6

### Breaking Changes

- remove `with-test-certificate-installer` cli flag

## 3.1.4

- add `sign_msix` configuration see: [#105](https://github.com/YehudaKremer/msix/issues/105)

## 3.1.3

- fix bug [#104](https://github.com/YehudaKremer/msix/issues/104)

## 3.1.2

- add `trim-logo` configuration option

## 3.1.0

- fix bugs related to [PR](https://github.com/YehudaKremer/msix/pull/101)

### Breaking Changes

- app installer configurations: `automatic_background_task`,`update_blocks_activation` and `show_prompt` are now `false` by default

## 3.0.1

- removed powershell file

## 3.0.0

- add `publish` command and configurations, for side loading publish (outside the microsoft store)
- user asked (cli dialog) if he want to **increment version number** (if needed)
- user asked (cli dialog) if he want to install the test certificate
- add [toast notifications](https://github.com/YehudaKremer/msix/issues/94) configuration
- `msix:create` is includes the `flutter build windows` command, unless use the argument: `--build-windows false`
- add `--with-test-certificate-installer` flag that copy test-certificate installer program (.exe), see configuration table
- logs are now minimal by default, use the `-v` argument to print extended logs (useful for debugging and bug reporting)
- code refactoring

### Breaking Changes

- remove `debug-signing` (not printing useful info)
- change `dont-install-certificate` to `install-certificate` with default of true
- setting msix-version via Command-line argument is allow only with `--version 1.0.0.1` and not with `-v` (use now for extended logs)

## 2.8.18

- fix [#91](https://github.com/YehudaKremer/msix/issues/91)

## 2.8.16

- fix [#90](https://github.com/YehudaKremer/msix/issues/90)

## 2.8.15

- fix [#74](https://github.com/YehudaKremer/msix/issues/74)

## 2.8.13

- fix log bug

## 2.8.11

- add `--debug --release` flags and `debug` configurations

## 2.8.10

### Breaking Changes

- remove `assets_directory_path` (we can use the formal [loading-assets](https://docs.flutter.dev/development/ui/assets-and-images#loading-assets) instead)

## 2.8.5

- fix bug [#79](https://github.com/YehudaKremer/msix/issues/79)

## 2.8.4

- package code refactoring, without any functionality changes

## 2.8.2

- fix [#73](https://github.com/YehudaKremer/msix/issues/73)

## 2.8.0

- switch icons generator from **.NET** third party program to **dart** code (using [`image`](https://pub.dev/packages/image) package)
- `logo_path` is now support multiple [image formats](https://github.com/brendan-duncan/image#supported-image-formats), fix blurry icons and trim transparent padding (fix [#71](https://github.com/YehudaKremer/msix/issues/70))
- breaking change: .svg format not supported (for now)

## 2.7.3

- fix bug [#70](https://github.com/YehudaKremer/msix/issues/70)

## 2.7.2

- fix [#69](https://github.com/YehudaKremer/msix/issues/69#issuecomment-1001878037)

## 2.7.1

- generate set of [optimized icons](https://docs.microsoft.com/en-us/windows/apps/design/style/app-icons-and-logos) (like [VS assets tool](https://docs.microsoft.com/en-us/windows/apps/design/style/app-icons-and-logos#generating-all-assets-at-once)) base on the logo image (`logo_path`), support only **.png**, **.svg** formats
- also support SVG format for the logo image

### Breaking Changes

**deleted configurations options:**

- vs_generated_images_folder_path (from this version those icons generate automatically)
- icons_background_color (ignore on windows [version 20H2](https://docs.microsoft.com/en-us/windows/whats-new/whats-new-windows-10-version-20h2#windows-shell) and above)
- tile_icon_path (generate automatically)
- start_menu_icon_path (generate automatically)

## 2.6.7

- update documentation: `icons_background_color` is ignore on windows [version 20H2](https://docs.microsoft.com/en-us/windows/whats-new/whats-new-windows-10-version-20h2#windows-shell) and above
- `icons_background_color` can be "color name" too

## 2.6.6

- fix bug [#68](https://github.com/YehudaKremer/msix/issues/68)
- log style improvements

## 2.6.5

- fix bug [#67](https://github.com/YehudaKremer/msix/issues/67)

## 2.6.4

- added add_execution_alias configuration field

## 2.6.3

- update example documentation [#65](https://github.com/YehudaKremer/msix/issues/65)

## 2.6.2

- fix bug [#61](https://github.com/YehudaKremer/msix/issues/61)

## 2.6.1

- added feature [#47](https://github.com/YehudaKremer/msix/issues/47) and [#57](https://github.com/YehudaKremer/msix/issues/57)
- fix bug [#51](https://github.com/YehudaKremer/msix/issues/51) and added error logs
- rewrite CLI arguments (see updated documentation)

## 2.5.5

- fix bug "Certificate Details can't be read" - https://github.com/YehudaKremer/msix/issues/60

## 2.5.4

- certificate "publisher" is now recognize automatic
- "publisher" configuration field is needed only for publish to windows store
- added new flag/configuration-field "dontInstallCert"

## 2.4.2

- documentation update

## 2.4.0

- use the "certutil" cmd to install automatic the test certificate
- documentation update

## 2.3.1

- fix error when the app have no capabilities

## 2.3.0

- added support for assets files for FFI library (documentation update)

## 2.2.3

- added support for all the capabilities types (documentation update)
- Update dependencies versions

## 2.1.3

- added support for association to multiple file extensions - https://github.com/YehudaKremer/msix/pull/46

## 2.1.2

- update terminal logs

## 2.1.1

- add `--store` flag see - https://github.com/YehudaKremer/msix/issues/42
- add BadgeLogo icons

## 2.0.0

- see - https://github.com/YehudaKremer/msix/issues/37

## 1.0.6

- add `--debug` flag to debug signing issues, fixed missing argument `/f' for not '.pfx' certificates

## 1.0.5

- add terminal explanation about the test certificate installation

## 1.0.4

- support multiple languages - https://github.com/YehudaKremer/msix/issues/35

## 1.0.3

- fix: command-line arguments not taken into account in case there is no configuration at all

## 1.0.2

- command-Line Arguments extensions - https://github.com/YehudaKremer/msix/pull/33
- fix: Incorrect description for certificate_password - https://github.com/YehudaKremer/msix/issues/34

## 1.0.0

- null safety
- code refactoring
- move to sync code to increase stability
- fix: Wrong executable selection - https://github.com/YehudaKremer/msix/pull/32

## 0.1.19

- fix: Sometimes VC libraries are not copied - https://github.com/YehudaKremer/msix/issues/30

## 0.1.15

- fix invalid character in the app name - https://github.com/YehudaKremer/msix/issues/25

## 0.1.14

- using Dart Package Configuration File v2.0
- add decode for packages path - https://github.com/YehudaKremer/msix/issues/21

## 0.1.13

- sign with time stamp

## 0.1.12

- add support for icons generated by Visual Studio

## 0.1.8

- fix bug: can't get pfx password from config - https://github.com/YehudaKremer/msix/issues/16

## 0.1.10

- delete old code and documentation editing

## 0.1.8

- allow setting certificate password via the command-line arguments

## 0.1.5

- backward compatibility for configuration properties

## 0.1.4

- backward compatibility for configuration properties

## 0.1.2

- can create an unsigned installation file for upload to the store
- breaking config change: "publisher_name" is now: "publisher_display_name"
- breaking config change: "certificate_subject" is now: "publisher"

## 0.1.1

- bug fix: automatically find the name of the exe file

## 0.1.0

- add capabilities
- support all tiles sizes
- bug fixes

## 0.0.10

- code refactoring

## 0.0.9

- fix "create doesn't handle package_names"

## 0.0.8

- initial version.
