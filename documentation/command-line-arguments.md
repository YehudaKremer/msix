## :gear: Command-Line Arguments

You can use this tool with command-line arguments instead of `pubspec.yaml` or combine them.

###### Example:
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
