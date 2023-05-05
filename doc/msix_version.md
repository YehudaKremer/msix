## Msix Version

The MSIX installer version number is used to determine updates to the app and consists of 4 numbers (`1.0.0.0`).
Using the build number as the fourth number is not allowed on the windows store ([see the important banner in the microsoft documentation](https://learn.microsoft.com/en-us/windows/apps/publish/publish-your-app/package-version-numbering?pivots=store-installer-msix#version-numbering-for-windows10-packages)).
#### The version is determined by the first available option:

1. Command line `--version` flag
2. In `pubspec.yaml`, under the `msix_config` node, the `msix_version` value
3. Using the `version` field in `pubspec.yaml`.
   - The Pubspec version uses [semver], which is of the form `major.minor.patch-prerelease+build`
   - `msix` will use the `major.minor.patch.0`.
   - All prerelease info is discarded
   - NOTE: An additional flag can be enabled in the config called `append_build_number_to_patch`. [See below for more info](#the-append_build_number_to_patch-flag) 
4. Fallback to `1.0.0.0`

By default, if you have a valid `version` in your `pubspec.yaml` file, that will form the basis for your MSIX installer version.

#### The `append_build_number_to_patch` configuration flag:
If true, the `build`number from the `pubspec.yaml` will be appended to `patch`: `major.minor.patchbuild.0`.

Example: 
- Given the following value for the `version` flag: `1.2.13+35`
- The resulting value, will be `1.2.1335.0`.

Config Example:
```yaml
name: myProject
version:1.2.3+4
msix_config:
  # Make sure that there is no msix_version key in this config, otherwise append_build_number_to_patch will not work
  append_build_number_to_patch: true
```

Caveats:
- If another version is given via the commandline (1.) or the via the `msix_version` in the `pubspec.yaml`, then the normal version tag will not be used.
- The maximum allowed number in the version [in the windows store is 65535](https://learn.microsoft.com/en-us/windows/apps/publish/publish-your-app/package-version-numbering?pivots=store-installer-msix#version-numbering-for-windows10-packages). If the combined value of `build` and `patch` exceed this value, the `build` number will not be appended.

To make it easy, the `build` and `patch` number should be below one of these combinations for the `build`number to be appended to the `patch`number: 
| `patch` | `build` |
| ------- | ------- |
| 6       | 5535    |
| 65      | 535     |
| 655     | 35      |
| 6553    | 5       |



#### More info:
[semver] : https://semver.org/
