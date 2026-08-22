# Third-party media notice

This add-on, on first start, downloads the exercise image/GIF library from
[hasaneyldrm/exercises-dataset](https://github.com/hasaneyldrm/exercises-dataset), exactly as
upstream openGym's own `docker-compose.yml` does.

- The dataset's metadata and instruction text are MIT-licensed.
- The exercise images and GIFs themselves are © [Gym visual](https://gymvisual.com) and are used
  under that dataset's own terms — **not** openGym's AGPL-3.0, and not this add-on's license.
- Neither openGym nor this add-on redistributes that media: it's fetched directly from upstream
  into this add-on's persistent storage (`/data/media`) at runtime.
- Reusing that media yourself, commercially or not, requires your own license from Gym visual.
  See <https://gymvisual.com/content/3-terms-and-conditions-of-use> and openGym's own
  `NOTICE.md` in its repository.

Set the `download_media` option to `false` if you don't want this add-on to fetch that media at
all.
