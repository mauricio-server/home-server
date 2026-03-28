#!/usr/bin/env bash
set -Eeuo pipefail

echo "======================================"
echo "SERVER MAINTENANCE START $(date)"
echo "======================================"

############################################
echo "[1] Disk usage before"
df -h

############################################
echo "[2] System update"
apt update -y
apt upgrade -y
apt autoremove -y
apt autoclean -y

############################################
echo "[3] Journal cleanup"
journalctl --vacuum-size=200M

############################################
echo "[4] Log cleanup"
find /var/log -type f -name "*.gz" -delete
find /var/log -type f -size +100M -delete

############################################
echo "[5] Docker cleanup (SAFE)"
docker image prune -f
docker network prune -f

############################################
echo "[6] Torrent cleanup"
DOWNLOADS="/srv/media/downloads"

find "$DOWNLOADS" -type f -name "*.parts" -mtime +2 -delete
find "$DOWNLOADS" -type f -name "*.tmp" -mtime +2 -delete
find "$DOWNLOADS" -type f -name "*.!qB" -mtime +2 -delete
find "$DOWNLOADS" -type f -size 0 -delete

find "$DOWNLOADS" -type d -empty -delete

############################################
echo "[7] Arr cache cleanup"

find /srv/docker/radarr/MediaCover -type f -mtime +30 -delete 2>/dev/null || true
find /srv/docker/sonarr/MediaCover -type f -mtime +30 -delete 2>/dev/null || true

############################################
echo "[8] Samba cleanup"
rm -rf /var/cache/samba/* 2>/dev/null || true
find /var/log/samba -type f -mtime +7 -delete 2>/dev/null || true

############################################
echo "[9] SSD TRIM"
fstrim -av

############################################
echo "[10] Disk usage after"
df -h

echo "======================================"
echo "MAINTENANCE COMPLETE"
echo "======================================"
