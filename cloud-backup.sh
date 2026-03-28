#!/usr/bin/env bash
set -Eeuo pipefail

BACKUP_DIR="/srv/backups"
REMOTE="gdrive:home-server"

TIMESTAMP=$(date +%F_%H-%M-%S)
BACKUP_FILE="$BACKUP_DIR/home-server-$TIMESTAMP.tar.gz"

echo "=============================="
echo "CLOUD BACKUP START $(date)"
echo "=============================="

############################################
echo "[1] Creating local backup"

mkdir -p "$BACKUP_DIR"

tar -czf "$BACKUP_FILE" \
  /srv/docker \
  /usr/local/bin

############################################
echo "[2] Cleaning Google Drive backup"

sudo -u mauricio rclone delete "$REMOTE"

############################################
echo "[3] Uploading new backup"

sudo -u mauricio rclone copy "$BACKUP_FILE" "$REMOTE"

############################################
echo "[4] Removing local backup"

rm -f /srv/backups/*.tar.gz

echo "=============================="
echo "BACKUP COMPLETED"
echo "=============================="
