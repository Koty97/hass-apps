# openGym — Home Assistant Add-on

Packages [openGym](https://gitea.com/DuarteSantos/openGym) (a self-hosted gym & body-weight
tracker) as a Home Assistant add-on. openGym itself doesn't ship a Home Assistant add-on or a
single all-in-one Docker image — upstream publishes two separate images (`web` + `api`) meant to
run via `docker compose`. This add-on instead **builds openGym from source** at image-build time
and runs the nginx frontend + Node API together in one container, so Supervisor can manage it
like any other add-on.

openGym is AGPL-3.0 licensed by Duarte Santos. This add-on just packages it; it isn't affiliated
with the upstream project.

## Install

### Option A — Local add-on (simplest, no repo needed)

1. Enable the Samba share or SSH add-on on your Home Assistant host so you can reach
   `/addons` (the Supervisor's local add-ons folder).
2. Copy the `opengym/` folder from this repo into `/addons/opengym` on the HA host.
3. In Home Assistant: **Settings → Add-ons → Add-on Store → ⋮ (top right) → Check for updates**,
   then find **openGym** under "Local add-ons".
4. Click it, then **Install**. The first build compiles the frontend and installs the API's
   dependencies from source, so it can take several minutes.

### Option B — Custom repository

1. Push this whole folder (including `repository.yaml`) to your own git repo.
2. In Home Assistant: **Settings → Add-ons → Add-on Store → ⋮ → Repositories**, add your repo's
   URL.
3. Find **openGym** in the store and install it.

## After install

- Open the add-on's **Configuration** tab and review `rp_id` / `origin` (see `opengym/DOCS.md`
  for what these mean — get them wrong and passkey login won't work).
- Start the add-on. First start also downloads ~140 MB of exercise images/GIFs into the add-on's
  persistent storage — this only happens once.
- Open the Web UI from the add-on's **Info** tab.

Full configuration reference: [`opengym/DOCS.md`](./opengym/DOCS.md).
