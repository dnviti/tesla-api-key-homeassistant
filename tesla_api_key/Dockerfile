FROM ghcr.io/home-assistant/base:latest

ARG BUILD_VERSION=dev

LABEL \
    io.hass.version="${BUILD_VERSION}" \
    io.hass.type="app" \
    io.hass.arch="aarch64|amd64" \
    org.opencontainers.image.source="https://github.com/dnviti/tesla-api-key-homeassistant" \
    org.opencontainers.image.description="Tesla Fleet public key Home Assistant add-on"

RUN \
    apk add --no-cache nginx && \
    mkdir -p \
        /run/nginx \
        /usr/share/nginx/html/.well-known/appspecific \
        /var/lib/nginx/tmp/client_body

COPY run.sh /
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]
