#!/command/with-contenv bashio
# ==============================================================================
# Home Assistant Community Add-on: Inner Range Inception to MQTT
# Sets up Inner Range Inception to MQTT.
# ==============================================================================

# Creates configuration folder if it does not exist.
if ! bashio::fs.directory_exists '/config/inception-mqtt'; then
    bashio::log.info "Creating inception-mqtt folder in /config..."
    mkdir -p /config/inception-mqtt ||
        bashio::exit.nok "Could not create /config/inception-mqtt."
fi

# Creates configuration.yml on first start.
if ! bashio::fs.file_exists '/config/inception-mqtt/configuration.yml'; then
    bashio::log.info "Creating configuration.yaml..."
    touch /config/inception-mqtt/configuration.yml ||
        bashio::exit.nok "Could not create configuration.yml."
fi

# Links /opt/inception-mqtt/.config to /config/inception-mqtt
if ! bashio::fs.directory_exists '/opt/inception-mqtt/.config'; then
    bashio::log "Linking /opt/inception-mqtt/.config to /config/inception-mqtt."
    ln -s /config/inception-mqtt /opt/inception-mqtt/.config ||
        bashio::exit.nok "Could not create symbolic link."
fi

# Check for empty config file and creates default config
if [ ! -s '/config/inception-mqtt/configuration.yml' ]; then
    if ! bashio::services.available "mqtt"; then
        bashio::exit.nok "Home Assistant MQTT service is not available. Please add a configuration.yml to /config/inception-mqtt/ and restart the addon."
    fi

    bashio::log.info "Creating default configuration using Home Assistant MQTT broker..."
    HOST=$(bashio::services "mqtt" "host")
    PORT=$(bashio::services "mqtt" "port")
    USERNAME=$(bashio::services "mqtt" "username")
    PASSWORD=$(bashio::services "mqtt" "password")
    {
        echo "mqtt:"
        echo "  broker: ${HOST}"
        echo "  port: ${PORT}"
        echo "  username: ${USERNAME}"
        echo "  password: ${PASSWORD}"
        echo "  qos: 2"
        echo "  retain: true"
        echo "  discovery: true"
        echo "  discovery_prefix: homeassistant"
        echo "  topic_prefix: inception"
        echo "  availability_topic: inception/available"
        echo "  alarm_code: '1199'"
        echo ""
        echo "inception:"
        echo "- base_url: http://192.168.xxx.xxx/api/v1"
        echo "  port: 80"
        echo "  username: xxxx"
        echo "  password: xxxx"
        echo "  polling_timeout: 60"
        echo "  polling_delay: 60"
    } >/config/inception-mqtt/configuration.yml ||
        bashio::exit.nok "Default configuration failed! Please add a configuration.yml to /config/inception-mqtt/ then restart the addon."
    bashio::exit.nok "Default configuration created. Please review the configuration.yml in /config/inception-mqtt/ then restart the addon."
fi
