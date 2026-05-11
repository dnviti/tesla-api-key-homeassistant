#!/usr/bin/with-contenv bashio
set -euo pipefail

KEY_PATH="/usr/share/nginx/html/.well-known/appspecific/com.tesla.3p.public-key.pem"
KEY_PEM="$(bashio::config 'key_pem')"

if [[ -z "${KEY_PEM}" || "${KEY_PEM}" == "null" ]]; then
    bashio::log.fatal "Missing key_pem configuration. Paste the Tesla Fleet public key into the add-on configuration."
    exit 1
fi

if [[ "${KEY_PEM}" == *"paste-the-public-key"* ]]; then
    bashio::log.fatal "key_pem still contains the example placeholder. Paste the real Tesla Fleet public key."
    exit 1
fi

mkdir -p "$(dirname "${KEY_PATH}")"

KEY_PEM_ONE_LINE="$(
    printf '%s' "${KEY_PEM}" |
        tr $'\r\n\t' '   ' |
        sed 's/[[:space:]][[:space:]]*/ /g; s/^ //; s/ $//'
)"

if [[ "${KEY_PEM_ONE_LINE}" != *"-----BEGIN PUBLIC KEY-----"* || \
      "${KEY_PEM_ONE_LINE}" != *"-----END PUBLIC KEY-----"* ]]; then
    bashio::log.fatal "key_pem does not look like a PEM public key. Do not paste the private tesla_fleet.key file."
    exit 1
fi

KEY_BODY="${KEY_PEM_ONE_LINE#*-----BEGIN PUBLIC KEY-----}"
KEY_BODY="${KEY_BODY%%-----END PUBLIC KEY-----*}"
KEY_BODY="$(printf '%s' "${KEY_BODY}" | tr -d '[:space:]')"

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

cat > /etc/nginx/http.d/default.conf <<'NGINX'
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    server_name _;
    root /usr/share/nginx/html;

    location = /.well-known/appspecific/com.tesla.3p.public-key.pem {
        default_type text/plain;
        try_files $uri =404;
    }

    location / {
        return 404;
    }
}
NGINX

bashio::log.info "Serving Tesla Fleet public key at /.well-known/appspecific/com.tesla.3p.public-key.pem"
exec nginx -g "daemon off;"
