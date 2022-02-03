# Changelog

## 3.0.0

- added `msix:buildAndCreate` command
- added new configuration options: `update-company-name`

### Breaking Changes

- remove `debug-signing` (not printing useful info)
- change `dont-install-certificate` to `install-certificate` with default of true

## 2.8.8

### Breaking Changes

- remove `assets_directory_path` (we can use the formal [loading-assets](https://docs.flutter.dev/development/ui/assets-and-images#loading-assets) instead)

## 2.8.5

- fix bug #79

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
