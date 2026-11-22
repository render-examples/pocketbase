# PocketBase on Render

Deploy [PocketBase](https://pocketbase.io/), an open source backend in one
file (SQLite database, auth, file storage, realtime API and an admin
dashboard), on Render with a persistent disk.

[![Deploy to Render](https://render.com/images/deploy-to-render-button.svg)](https://render.com/deploy?repo=https://github.com/render-examples/pocketbase)

## What this creates

The Blueprint creates a `pocketbase` project with a `production` environment:

| Resource | Type | Plan | Notes |
|---|---|---|---|
| `pocketbase` | Web service (Docker) | Starter | Health check at `/api/health` |
| `pb-data` | Persistent disk, 5 GB | | Mounted at `/pb/pb_data` |

PocketBase has no official Docker image, so the `Dockerfile` downloads the
release binary, checks it against the published SHA-256 checksum, and runs
`pocketbase serve` on the port Render assigns. The SQLite database and
uploaded files live in `pb_data` on the disk, so they survive deploys and
restarts.

## Deploy

1. Click **Deploy to Render** above, or create a Blueprint in the Render
   Dashboard that points at this repository.
2. When the deploy is live, open the `pocketbase` service's **Logs** in the
   Render Dashboard. On first start, PocketBase prints a link like this:

   ```
   https://<your-service>.onrender.com/_/#/pbinstal/<token>
   ```

   Replace `0.0.0.0:10000` in the logged link with your service URL if needed,
   open it, and create the first superuser account. The link has a one-time
   token, so only someone who can read the logs can use it.
3. Sign in to the dashboard at `https://<your-service>.onrender.com/_/`.

The REST API is at `https://<your-service>.onrender.com/api/`. See the
[PocketBase docs](https://pocketbase.io/docs/) for the JavaScript and Dart
SDKs.

## Hooks and migrations

Put JavaScript hooks (`*.pb.js`) in [`pb_hooks/`](pb_hooks) and JavaScript
migrations in [`pb_migrations/`](pb_migrations). The Docker build copies
both folders into the image, so push to your repository to deploy changes.

## Recommended settings

In the dashboard, under **Settings**:

- **Mail settings:** set up an SMTP service. The default `sendmail` doesn't
  work on Render, so password resets and verification emails fail until you do.
- **Application URL:** set it to your service URL or custom domain, so links
  in emails point to the right place.
- **Backups:** turn on scheduled backups. You can store them on the disk or in
  S3-compatible storage. Render also takes daily
  [disk snapshots](https://render.com/docs/disks#disk-snapshots).

## Limitations

- A persistent disk attaches to one instance, so the service can't scale to
  more than one instance.
- Render stops the old instance before it starts the new one, so each deploy
  has a few seconds of downtime.

## Upgrades

Change `PB_VERSION` in the `Dockerfile` and push. Find releases at
https://ganigeorgiev.com/pocketbase/pocketbase, where PocketBase moved from
GitHub in October 2026. Read the changelog before you upgrade: PocketBase is
still pre-1.0, and some releases have breaking changes. PocketBase runs its
own migrations on startup.
