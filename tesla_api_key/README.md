# Tesla Fleet Public Key

Serves the Tesla Fleet public key required by the [Home Assistant Tesla Fleet integration](https://www.home-assistant.io/integrations/tesla_fleet).

The add-on image is built by GitHub Actions and published to GitHub Container Registry:

```text
ghcr.io/dnviti/tesla-api-key-homeassistant:1.0.5
```

The add-on does not open a host port by default. Use the repository's custom integration for the no-port setup that serves the key from Home Assistant Core's own URL.

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
homeassistant_url: http://homeassistant.local.hass.io:8123
```

If you choose the optional add-on path, manually expose/map its port and put it behind a valid HTTPS domain before completing Tesla Fleet setup.

Use the add-on configuration card's three-dot menu and select **Edit in YAML** before pasting the key. Folded YAML (`key_pem: >-`) and wrapped base64 are normalized back to valid PEM format at startup.

Nginx serves the Tesla key path directly and proxies all other requests to `homeassistant_url`, but only after you manually expose/map the add-on port and route public traffic to it.
