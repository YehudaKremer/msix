### Configurations Examples And Use Cases

###### Basic:

```yaml
msix_config:
  display_name: Flutter App
  msix_version: 1.0.0.0
  logo_path: C:\path\to\logo.png
```

###### For Publish To Windows Store:

```yaml
msix_config:
  display_name: Flutter App
  publisher_display_name: Company Name
  identity_name: 48434MySoftware.MyFlutterApp 
  publisher: CN=BF212345-5644-46DF-8668-012044C1B138
  msix_version: 1.0.1.0
  store: true
```

###### With Your Own Certificate:

```yaml
msix_config:
  display_name: Flutter App
  msix_version: 1.0.0.0
  certificate_path: C:\path\to\myCertificate.pfx
  certificate_password: 1234
```

###### For CI/CD:

```yaml
name: flutter_app
version: 1.3.2

# ...

msix_config:
  display_name: Flutter App
  install_certificate: false
```
Note: The main app version will be used as a basis for the MSIX version (`1.3.2` to `1.3.2.0`)

###### With Metadata:

```yaml
msix_config:
  display_name: Flutter App
  publisher_display_name: Company Name
  identity_name: company.suite.flutterapp
  msix_version: 1.0.0.0
  languages: en-us, de-de
  capabilities: "internetClient,location,microphone,webcam"
```
