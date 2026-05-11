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
printf '%s\n' "${KEY_PEM}" | sed 's/\r$//' > "${KEY_PATH}"
chmod 0444 "${KEY_PATH}"

if ! grep -Eq -- '^-----BEGIN (.* )?PUBLIC KEY-----$' "${KEY_PATH}" || \
   ! grep -Eq -- '^-----END (.* )?PUBLIC KEY-----$' "${KEY_PATH}"; then
    bashio::log.fatal "key_pem does not look like a PEM public key. Do not paste the private tesla_fleet.key file."
    exit 1
fi

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
