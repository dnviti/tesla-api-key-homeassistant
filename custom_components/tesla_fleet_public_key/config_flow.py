"""Config flow for the Tesla Fleet Public Key integration."""

from __future__ import annotations

import re
import textwrap
from typing import Any

import voluptuous as vol

from homeassistant.config_entries import ConfigFlow, ConfigFlowResult, OptionsFlow
from homeassistant.core import callback
from homeassistant.helpers.selector import (
    TextSelector,
    TextSelectorConfig,
    TextSelectorType,
)

from .const import CONF_KEY_PEM, DOMAIN, TITLE

BEGIN_MARKER = "-----BEGINPUBLICKEY-----"
END_MARKER = "-----ENDPUBLICKEY-----"
KEY_BODY_RE = re.compile(r"^[A-Za-z0-9+/=]+$")

KEY_SELECTOR = TextSelector(
    TextSelectorConfig(type=TextSelectorType.TEXT, multiline=True)
)


class PublicKeyPlaceholderError(ValueError):
    """Raised when the example placeholder is submitted."""


class PublicKeyFormatError(ValueError):
    """Raised when the submitted key does not look like a public PEM key."""


def normalize_public_key(value: str) -> str:
    """Normalize folded, wrapped, or escaped PEM input into standard PEM text."""
    if not value or not value.strip():
        raise PublicKeyFormatError

    if "paste-the-public-key" in value:
        raise PublicKeyPlaceholderError

    compact = value.replace("\\r", "").replace("\\n", "")
    compact = "".join(compact.split())

    if BEGIN_MARKER not in compact or END_MARKER not in compact:
        raise PublicKeyFormatError

    body = compact.split(BEGIN_MARKER, 1)[1].split(END_MARKER, 1)[0]
    if not body or not KEY_BODY_RE.fullmatch(body):
        raise PublicKeyFormatError

    wrapped_body = "\n".join(textwrap.wrap(body, width=64))
    return f"-----BEGIN PUBLIC KEY-----\n{wrapped_body}\n-----END PUBLIC KEY-----\n"


def build_key_schema(default: str | None = None) -> vol.Schema:
    """Build the public key form schema."""
    key = (
        vol.Required(CONF_KEY_PEM, default=default)
        if default
        else vol.Required(CONF_KEY_PEM)
    )
    return vol.Schema({key: KEY_SELECTOR})


def validate_key(user_input: dict[str, Any]) -> tuple[dict[str, str], dict[str, Any]]:
    """Validate and normalize user input."""
    errors: dict[str, str] = {}
    normalized_input = dict(user_input)

    try:
        normalized_input[CONF_KEY_PEM] = normalize_public_key(user_input[CONF_KEY_PEM])
    except PublicKeyPlaceholderError:
        errors[CONF_KEY_PEM] = "placeholder"
    except PublicKeyFormatError:
        errors[CONF_KEY_PEM] = "invalid_public_key"

    return errors, normalized_input


class TeslaFleetPublicKeyConfigFlow(ConfigFlow, domain=DOMAIN):
    """Handle a config flow for Tesla Fleet Public Key."""

    VERSION = 1

    @staticmethod
    @callback
    def async_get_options_flow(
        config_entry,
    ) -> TeslaFleetPublicKeyOptionsFlow:
        """Create the options flow."""
        return TeslaFleetPublicKeyOptionsFlow()

    async def async_step_user(
        self, user_input: dict[str, Any] | None = None
    ) -> ConfigFlowResult:
        """Handle the initial setup step."""
        await self.async_set_unique_id(DOMAIN)
        self._abort_if_unique_id_configured()

        errors: dict[str, str] = {}

        if user_input is not None:
            errors, normalized_input = validate_key(user_input)
            if not errors:
                return self.async_create_entry(title=TITLE, data=normalized_input)

        return self.async_show_form(
            step_id="user",
            data_schema=build_key_schema(),
            errors=errors,
        )


class TeslaFleetPublicKeyOptionsFlow(OptionsFlow):
    """Handle Tesla Fleet Public Key options."""

    async def async_step_init(
        self, user_input: dict[str, Any] | None = None
    ) -> ConfigFlowResult:
        """Manage integration options."""
        errors: dict[str, str] = {}

        if user_input is not None:
            errors, normalized_input = validate_key(user_input)
            if not errors:
                return self.async_create_entry(title="", data=normalized_input)

        current_key = self.config_entry.options.get(
            CONF_KEY_PEM, self.config_entry.data.get(CONF_KEY_PEM, "")
        )

        return self.async_show_form(
            step_id="init",
            data_schema=build_key_schema(current_key),
            errors=errors,
        )
