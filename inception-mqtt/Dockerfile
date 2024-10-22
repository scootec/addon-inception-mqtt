ARG BUILD_FROM=ghcr.io/hassio-addons/base/amd64:16.3.4
FROM ${BUILD_FROM}

# Set inception-mqtt Committ. Needs to be after FROM
ARG INCEPTION_MQTT_COMMIT="8d83e05"

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Setup base
RUN apk add --no-cache --virtual .build-dependencies \
    # git \
    npm \
    \
    && apk add --no-cache \
    nodejs

# Create work dir. Download latest release. Remove unnecessary directories.
RUN mkdir -p /opt/inception-mqtt \
    && cd /opt/inception-mqtt \
    && curl -sL "https://github.com/matthew-larner/inception-mqtt/tarball/${INCEPTION_MQTT_COMMIT}" \
    -o "release.tar.gz" \
    && tar -xzvf "release.tar.gz" --strip-components=1 \
    && npm ci \
    --no-audit \
    --no-optional \
    --no-update-notifier \
    --unsafe-perm \
    && npm run build \
    # Cleanup
    && npm prune --production \
    && npm cache clear --force \
    && apk del --purge .build-dependencies \
    && find . \
    -not -path './dist/*' \
    -not -path './node_modules/*' \
    -not -name 'index.js' \
    -not -name 'package.json' \
    -delete

# Copy /etc
COPY rootfs /

# Build arugments
ARG BUILD_ARCH
ARG BUILD_DATE
ARG BUILD_REF
ARG BUILD_VERSION

# Labels
LABEL \
    io.hass.name="Inner Range Inception to MQTT" \
    io.hass.description="" \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.type="addon" \
    io.hass.version=${BUILD_VERSION} \
    maintainer="Shane Scott" \
    org.opencontainers.image.title="Inner Range Inception to MQTT" \
    org.opencontainers.image.description="Inner Range Inception to MQTT bridge." \
    org.opencontainers.image.vendor="Home Assistant Community Add-ons" \
    org.opencontainers.image.authors="Shane Scott" \
    org.opencontainers.image.licenses="MIT" \
    org.opencontainers.image.url="https://github.com/scootec/addon-inception-mqtt" \
    org.opencontainers.image.source="https://github.com/scootec/addon-inception-mqtt" \
    org.opencontainers.image.documentation="https://github.com/scootec/addon-inception-mqtt" \
    org.opencontainers.image.created=${BUILD_DATE} \
    org.opencontainers.image.revision=${BUILD_REF} \
    org.opencontainers.image.version=${BUILD_VERSION}