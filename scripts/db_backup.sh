#!/usr/bin/env bash
set -euo pipefail

mkdir -p backups
PGUSER=jacquesbloom
PGPASSWORD=password
DB=larry

# Use Docker container's pg_dump to avoid version mismatch
docker compose exec -T postgres pg_dump -U ${PGUSER} -d ${DB} --no-owner --format=plain \
  > "backups/${DB}_$(date +%F_%H%M%S).sql"

echo "Backup written to backups/${DB}_$(date +%F_%H%M%S).sql"
