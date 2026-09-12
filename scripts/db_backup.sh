#!/usr/bin/env bash

set -eo pipefail

BACKUP_DIR="/var/backups/db"
TIMESTAMP=$(date "+%Y%m%d")
BACKUP_FILE="${BACKUP_DIR}/db_backup_${TIMESTAMP}.sql.gz"
CONTAINER_NAME="postgres_db"
DB_USER="trainee"
DB_NAME="traineedb"

echo "[INFO] Starting database backup for '${DB_NAME}'..."

mkdir -p "$BACKUP_DIR"

# Execute pg_dump inside container, stream output, and gzip compress
docker exec "$CONTAINER_NAME" pg_dump -U "$DB_USER" "$DB_NAME" | gzip > "$BACKUP_FILE"

if [ -s "$BACKUP_FILE" ]; then
    FILESIZE=$(du -h "$BACKUP_FILE" | awk '{print $1}')
    echo "[SUCCESS] Backup completed: ${BACKUP_FILE} (${FILESIZE})"
else
    echo "[ERROR] Backup failed or generated an empty file." >&2
    exit 1
fi
