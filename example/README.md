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

##### Note: The main app version will be used as a basis for the MSIX version (`1.3.2` to `1.3.2.0`)

<br />

###### Without signing

```yaml
msix_config:
  publisher: CN=PublisherName, O=Msix Testing... # required
  sign_msix: false
```

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

#### Signing With Installed Certificate Using SignTool

###### By Subject:

```yaml
msix_config:
  display_name: Flutter App
  msix_version: 1.0.0.0
  signtool_options: /v /debug /sm /fd sha256 /n "Msix Testing" /tr http://timestamp.digicert.com
```

###### By Issuer:

```yaml
msix_config:
  display_name: Flutter App
  msix_version: 1.0.0.0
  signtool_options: /fd sha256 /i "Msix Testing" /tr http://timestamp.digicert.com
```

###### By Thumbprint:

```yaml
msix_config:
  display_name: Flutter App
  msix_version: 1.0.0.0
  signtool_options: /fd sha256 /sha1 028bc9922d198ee83d776aa19cb8e82897691e0c /tr http://timestamp.digicert.com
```

###### By .crt File:

```yaml
msix_config:
  display_name: Flutter App
  msix_version: 1.0.0.0
  signtool_options: /fd SHA256 /f "<path_to>\test_certificate.crt"
```

###### By .pfx File:

```yaml
msix_config:
  display_name: Flutter App
  msix_version: 1.0.0.0
  signtool_options: /fd SHA256 /f "<path_to>\test_certificate.pfx" /p 1234
```
