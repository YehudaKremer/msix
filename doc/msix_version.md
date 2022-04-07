## Msix Version

The MSIX installer version number is used to determine updates to the app and consists of 4 numbers (`1.0.0.0`).

#### The version is determined by the first available option:

1. Command line `--version` flag
2. In `pubspec.yaml`, under the `msix_config` node, the `msix_version` value
3. Using the `version` field in `pubspec.yaml`.
   - The Pubspec version uses [semver], which is of the form `major.minor.patch-prerelease+build`
   - `msix` will use the `major.minor.patch` and append a `0` for the MSIX version
   - All prerelease and build info is discarded
4. Fallback to `1.0.0.0`

By default, if you have a valid `version` in your `pubspec.yaml` file, that will form the basis for your MSIX installer version.

[semver]: https://semver.org/