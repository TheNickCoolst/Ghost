#!/usr/bin/env bash
set -euo pipefail

# Railway provides PORT at runtime; Ghost must listen on 0.0.0.0:$PORT.
export NODE_ENV="${NODE_ENV:-production}"
export server__host="${server__host:-0.0.0.0}"
export server__port="${server__port:-${PORT:-2368}}"

# Prefer an explicit Ghost URL, otherwise derive one from Railway's public
# domain. The localhost fallback keeps the container bootable before a Railway
# domain has been generated.
if [[ -z "${url:-}" ]]; then
    if [[ -n "${RAILWAY_PUBLIC_DOMAIN:-}" ]]; then
        export url="https://${RAILWAY_PUBLIC_DOMAIN}"
    else
        export url="http://localhost:${server__port}"
    fi
fi

# Persist Ghost content on a Railway Volume when one is attached. Railway sets
# RAILWAY_VOLUME_MOUNT_PATH automatically for attached volumes. Without a
# volume, /data still lets the container boot, but data will be ephemeral.
CONTENT_ROOT="${RAILWAY_VOLUME_MOUNT_PATH:-/data}"
export paths__contentPath="${paths__contentPath:-${CONTENT_ROOT}/content}"
mkdir -p "${paths__contentPath}" "${paths__contentPath}/data"

# Make the image run with no extra services by default: use sqlite in the
# content volume. If a Railway MySQL service is attached, Railway commonly
# exposes MYSQLHOST/MYSQLPORT/MYSQLUSER/MYSQLPASSWORD/MYSQLDATABASE; map those
# to Ghost's nested env format automatically.
if [[ -n "${MYSQLHOST:-}" || -n "${MYSQL_URL:-}" || -n "${DATABASE_URL:-}" ]]; then
    export database__client="${database__client:-mysql}"

    if [[ -n "${MYSQLHOST:-}" ]]; then
        export database__connection__host="${database__connection__host:-${MYSQLHOST}}"
        export database__connection__port="${database__connection__port:-${MYSQLPORT:-3306}}"
        export database__connection__user="${database__connection__user:-${MYSQLUSER:-root}}"
        export database__connection__password="${database__connection__password:-${MYSQLPASSWORD:-}}"
        export database__connection__database="${database__connection__database:-${MYSQLDATABASE:-railway}}"
    fi
else
    export database__client="${database__client:-sqlite3}"
    export database__connection__filename="${database__connection__filename:-${paths__contentPath}/data/ghost.db}"
fi

cd /app/ghost/core
exec node index.js
