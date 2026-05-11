FROM ghcr.io/home-assistant/base:latest

ARG BUILD_VERSION
ARG BUILD_ARCH

LABEL \
    io.hass.version="${BUILD_VERSION}" \
    io.hass.type="app" \
    io.hass.arch="${BUILD_ARCH}"

RUN \
    apk add --no-cache nginx && \
    mkdir -p \
        /run/nginx \
        /usr/share/nginx/html/.well-known/appspecific \
        /var/lib/nginx/tmp/client_body

COPY run.sh /
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]

