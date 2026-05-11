# Tesla Fleet Public Key

This add-on hosts the public key file needed by the [Home Assistant Tesla Fleet integration](https://www.home-assistant.io/integrations/tesla_fleet).

The add-on image is built by GitHub Actions and published to GitHub Container Registry as `ghcr.io/dnviti/tesla-api-key-homeassistant`.

Paste the public key shown by the Tesla Fleet setup flow into the add-on configuration code editor:

```yaml
key_pem: |
  -----BEGIN PUBLIC KEY-----
  paste-the-public-key-shown-by-home-assistant-here
  -----END PUBLIC KEY-----
```

The add-on intentionally uses Home Assistant's raw configuration/code editor instead of a single-line text field. Folded YAML (`key_pem: >-`) and wrapped base64 are normalized back to valid PEM format at startup.

After starting the add-on, verify the endpoint through the HTTPS domain you configured for Tesla:

```text
https://yourdomain.com/.well-known/appspecific/com.tesla.3p.public-key.pem
```

Tesla requires this URL to use a valid SSL certificate.
