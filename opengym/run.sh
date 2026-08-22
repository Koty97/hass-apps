#!/usr/bin/env bash

# 1. Parse Home Assistant Configuration
CONFIG_PATH=/data/options.json
PORT=$(jq --raw-output '.port // 3000' $CONFIG_PATH)
LOG_LEVEL=$(jq --raw-output '.log_level // "info"' $CONFIG_PATH)

export PORT
export LOG_LEVEL
export DATA_DIR=/data

# 2. Replicate the `media` compose service
# Create persistent directories inside Home Assistant's /data volume
mkdir -p /data/media/img /data/media/gif

# If the folder is empty, download the media (exactly like the compose file)
if [ -z "$(ls -A /data/media/img 2>/dev/null)" ]; then
    echo "↓ Downloading exercise media (~140 MB, one time)…"
    git clone --depth 1 https://github.com/hasaneyldrm/exercises-dataset /tmp/ds
    cp /tmp/ds/images/*.jpg /data/media/img/
    cp /tmp/ds/videos/*.gif /data/media/gif/
    rm -rf /tmp/ds
    echo "✓ Exercise media ready."
else
    echo "✓ Exercise media already present — skipping download."
fi

# 3. Replicate the `web` compose volume mappings
# The web container expects media at /usr/share/nginx/html
# We symlink our persistent /data/media folder to Nginx's path
rm -rf /usr/share/nginx/html/img /usr/share/nginx/html/gif
ln -s /data/media/img /usr/share/nginx/html/img
ln -s /data/media/gif /usr/share/nginx/html/gif

# 4. Start the main monolithic application
exec /docker-entrypoint.sh