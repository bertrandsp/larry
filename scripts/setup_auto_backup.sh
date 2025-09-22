#!/usr/bin/env bash
set -euo pipefail

# Setup automatic database backups using cron
# This script will create a cron job that runs every 6 hours

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BACKUP_SCRIPT="$SCRIPT_DIR/db_backup.sh"

# Create a cron job that runs every 30 minutes
CRON_JOB="*/30 * * * * cd $PROJECT_DIR && $BACKUP_SCRIPT >> logs/backup.log 2>&1"

echo "Setting up automatic database backups..."
echo "Backup script: $BACKUP_SCRIPT"
echo "Cron job: $CRON_JOB"

# Create logs directory
mkdir -p "$PROJECT_DIR/logs"

# Add to crontab (this will add to user's crontab)
(crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -

echo "✅ Automatic backup cron job added!"
echo "📅 Backups will run every 30 minutes"
echo "📁 Backup files: $PROJECT_DIR/backups/"
echo "📝 Logs: $PROJECT_DIR/logs/backup.log"
echo ""
echo "To view current cron jobs: crontab -l"
echo "To remove this cron job: crontab -e (then delete the line)"
