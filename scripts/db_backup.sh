#!/usr/bin/env bash

# Enable strict error handling
set -e
set -u

# Configuration Variables
BACKUP_DIR="/var/backups/db"
TIMESTAMP=$(date "+%Y%m%d")
BACKUP_FILE="${BACKUP_DIR}/db_backup_${TIMESTAMP}.sql.gz"
CONTAINER_NAME="postgres_db" 
DB_USER="postgres"

# Trap errors and log exactly which line failed
trap 'echo "[$TIMESTAMP] [FATAL ERROR] Backup script failed at line $LINENO" >> /var/log/infra_health.log' ERR

# 1. Ensure backup directory exists
mkdir -p "$BACKUP_DIR"

# 2. Execute database dump and compress
echo "Starting database backup..."
docker exec "$CONTAINER_NAME" pg_dump -U "$DB_USER" postgres | gzip > "$BACKUP_FILE"

# 3. Verify backup success
if [ -f "$BACKUP_FILE" ]; then
    echo "Backup completed successfully: $BACKUP_FILE"
else
    echo "Error: Backup file was not created!"
    exit 1
fi

# 4. Cleanup old backups (Retention: 7 days)
echo "Cleaning up backups older than 7 days to preserve disk space..."
find "$BACKUP_DIR" -type f -name '*.sql.gz' -mtime +7 -exec rm {} \;

echo "Backup process finished."
