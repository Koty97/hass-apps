# openGym

Self-hosted gym & body-weight tracker, built from source from
[DuarteSantos/openGym](https://gitea.com/DuarteSantos/openGym) (AGPL-3.0).

## Why this add-on builds from source

Upstream doesn't publish one all-in-one image — it ships a `web` (nginx) image and an `api`
(Node) image meant to be run together with `docker compose`, plus a separate one-shot step that
downloads ~140 MB of exercise images/GIFs. A Home Assistant add-on is one container, so this
add-on clones the openGym repo at build time, builds the frontend and installs the API, and runs
both processes (nginx + Node) inside that single container — mirroring what the upstream compose
file does.

## First start

- The image build compiles the React/Vite frontend and installs API dependencies — this can take
  several minutes, especially on a Raspberry Pi.
- The first time the add-on **runs**, it downloads the exercise media library into persistent
  storage. This only happens once; subsequent restarts skip it.

## Configuration

| Option | Meaning | Default |
| --- | --- | --- |
| `rp_id` | The hostname passkeys are bound to. Must match the hostname you actually browse to. | `localhost` |
| `origin` | The full URL the app is served from, including scheme and port. Must match what's in your browser's address bar. | `http://localhost:8099` |
| `rp_name` | Name shown in the passkey prompt. | `openGym` |
| `session_days` | How long a sign-in lasts, in days. | `90` |
| `admin_uids` | Comma-separated user IDs that get the admin dashboard. Leave empty for none. | *(empty)* |
| `invite_only` | Require an invite code to create a profile. | `false` |
| `allow_guest` | Offer "Continue without account". | `true` |
| `vapid_subject` | Contact URL sent with push notifications. Defaults to `origin` if left empty. | *(empty)* |
| `download_media` | Download the exercise image/GIF library on first run. Turn off to save ~140 MB if you don't need exercise media. | `true` |

### Getting `rp_id` / `origin` right

This is the most common source of "passkey sign-in doesn't work":

- **Local/LAN testing on `http://localhost:8099`** (i.e. you're on the same machine as Home
  Assistant): the defaults work as-is.
- **Accessing over your LAN by IP or another hostname, or from your phone**: WebAuthn passkeys
  require a real hostname over HTTPS (browsers only exempt `localhost`). Put a reverse proxy
  (e.g. Nginx Proxy Manager, or Home Assistant's own remote access) in front of this add-on with
  a real domain and a valid TLS certificate, then set `rp_id` to that domain (no scheme, no
  port) and `origin` to the full `https://` URL. See upstream's
  [`docs/SELF_HOSTING.md`](https://gitea.com/DuarteSantos/openGym/src/branch/main/docs/SELF_HOSTING.md)
  for the full picture — the mechanics are identical, only the deployment wrapper differs.

## Data & backups

Everything is stored under the add-on's persistent `/data`:

- `/data/appdata` — profiles, passkeys, workouts, body-weight history, the session-cookie
  secret, and generated push-notification keys. **Back this up — losing it loses everything.**
- `/data/media` — the downloaded exercise image/GIF library (safe to delete; it'll be
  re-downloaded on next start if `download_media` is on).

## Updating to a newer openGym release

This add-on pins a specific openGym git tag at build time (see `OPENGYM_REF` in the Dockerfile).
To pick up a new upstream release, bump that tag, bump this add-on's `version` in `config.yaml`,
and rebuild.

## Third-party exercise media

On first start this add-on downloads the exercise image/GIF library into persistent storage,
exactly as upstream's own `docker-compose.yml` does. Those images/GIFs are © Gym visual
(gymvisual.com), used under that dataset's own terms rather than openGym's or this add-on's
license — see [`NOTICE.md`](./NOTICE.md). Set `download_media` to `false` to skip it.

## A note on forks and mirrors

If you go looking for openGym elsewhere, stick to the
[gitea.com/DuarteSantos/openGym](https://gitea.com/DuarteSantos/openGym) source this add-on
builds from. Some GitHub forks found while researching this add-on carried an unofficial
`ai-enablement/` addition baking third-party AI agent tooling directly into the API's Docker
image — not part of the real project, whose optional AI integration (`mcp/`) is opt-in and runs
client-side, not inside the server image.

## Known limitations

- The optional MCP server (for asking an AI assistant about your training data) isn't included —
  upstream ships it separately from the Docker build too, and it's meant to be spawned locally by
  an AI client like Claude Desktop rather than run as a server.
- Android/iOS mobile-app builds are unrelated to self-hosting and aren't part of this add-on.
