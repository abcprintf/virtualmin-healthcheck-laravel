#!/bin/bash

DOMAIN="abcprintf.com"
URL="https://${DOMAIN}/health"
STATE_FILE="/tmp/health-${DOMAIN}.count"
LOGFILE="/var/log/healthcheck-${DOMAIN}.log"
MAX_FAIL=2
SERVICE="php8.1-fpm"

# ตรวจสอบสถานะ HTTP (timeout ภายใน 3 วิ)
STATUS=$(curl -s -o /dev/null -w "%{http_code}" --max-time 3 --connect-timeout 2 "$URL")
TIME=$(date "+%a %b %d %H:%M:%S %Y")

if [ "$STATUS" != "200" ]; then
    echo "$TIME ❌ FAIL ($STATUS) from $URL" >> "$LOGFILE"
    COUNT=$(cat "$STATE_FILE" 2>/dev/null || echo 0)
    COUNT=$((COUNT + 1))
    echo $COUNT > "$STATE_FILE"

    if [ "$COUNT" -ge "$MAX_FAIL" ]; then
        echo "$TIME 🔁 Restarting $SERVICE due to $MAX_FAIL failures" >> "$LOGFILE"
        systemctl restart $SERVICE
        echo 0 > "$STATE_FILE"
    fi
else
    echo "$TIME ✅ OK ($STATUS)" >> "$LOGFILE"
    echo 0 > "$STATE_FILE"
fi