# Changelog

## 1.0.4

- Proxy all non-key requests to the configured Home Assistant upstream.
- Add `homeassistant_url` configuration with a default internal Home Assistant URL.

## 1.0.3

- Restore schema-backed `key_pem` persistence.
- Document the Home Assistant **Edit in YAML** workflow instead of `schema: false`.

## 1.0.2

- Switch configuration to Home Assistant's raw configuration/code editor.
- Make PEM marker parsing tolerant of wrapped marker text and escaped newlines.

## 1.0.1

- Normalize folded Home Assistant YAML values back to valid PEM formatting.

## 1.0.0

- Initial Home Assistant app/add-on for serving the Tesla Fleet public key.
