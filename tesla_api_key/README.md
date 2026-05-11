# Tesla Fleet Public Key

Serves the Tesla Fleet public key required by the [Home Assistant Tesla Fleet integration](https://www.home-assistant.io/integrations/tesla_fleet).

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

