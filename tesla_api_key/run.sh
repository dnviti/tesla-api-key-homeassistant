#!/usr/bin/with-contenv bashio
set -euo pipefail

KEY_PATH="/usr/share/nginx/html/.well-known/appspecific/com.tesla.3p.public-key.pem"
KEY_PEM="$(bashio::config 'key_pem')"
HOMEASSISTANT_URL="$(bashio::config 'homeassistant_url')"

if [[ -z "${KEY_PEM}" || "${KEY_PEM}" == "null" ]]; then
    bashio::log.fatal "Missing key_pem configuration. Paste the Tesla Fleet public key into the add-on configuration."
    exit 1
fi

if [[ "${KEY_PEM}" == *"paste-the-public-key"* ]]; then
    bashio::log.fatal "key_pem still contains the example placeholder. Paste the real Tesla Fleet public key."
    exit 1
fi

if [[ -z "${HOMEASSISTANT_URL}" || "${HOMEASSISTANT_URL}" == "null" ]]; then
    HOMEASSISTANT_URL="http://homeassistant.local.hass.io:8123"
fi

HOMEASSISTANT_URL="${HOMEASSISTANT_URL%/}"

if [[ ! "${HOMEASSISTANT_URL}" =~ ^https?://[A-Za-z0-9._-]+(:[0-9]+)?$ ]]; then
    bashio::log.fatal "homeassistant_url must be a plain http(s) origin like http://homeassistant.local.hass.io:8123"
    exit 1
fi

mkdir -p "$(dirname "${KEY_PATH}")"

KEY_PEM_ONE_LINE="$(
    printf '%s' "${KEY_PEM}" |
        tr $'\r\n\t' '   ' |
        sed 's/[[:space:]][[:space:]]*/ /g; s/^ //; s/ $//'
)"

KEY_PEM_COMPACT="$(
    printf '%s' "${KEY_PEM_ONE_LINE}" |
        sed 's/\\r//g; s/\\n//g' |
        tr -d '[:space:]'
)"
BEGIN_MARKER="-----BEGINPUBLICKEY-----"
END_MARKER="-----ENDPUBLICKEY-----"

if [[ "${KEY_PEM_COMPACT}" != *"${BEGIN_MARKER}"* || \
      "${KEY_PEM_COMPACT}" != *"${END_MARKER}"* ]]; then
    bashio::log.fatal "key_pem does not look like a PEM public key. Do not paste the private tesla_fleet.key file."
    exit 1
fi

KEY_BODY="${KEY_PEM_COMPACT#*${BEGIN_MARKER}}"
KEY_BODY="${KEY_BODY%%${END_MARKER}*}"

if [[ -z "${KEY_BODY}" || ! "${KEY_BODY}" =~ ^[A-Za-z0-9+/=]+$ ]]; then
    bashio::log.fatal "key_pem has an invalid PEM body. Paste only the Tesla Fleet public key."
    exit 1
fi

{
    printf '%s\n' "-----BEGIN PUBLIC KEY-----"
    printf '%s' "${KEY_BODY}" | fold -w 64
    printf '\n%s\n' "-----END PUBLIC KEY-----"
} > "${KEY_PATH}"
chmod 0444 "${KEY_PATH}"

cat > /etc/nginx/http.d/default.conf <<NGINX
map \$http_upgrade \$connection_upgrade {
    default upgrade;
    '' close;
}

map \$http_x_forwarded_proto \$forwarded_proto {
    default \$http_x_forwarded_proto;
    '' \$scheme;
}

server {
    listen 80 default_server;
    listen [::]:80 default_server;
    server_name _;
    root /usr/share/nginx/html;
    client_max_body_size 0;

    location = /.well-known/appspecific/com.tesla.3p.public-key.pem {
        default_type text/plain;
        try_files \$uri =404;
    }

    location / {
        proxy_pass ${HOMEASSISTANT_URL};
        proxy_buffering off;
        proxy_http_version 1.1;
        proxy_read_timeout 3600s;
        proxy_send_timeout 3600s;

        proxy_set_header Host \$http_host;
        proxy_set_header Origin \$http_origin;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection \$connection_upgrade;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Host \$http_host;
        proxy_set_header X-Forwarded-Proto \$forwarded_proto;
    }
}
NGINX

bashio::log.info "Serving Tesla Fleet public key at /.well-known/appspecific/com.tesla.3p.public-key.pem"
bashio::log.info "Proxying all other requests to ${HOMEASSISTANT_URL}"
exec nginx -g "daemon off;"
