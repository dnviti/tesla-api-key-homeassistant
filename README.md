# Tesla API Key Home Assistant

Home Assistant custom integration for serving the Tesla Fleet public key from the existing Home Assistant URL, with no extra opened ports.

```text
/.well-known/appspecific/com.tesla.3p.public-key.pem
```

Reference documentation:

- [Home Assistant Tesla Fleet integration](https://www.home-assistant.io/integrations/tesla_fleet)
- [Home Assistant config flow documentation](https://developers.home-assistant.io/docs/core/integration/config_flow/)
- [Home Assistant app repository documentation](https://developers.home-assistant.io/docs/apps/repository/)
- [Home Assistant app configuration documentation](https://developers.home-assistant.io/docs/apps/configuration/)

## Recommended: No-Port Integration

Install the custom integration when you want this to work through whatever external Home Assistant URL you already use. It registers the Tesla key route inside Home Assistant Core, so no add-on port, reverse proxy target change, or extra firewall rule is required.

The public key will be available at:

```text
https://YOUR_EXISTING_HOME_ASSISTANT_URL/.well-known/appspecific/com.tesla.3p.public-key.pem
```

### HACS Install

1. Open HACS.
2. Add this repository as a custom repository of type **Integration**:

   ```text
   https://github.com/dnviti/tesla-api-key-homeassistant
   ```

3. Download **Tesla Fleet Public Key**.
4. Restart Home Assistant.
5. Go to **Settings > Devices & services > Add integration**.
6. Add **Tesla Fleet Public Key** and paste the public key shown by the Tesla Fleet setup flow.

### Manual Install

1. Copy this folder into your Home Assistant config directory:

   ```text
   custom_components/tesla_fleet_public_key
   ```

2. Restart Home Assistant.
3. Go to **Settings > Devices & services > Add integration**.
4. Add **Tesla Fleet Public Key** and paste the public key shown by the Tesla Fleet setup flow.

The setup form uses a multiline textarea and normalizes folded or wrapped PEM text before serving it.

## Configure Tesla Fleet

During Tesla Fleet setup, Home Assistant asks you to host the public key shown in the setup flow. Paste that public key into the **Tesla Fleet Public Key** integration.

This should be the public key shown by the Tesla Fleet integration, not the private `tesla_fleet.key` file.

The key endpoint is unauthenticated so Tesla can fetch it:

```text
https://YOUR_EXISTING_HOME_ASSISTANT_URL/.well-known/appspecific/com.tesla.3p.public-key.pem
```

## Optional Add-on

This repository still contains the add-on from the earlier implementation, but it no longer opens host port `8085` by default. The add-on cannot make the key available on your existing Home Assistant URL unless external traffic is explicitly routed to the add-on first.

Use the custom integration above for the no-port setup.

[![Open your Home Assistant instance and add this add-on repository](https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgithub.com%2Fdnviti%2Ftesla-api-key-homeassistant)

Add-on install steps:

1. Open Home Assistant.
2. Go to **Settings > Apps** or **Settings > Add-ons**, depending on your Home Assistant version.
3. Open the app/add-on store menu and add this repository URL:

   ```text
   https://github.com/dnviti/tesla-api-key-homeassistant
   ```

4. Install **Tesla Fleet Public Key**.

The optional add-on container image is built by GitHub Actions and published to GitHub Container Registry as:

```text
ghcr.io/dnviti/tesla-api-key-homeassistant:1.0.5
```

Home Assistant pulls this prebuilt image from the `image` setting in the add-on configuration.

Use Home Assistant's add-on configuration YAML editor:

1. Open the **Configuration** tab for this add-on.
2. Open the three-dot menu in the configuration card.
3. Select **Edit in YAML**.
4. Paste the key as a YAML block:

```yaml
key_pem: |
  -----BEGIN PUBLIC KEY-----
  paste-the-public-key-shown-by-home-assistant-here
  -----END PUBLIC KEY-----
homeassistant_url: http://homeassistant.local.hass.io:8123
```

The documented Home Assistant add-on schema types do not provide a textarea control, and `schema: false` does not reliably persist add-on options. Use **Edit in YAML** instead of the single-line form field. If Home Assistant rewrites the value as folded YAML (`key_pem: >-`) or wraps the base64 body, the add-on normalizes it back to valid PEM format when it starts.

### Add-on Proxy Mode

The add-on's nginx serves the Tesla key path locally and proxies every other request to `homeassistant_url`, but only if you manually expose/map the add-on port and route external traffic to it.

Default upstream:

```yaml
homeassistant_url: http://homeassistant.local.hass.io:8123
```

Do not bind this add-on to host port `8123` while Home Assistant Core is already using that port. Change the external reverse proxy target instead.

Because this add-on becomes a reverse proxy for Home Assistant, Home Assistant Core may require `use_x_forwarded_for` and `trusted_proxies` in `configuration.yaml`. If Home Assistant logs a reverse proxy or trusted proxy error, add the proxy IP shown in that log, following the [Home Assistant HTTP integration documentation](https://www.home-assistant.io/integrations/http/#reverse-proxies).

## Public HTTPS Requirement

Tesla Fleet requires the public key to be reachable at a valid HTTPS URL on the domain you enter during integration setup:

```text
https://yourdomain.com/.well-known/appspecific/com.tesla.3p.public-key.pem
```

With the recommended custom integration, use the same HTTPS URL you already use for Home Assistant. With the optional add-on, put the add-on behind your existing HTTPS reverse proxy, router, tunnel, or another Home Assistant proxy setup so that the public HTTPS URL forwards to the add-on's manually exposed HTTP port.

The domain must match the Tesla Fleet setup requirements in the [official Tesla Fleet integration documentation](https://www.home-assistant.io/integrations/tesla_fleet), including the developer application origin and the valid SSL certificate requirement.

## Tesla Fleet Setup Flow

Follow the [Home Assistant Tesla Fleet documentation](https://www.home-assistant.io/integrations/tesla_fleet):

1. Create a Tesla Developer Application.
2. Configure the OAuth redirect URI and allowed origin URL.
3. Add Tesla Fleet in Home Assistant.
4. Paste the public key from the setup flow into the **Tesla Fleet Public Key** integration.
5. Verify the public key URL returns the PEM text.
6. Continue Tesla Fleet setup and install the virtual key for each supported vehicle.

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
