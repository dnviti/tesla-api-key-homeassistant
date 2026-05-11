"""Serve the Tesla Fleet public key from Home Assistant Core."""

from __future__ import annotations

from http import HTTPStatus

from aiohttp import web

from homeassistant.components.http import KEY_HASS, HomeAssistantView
from homeassistant.config_entries import ConfigEntry
from homeassistant.core import HomeAssistant, callback

from .const import (
    CONF_KEY_PEM,
    DATA_KEY_PEM,
    DATA_VIEW_REGISTERED,
    DOMAIN,
    PUBLIC_KEY_PATH,
)

TeslaFleetPublicKeyConfigEntry = ConfigEntry


async def async_setup_entry(
    hass: HomeAssistant, entry: TeslaFleetPublicKeyConfigEntry
) -> bool:
    """Set up Tesla Fleet Public Key from a config entry."""
    domain_data = hass.data.setdefault(DOMAIN, {})
    domain_data[DATA_KEY_PEM] = entry.options.get(
        CONF_KEY_PEM, entry.data[CONF_KEY_PEM]
    )

    if not domain_data.get(DATA_VIEW_REGISTERED):
        hass.http.register_view(TeslaFleetPublicKeyView)
        domain_data[DATA_VIEW_REGISTERED] = True

    entry.async_on_unload(entry.add_update_listener(_async_update_listener))
    return True


async def async_unload_entry(
    hass: HomeAssistant, entry: TeslaFleetPublicKeyConfigEntry
) -> bool:
    """Unload Tesla Fleet Public Key."""
    domain_data = hass.data.setdefault(DOMAIN, {})
    domain_data.pop(DATA_KEY_PEM, None)
    return True


async def _async_update_listener(
    hass: HomeAssistant, entry: TeslaFleetPublicKeyConfigEntry
) -> None:
    """Reload the entry after options change."""
    await hass.config_entries.async_reload(entry.entry_id)


class TeslaFleetPublicKeyView(HomeAssistantView):
    """Serve the configured Tesla Fleet public key without authentication."""

    url = PUBLIC_KEY_PATH
    name = "tesla_fleet_public_key:public_key"
    requires_auth = False

    @callback
    def get(self, request: web.Request) -> web.Response:
        """Return the configured Tesla Fleet public key."""
        hass: HomeAssistant = request.app[KEY_HASS]
        key_pem = hass.data.get(DOMAIN, {}).get(DATA_KEY_PEM)

        if not key_pem:
            return web.Response(
                status=HTTPStatus.NOT_FOUND,
                text="Tesla Fleet public key is not configured.\n",
                content_type="text/plain",
            )

        return web.Response(
            text=key_pem,
            content_type="text/plain",
            headers={"Cache-Control": "no-store"},
        )
