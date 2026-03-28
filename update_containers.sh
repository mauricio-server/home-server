#!/usr/bin/env bash
set -Eeuo pipefail

BACKUP_DIR="/srv/backup"
SOURCE_DIR="/srv/docker"
RETAIN_BACKUPS=3

CONTAINERS=(qbittorrent radarr sonarr prowlarr bazarr portainer)

timestamp() {
  date +%F_%H-%M-%S
}

log() {
  printf '[%s] %s\n' "$(date +'%F %T')" "$*"
}

############################################
log "Starting container update"

############################################
log "Creating backup"

BACKUP_PATH="$BACKUP_DIR/docker-stack-$(timestamp)"
mkdir -p "$BACKUP_PATH"

rsync -aHAX "$SOURCE_DIR/" "$BACKUP_PATH/docker/"

############################################
log "Cleaning old backups"

ls -dt $BACKUP_DIR/docker-stack-* 2>/dev/null | tail -n +$((RETAIN_BACKUPS+1)) | xargs -r rm -rf

############################################
log "Pulling images"

for c in "${CONTAINERS[@]}"; do
  docker pull lscr.io/linuxserver/$c:latest 2>/dev/null || true
done

docker pull portainer/portainer-ce:latest

############################################
log "Restarting containers"

for c in "${CONTAINERS[@]}"; do
  if docker ps --format '{{.Names}}' | grep -q "^$c$"; then
    docker restart "$c"
  fi
done

############################################
log "Cleaning old images"
docker image prune -f

log "UPDATE COMPLETED"
