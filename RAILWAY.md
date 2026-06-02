# Deploying this Ghost repo on Railway

This repository includes a Railway-ready Docker container. Create a Railway
service from the repository and start it; Railway will use `railway.json`, build
`Dockerfile.railway`, and run `scripts/railway-start.sh`.

## What works without extra setup

The container boots Ghost with Railway defaults:

- listens on `0.0.0.0:$PORT`
- derives `url` from `RAILWAY_PUBLIC_DOMAIN` when Railway provides one
- stores Ghost content in `/data/content`
- uses sqlite at `/data/content/data/ghost.db` when no MySQL service is attached

## Recommended Railway setup

For persistence, attach a Railway Volume to the service. The start script uses
Railway's `RAILWAY_VOLUME_MOUNT_PATH` automatically, so any mount path works.
If no volume is attached, the app can still boot but uploads, themes, and the
sqlite database are ephemeral.

If you attach Railway MySQL, the script maps Railway's `MYSQLHOST`, `MYSQLPORT`,
`MYSQLUSER`, `MYSQLPASSWORD`, and `MYSQLDATABASE` variables into Ghost's database
configuration automatically. Without MySQL, sqlite is used by default.

After Railway generates a public domain, redeploy if needed so `url` is set from
`RAILWAY_PUBLIC_DOMAIN`. You can also set `url` manually to your final custom
domain, for example `https://example.com`.
