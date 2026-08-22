ARG BUILD_FROM=ghcr.io/arvids-unavailable/opengym:1.2.7
FROM ${BUILD_FROM}

# Install jq (for config) and git (for media downloading)
RUN if command -v apt-get >/dev/null; then \
        apt-get update && apt-get install -yq --no-install-recommends jq git; \
    elif command -v apk >/dev/null; then \
        apk add --no-cache jq git; \
    fi

COPY run.sh /run.sh
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]