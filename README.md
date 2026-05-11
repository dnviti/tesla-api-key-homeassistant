# Tesla API Key Home Assistant

Home Assistant app/add-on repository for serving the Tesla Fleet public key at the path required by the Tesla Fleet integration:

```text
/.well-known/appspecific/com.tesla.3p.public-key.pem
```

Reference documentation:

- [Home Assistant Tesla Fleet integration](https://www.home-assistant.io/integrations/tesla_fleet)
- [Home Assistant app repository documentation](https://developers.home-assistant.io/docs/apps/repository/)
- [Home Assistant app configuration documentation](https://developers.home-assistant.io/docs/apps/configuration/)

## Install

Use the My Home Assistant button or add the repository manually.

[![Open your Home Assistant instance and add this repository](https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgithub.com%2Fdnviti%2Ftesla-api-key-homeassistant)

Manual steps:

1. Open Home Assistant.
2. Go to **Settings > Apps** or **Settings > Add-ons**, depending on your Home Assistant version.
3. Open the app/add-on store menu and add this repository URL:

   ```text
   https://github.com/dnviti/tesla-api-key-homeassistant
   ```

4. Install **Tesla Fleet Public Key**.

## Configure

During Tesla Fleet setup, Home Assistant asks you to host the public key shown in the setup flow. Paste that public key into this add-on configuration as `key_pem`.

Use the configuration YAML editor/textarea:

```yaml
key_pem: |
  -----BEGIN PUBLIC KEY-----
  paste-the-public-key-shown-by-home-assistant-here
  -----END PUBLIC KEY-----
```

This should be the public key shown by the Tesla Fleet integration, not the private `tesla_fleet.key` file.

The add-on exposes HTTP port `80` from the container. By default Home Assistant maps it to host port `8085`, so the local endpoint is:

```text
http://homeassistant.local:8085/.well-known/appspecific/com.tesla.3p.public-key.pem
```

## Public HTTPS Requirement

Tesla Fleet requires the public key to be reachable at a valid HTTPS URL on the domain you enter during integration setup:

```text
https://yourdomain.com/.well-known/appspecific/com.tesla.3p.public-key.pem
```

Put this add-on behind your existing HTTPS reverse proxy, router, tunnel, or another Home Assistant proxy setup so that the public HTTPS URL forwards to this add-on's HTTP port.

The domain must match the Tesla Fleet setup requirements in the [official Tesla Fleet integration documentation](https://www.home-assistant.io/integrations/tesla_fleet), including the developer application origin and the valid SSL certificate requirement.

## Tesla Fleet Setup Flow

Follow the [Home Assistant Tesla Fleet documentation](https://www.home-assistant.io/integrations/tesla_fleet):

1. Create a Tesla Developer Application.
2. Configure the OAuth redirect URI and allowed origin URL.
3. Add Tesla Fleet in Home Assistant.
4. Paste the public key from the setup flow into this add-on's `key_pem` configuration.
5. Start or restart this add-on.
6. Verify the public key URL returns the PEM text.
7. Continue Tesla Fleet setup and install the virtual key for each supported vehicle.

For command signing, the Tesla Fleet documentation also notes that vehicles requiring signed commands must have the public key installed by opening:

```text
https://tesla.com/_ak/YOUR_DOMAIN
```

## Local Development

For local testing outside Home Assistant, create `local/options.json`:

```json
{
  "key_pem": "-----BEGIN PUBLIC KEY-----\n...\n-----END PUBLIC KEY-----"
}
```

Then run:

```sh
docker compose up --build
```

The key should be available at:

```text
http://localhost:8085/.well-known/appspecific/com.tesla.3p.public-key.pem
```

