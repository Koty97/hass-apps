#!/usr/bin/env bash
set -uo pipefail

OPTIONS_FILE=/data/options.json
APP_DATA_DIR=/data/appdata
MEDIA_DIR=/data/media
export API_PORT=3000
export WEB_PORT=8099

mkdir -p "$APP_DATA_DIR" "$MEDIA_DIR/img" "$MEDIA_DIR/gif"

get_opt() {
    jq -r --arg k "$1" '.[$k] // empty' "$OPTIONS_FILE"
}

export RP_ID
RP_ID="$(get_opt rp_id)"
export ORIGIN
ORIGIN="$(get_opt origin)"
export RP_NAME
RP_NAME="$(get_opt rp_name)"
export SESSION_DAYS
SESSION_DAYS="$(get_opt session_days)"
export ADMIN_UIDS
ADMIN_UIDS="$(get_opt admin_uids)"
export VAPID_SUBJECT
VAPID_SUBJECT="$(get_opt vapid_subject)"

invite_only_raw="$(get_opt invite_only)"
allow_guest_raw="$(get_opt allow_guest)"
download_media_raw="$(get_opt download_media)"

if [ "$invite_only_raw" = "true" ]; then export INVITE_ONLY=1; else export INVITE_ONLY=0; fi
if [ "$allow_guest_raw" = "false" ]; then export ALLOW_GUEST=0; else export ALLOW_GUEST=1; fi

export PORT="$API_PORT"
export DATA_DIR="$APP_DATA_DIR"

echo "[opengym] RP_ID=${RP_ID} ORIGIN=${ORIGIN} RP_NAME=${RP_NAME}"

# Exercise media (~140 MB), downloaded once into persistent storage, same
# as upstream's docker-compose "media" init step.
#
# NOTICE: this media comes from github.com/hasaneyldrm/exercises-dataset.
# The dataset's own metadata/instruction text is MIT-licensed, but the
# images and GIFs themselves are (c) Gym visual (https://gymvisual.com) and
# are used here under that dataset's terms, not openGym's AGPL-3.0 and not
# this add-on's license. openGym does not redistribute them, and neither
# does this add-on: they're fetched fresh from upstream on first run. Any
# other reuse of that media needs its own license from Gym visual — see
# https://gymvisual.com/content/3-terms-and-conditions-of-use and
# openGym's NOTICE.md.
if [ "$download_media_raw" != "false" ] && [ -z "$(ls -A "$MEDIA_DIR/img" 2>/dev/null)" ]; then
    echo "[opengym] Downloading exercise media (~140 MB), first run only..."
    echo "[opengym] Source: github.com/hasaneyldrm/exercises-dataset."
    echo "[opengym] Images/GIFs are (c) Gym visual (gymvisual.com), used under that"
    echo "[opengym] dataset's own terms, not redistributed by openGym or this add-on."
    tmpdir="$(mktemp -d)"
    if git clone --depth 1 https://github.com/hasaneyldrm/exercises-dataset "$tmpdir/ds" >/tmp/media.log 2>&1; then
        cp "$tmpdir"/ds/images/*.jpg "$MEDIA_DIR/img/" 2>/dev/null || true
        cp "$tmpdir"/ds/videos/*.gif "$MEDIA_DIR/gif/" 2>/dev/null || true
        echo "[opengym] Exercise media ready ($(ls "$MEDIA_DIR/img" | wc -l) images)."
    else
        echo "[opengym] WARNING: could not download exercise media (see /tmp/media.log)." \
             "Exercise images/GIFs will be missing; the tracker itself still works."
    fi
    rm -rf "$tmpdir"
else
    echo "[opengym] Exercise media already present or download disabled, skipping."
fi

envsubst '${WEB_PORT} ${API_PORT}' \
    < /etc/nginx/http.d/opengym.conf.template \
    > /etc/nginx/http.d/default.conf

# Start the API. Upstream's entry point is api/server.js (confirmed from
# its own Dockerfile), reached here via "npm start". Kept as an npm-start-
# or-fall-back-to-main lookup rather than a hardcoded filename, so this
# doesn't silently break if a future openGym release renames it.
cd /opengym/api || exit 1
if node -e "process.exit((require('./package.json').scripts||{}).start?0:1)"; then
    npm start &
else
    main_file="$(node -e "console.log(require('./package.json').main||'index.js')")"
    node "$main_file" &
fi
api_pid=$!
cd /opengym || exit 1

nginx -g "daemon off;" &
nginx_pid=$!

term_handler() {
    echo "[opengym] Shutting down..."
    kill -TERM "$api_pid" 2>/dev/null || true
    nginx -s quit 2>/dev/null || true
    wait "$api_pid" 2>/dev/null
    wait "$nginx_pid" 2>/dev/null
    exit 0
}
trap term_handler SIGTERM SIGINT

wait -n "$api_pid" "$nginx_pid"
echo "[opengym] A process exited unexpectedly, stopping add-on."
term_handler
