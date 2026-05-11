# Tesla Fleet Public Key

This add-on hosts the public key file needed by the [Home Assistant Tesla Fleet integration](https://www.home-assistant.io/integrations/tesla_fleet).

The add-on image is built by GitHub Actions and published to GitHub Container Registry as `ghcr.io/dnviti/tesla-api-key-homeassistant`.

The add-on does not open a host port by default. Use the repository's custom integration for the no-port setup that serves the key from Home Assistant Core's own URL.

Paste the public key shown by the Tesla Fleet setup flow into the add-on configuration YAML editor. In the configuration card, open the three-dot menu and select **Edit in YAML** before pasting:

```yaml
key_pem: |
  -----BEGIN PUBLIC KEY-----
  paste-the-public-key-shown-by-home-assistant-here
  -----END PUBLIC KEY-----
homeassistant_url: http://homeassistant.local.hass.io:8123
```

The documented Home Assistant add-on schema types do not provide a textarea control, and `schema: false` does not reliably persist add-on options. Use **Edit in YAML** instead of the single-line form field. Folded YAML (`key_pem: >-`) and wrapped base64 are normalized back to valid PEM format at startup.

Nginx serves `/.well-known/appspecific/com.tesla.3p.public-key.pem` directly and proxies every other request to `homeassistant_url`, but only after you manually expose/map the add-on port. To use the original public Home Assistant URL without opening ports, use the custom integration instead.

Because this add-on becomes a reverse proxy for Home Assistant, Home Assistant Core may require `use_x_forwarded_for` and `trusted_proxies` in `configuration.yaml`. If Home Assistant logs a reverse proxy or trusted proxy error, add the proxy IP shown in that log, following the [Home Assistant HTTP integration documentation](https://www.home-assistant.io/integrations/http/#reverse-proxies).

After starting the add-on, verify the endpoint through the HTTPS domain you configured for Tesla:

```text
https://yourdomain.com/.well-known/appspecific/com.tesla.3p.public-key.pem
```

Tesla requires this URL to use a valid SSL certificate.
