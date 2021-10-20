### Configurations Examples

###### Basic 
```yaml
msix_config:
  display_name: MyAppName
  publisher_display_name: MyName
  identity_name: MyCompany.MySuite.MyApp
  msix_version: 1.0.0.0
  logo_path: C:\<PathToIcon>\<Logo.png>
```

###### With Capabilities And Generated Icons
```yaml
msix_config:
  display_name: MyAppName
  publisher_display_name: MyName
  identity_name: MyCompany.MySuite.MyApp
  msix_version: 2.0.2.1
  vs_generated_images_folder_path: C:\<PathToFolder>\icons
  capabilities: 'internetClient,location,microphone,webcam'
```

###### For Publish To Windows Store
```yaml
msix_config:
  display_name: MyAppName
  publisher_display_name: MyName
  identity_name: MyCompany.MySuite.MyApp
  msix_version: 1.0.0.0
  logo_path: C:\<PathToIcon>\<Logo.png>
  store: true
```

###### With Your Own Certificate
```yaml
msix_config:
  display_name: MyAppName
  publisher_display_name: MyName
  identity_name: MyCompany.MySuite.MyApp
  msix_version: 1.0.0.0
  logo_path: C:\<PathToIcon>\<Logo.png>
  certificate_path: C:\<PathToCertificate>\<MyCertificate.pfx>
  certificate_password: 1234
  publisher: CN=My Company, O=My Company, L=Berlin, S=Berlin, C=DE
```