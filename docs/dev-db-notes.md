# Local DB (Postgres) — Persistence & Safety

## Current Setup ✅
- **Docker Compose**: ✅ Present (`docker-compose.yaml`)
- **DB Container**: `larry-postgres-1` (postgres:15)
- **Persistent Volume**: ✅ `larry_postgres_data` mounted to `/var/lib/postgresql/data`
- **Connection**: `postgresql://jacquesbloom:password@localhost:5433/larry`

## Database Status ✅
- **Container**: Running and healthy
- **Volume**: Persistent data storage enabled and tested
- **Tables**: 17 tables including migrations
- **Data**: 1 user, 16 interests, and other data present
- **Persistence Test**: ✅ Data survives container restarts

## Management Commands
- Start DB: `docker compose up -d postgres`
- Stop DB: `docker compose down` (volume retained)
- Restart DB: `docker compose restart postgres` (data preserved)
- Connect: `docker compose exec postgres psql -U jacquesbloom -d larry`
- View logs: `docker compose logs postgres`
- **Backup service**: `docker compose up -d backup` (auto-backup every 30 minutes)
- **View backup logs**: `docker compose logs backup`

## Warnings ⚠️
- **Do NOT** run `docker rm -v` on DB container — deletes volume
- **Do NOT** run `prisma migrate reset` — wipes all data
- **Do NOT** run `docker volume rm larry_postgres_data` — deletes all data

## Backups ✅
- **Manual backup**: `pnpm db:backup` (basic)
- **Enhanced backup**: `pnpm db:backup:enhanced` (with compression & retention)
- **Auto backup setup**: `pnpm db:backup:setup-auto` (cron-based)
- **Docker auto backup**: ✅ Running every 30 minutes (service: `larry-backup-1`)
- **Manual backup**: `docker compose exec postgres pg_dump -U jacquesbloom -d larry > backup.sql`
- **Backup tested**: ✅ Multiple backup files created successfully
- **Retention**: Auto-cleanup after 7 days
- **Compression**: Enhanced backups are gzipped (smaller size)

## Volume Location
- **Host Path**: `/var/lib/docker/volumes/larry_postgres_data/_data`
- **Container Path**: `/var/lib/postgresql/data`
- **Persistence**: ✅ Data survives container restarts and rebuilds

## Test Results ✅
- **Before restart**: 1 user, 16 interests
- **After restart**: 1 user, 16 interests (unchanged)
- **Volume mount**: Still properly attached after restart
