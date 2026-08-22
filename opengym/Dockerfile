# syntax=docker/dockerfile:1
#
# openGym has no single all-in-one image upstream — it ships separate
# `web` (nginx) and `api` (Node) images meant for docker-compose. This
# builds both pieces from source and combines them into one container
# so Home Assistant Supervisor can run it as a normal add-on.
#
# Pin OPENGYM_REF to a released tag for reproducible builds. Bump it to
# track new openGym releases.
ARG OPENGYM_REPO=https://gitea.com/DuarteSantos/openGym.git
ARG OPENGYM_REF=v1.2.7

FROM node:22-alpine AS builder
ARG OPENGYM_REPO
ARG OPENGYM_REF
RUN apk add --no-cache git
WORKDIR /src
RUN git clone --depth 1 --branch "${OPENGYM_REF}" "${OPENGYM_REPO}" .

# Frontend: React + Vite -> static files (defaults to dist/)
WORKDIR /src/frontend
ENV NODE_OPTIONS=--max-old-space-size=896
RUN npm ci
RUN npm run build

# API: Node, production deps only. Upstream's own api/Dockerfile is just
# node:22-alpine + `npm install --omit=dev` + server.js, so this mirrors it
# rather than guessing.
WORKDIR /src/api
RUN npm install --omit=dev

FROM node:22-alpine
RUN apk add --no-cache nginx bash curl jq git tzdata

WORKDIR /opengym
COPY --from=builder /src/frontend/dist ./web
COPY --from=builder /src/api ./api

COPY nginx.conf.template /etc/nginx/http.d/opengym.conf.template
COPY run.sh /run.sh
RUN chmod +x /run.sh \
    && mkdir -p /run/nginx \
    && rm -f /etc/nginx/http.d/default.conf

EXPOSE 8099

CMD [ "/run.sh" ]
