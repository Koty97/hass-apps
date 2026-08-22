#!/usr/bin/with-contenv bashio

PORT=$(bashio::config 'port')
LOG_LEVEL=$(bashio::config 'log_level')

export PORT
export LOG_LEVEL

exec /docker-entrypoint.sh