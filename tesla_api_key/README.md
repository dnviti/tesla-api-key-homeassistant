# Tesla Fleet Public Key

Serves the Tesla Fleet public key required by the [Home Assistant Tesla Fleet integration](https://www.home-assistant.io/integrations/tesla_fleet).

The add-on image is built by GitHub Actions and published to GitHub Container Registry:

```text
ghcr.io/dnviti/tesla-api-key-homeassistant:1.0.3
```

The add-on writes the configured `key_pem` value to:

```text
/.well-known/appspecific/com.tesla.3p.public-key.pem
```

Configure it with:

```yaml
key_pem: |
  -----BEGIN PUBLIC KEY-----
  paste-the-public-key-shown-by-home-assistant-here
  -----END PUBLIC KEY-----
```

Expose this add-on through a valid HTTPS domain before completing Tesla Fleet setup.

Use the add-on configuration card's three-dot menu and select **Edit in YAML** before pasting the key. Folded YAML (`key_pem: >-`) and wrapped base64 are normalized back to valid PEM format at startup.
