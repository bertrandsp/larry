#!/usr/bin/env bash
set -euo pipefail

# Enhanced database backup script with retention and compression
# Usage: ./db_backup_enhanced.sh [retention_days] [compression]

RETENTION_DAYS=${1:-7}  # Default: keep 7 days
COMPRESS=${2:-true}     # Default: compress backups

mkdir -p backups
mkdir -p logs

PGUSER=jacquesbloom
PGPASSWORD=password
DB=larry
TIMESTAMP=$(date +%F_%H%M%S)
BACKUP_FILE="backups/${DB}_${TIMESTAMP}.sql"
LOG_FILE="logs/backup_${TIMESTAMP}.log"

echo "Starting enhanced database backup at $(date)" | tee -a "$LOG_FILE"

# Create backup
echo "Creating backup: $BACKUP_FILE" | tee -a "$LOG_FILE"
docker compose exec -T postgres pg_dump -U ${PGUSER} -d ${DB} --no-owner --format=plain > "$BACKUP_FILE" 2>> "$LOG_FILE"

if [ $? -eq 0 ]; then
    echo "✅ Backup created successfully: $BACKUP_FILE" | tee -a "$LOG_FILE"
    
    # Compress if requested
    if [ "$COMPRESS" = "true" ]; then
        echo "Compressing backup..." | tee -a "$LOG_FILE"
        gzip "$BACKUP_FILE"
        BACKUP_FILE="${BACKUP_FILE}.gz"
        echo "✅ Compressed backup: $BACKUP_FILE" | tee -a "$LOG_FILE"
    fi
    
    # Get file size
    FILE_SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
    echo "📁 Backup size: $FILE_SIZE" | tee -a "$LOG_FILE"
    
    # Clean up old backups
    echo "Cleaning up backups older than $RETENTION_DAYS days..." | tee -a "$LOG_FILE"
    find backups -name "${DB}_*.sql*" -mtime +$RETENTION_DAYS -delete 2>/dev/null || true
    
    # List current backups
    echo "📋 Current backups:" | tee -a "$LOG_FILE"
    ls -lah backups/${DB}_*.sql* 2>/dev/null | tee -a "$LOG_FILE" || echo "No backups found" | tee -a "$LOG_FILE"
    
    echo "✅ Enhanced backup completed successfully at $(date)" | tee -a "$LOG_FILE"
else
    echo "❌ Backup failed! Check logs: $LOG_FILE" | tee -a "$LOG_FILE"
    exit 1
fi
