# Tesla Fleet Public Key

This add-on hosts the public key file needed by the [Home Assistant Tesla Fleet integration](https://www.home-assistant.io/integrations/tesla_fleet).

Paste the public key shown by the Tesla Fleet setup flow into the add-on configuration:

```yaml
key_pem: |
  -----BEGIN PUBLIC KEY-----
  paste-the-public-key-shown-by-home-assistant-here
  -----END PUBLIC KEY-----
```

After starting the add-on, verify the endpoint through the HTTPS domain you configured for Tesla:

```text
https://yourdomain.com/.well-known/appspecific/com.tesla.3p.public-key.pem
```

Tesla requires this URL to use a valid SSL certificate.

