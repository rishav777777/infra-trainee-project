#!/usr/bin/env bash

# Enable strict error handling (Code Quality Upgrade)
set -e
set -u

LOG_FILE="/var/log/infra_health.log"
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
APP_CONTAINER="web_app"
DISK_THRESHOLD=85

# Ensure log file exists
touch "$LOG_FILE"

# 1. Resource Metrics Collection
# CPU: Calculate usage by subtracting idle percentage from 100
CPU_IDLE=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print int($1)}')
CPU_USAGE=$((100 - CPU_IDLE))

# RAM: Calculate percentage used from free command
RAM_TOTAL=$(free -m | awk '/^Mem:/{print $2}')
RAM_USED=$(free -m | awk '/^Mem:/{print $3}')
RAM_USAGE=$(( RAM_USED * 100 / RAM_TOTAL ))

# Disk: Root filesystem capacity usage percentage
DISK_USAGE=$(df / | awk 'NR==2 {gsub("%","",$5); print $5}')

# 2. Service & Container Status
DOCKER_STATUS="INACTIVE"
if systemctl is-active --quiet docker; then
    DOCKER_STATUS="ACTIVE"
fi

CONTAINER_STATUS="STOPPED"
if [ "$(docker inspect -f '{{.State.Running}}' "$APP_CONTAINER" 2>/dev/null)" = "true" ]; then
    CONTAINER_STATUS="RUNNING"
fi

# 3. Terminal Output
echo "=========================================="
echo " Infrastructure Health Check - $TIMESTAMP"
echo "=========================================="
echo "CPU Utilization  : ${CPU_USAGE}%"
echo "RAM Utilization  : ${RAM_USAGE}% (${RAM_USED}MB / ${RAM_TOTAL}MB)"
echo "Root Disk Usage  : ${DISK_USAGE}% (Threshold: ${DISK_THRESHOLD}%)"
echo "Docker Daemon    : ${DOCKER_STATUS}"
echo "App Container    : ${CONTAINER_STATUS} ($APP_CONTAINER)"
echo "------------------------------------------"

# 4. Threshold & Alert Logic
WARNING_TRIGGERED=0

if [ "$DISK_USAGE" -gt "$DISK_THRESHOLD" ]; then
    echo "[WARNING] Root disk capacity exceeds ${DISK_THRESHOLD}%: currently at ${DISK_USAGE}%"
    echo "[$TIMESTAMP] [WARNING] Root disk capacity exceeded: ${DISK_USAGE}%" >> "$LOG_FILE"
    WARNING_TRIGGERED=1
fi

if [ "$CONTAINER_STATUS" != "RUNNING" ]; then
    echo "[WARNING] Web application container '${APP_CONTAINER}' is not running!"
    echo "[$TIMESTAMP] [WARNING] Application container '${APP_CONTAINER}' is STOPPED" >> "$LOG_FILE"
    WARNING_TRIGGERED=1
fi

if [ "$WARNING_TRIGGERED" -eq 0 ]; then
    echo "[OK] All system health checks within nominal thresholds."
    echo "[$TIMESTAMP] [INFO] System healthy. CPU:${CPU_USAGE}% RAM:${RAM_USAGE}% DISK:${DISK_USAGE}%" >> "$LOG_FILE"
fi
