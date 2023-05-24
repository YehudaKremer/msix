## MSIX Version

The MSIX installer version number is used to determine updates to the app and consists of 4 numbers (`1.0.0.0`). 
Using the build number as the fourth number is not allowed in the windows store ([see the important banner in the microsoft documentation](https://learn.microsoft.com/en-us/windows/apps/publish/publish-your-app/package-version-numbering?pivots=store-installer-msix#version-numbering-for-windows10-packages)).
#### The version is determined by the first available option:

1. Command line `--version` flag
2. In `pubspec.yaml`, under the `msix_config` node, the `msix_version` value
3. Using the `version` field in `pubspec.yaml`.
   - The Pubspec version uses [semver], which is of the form `major.minor.patch-prerelease+build`
   - `msix` will use the `major.minor.patch.0`.
   - All `prerelease` info is discarded
   - NOTE: An additional flag can be enabled in the config called `version_with_build_number`. [See below for more info](#the-version_with_build_number-flag) 
4. Fallback to `1.0.0.0`

By default, if you have a valid `version` in your `pubspec.yaml` file, that will form the basis for your MSIX installer version.

#### The `version_with_build_number` configuration flag:
If true, the `build`number from the `pubspec.yaml` will be appended to `patch`: `major.minor0patch.build.0`.

Example: 
- Given the following value for the `version` flag: `1.2.13+35`
- The resulting value, will be `1.2013.35.0`.

Config Example:
```yaml
name: myProject
version: 1.2.3+4
msix_config:
  # Make sure that there is no msix_version key in this config, otherwise version_with_build_number will not work
  version_with_build_number: true
```

Caveats:
- If another version is given via the command line (1.) or the via the `msix_version` in the `pubspec.yaml`, then the normal version tag will not be used.
- The maximum allowed number in the version [in the windows store is 65535](https://learn.microsoft.com/en-us/windows/apps/publish/publish-your-app/package-version-numbering?pivots=store-installer-msix#version-numbering-for-windows10-packages). This imposes certain constraints on each of the four numbers. The table below shows these constraints which are checked in the code. If one of these constraints are not met, the version number defaults to `1.0.0.0`.

| part   | minimal value | maximal value (inclusive) |
| ------ | ------------- | ------------------------- |
| major  | 0             | 65535                     |
| minor  | 0             | 654                       |
| patch  | 0             | 99                        |
| build  | 0             | 65535                     |



#### More info:
[semver] : https://semver.org/
