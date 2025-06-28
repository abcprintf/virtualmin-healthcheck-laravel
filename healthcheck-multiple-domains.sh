

#!/bin/bash

# List of domains to check
DOMAINS=("abcprintf.com" "abcprintf2.com" "abcprintf3.com")
MAX_FAIL=2
LOGDIR="/var/log"
STATE_DIR="/tmp"
SERVICE="php8.1-fpm"

for DOMAIN in "${DOMAINS[@]}"; do
    URL="https://${DOMAIN}/health"
    LOGFILE="$LOGDIR/healthcheck-${DOMAIN}.log"
    STATE_FILE="$STATE_DIR/health-${DOMAIN}.count"
    TIME=$(date "+%a %b %d %H:%M:%S %Y")

    STATUS=$(curl -s -o /dev/null -w "%{http_code}" --max-time 3 --connect-timeout 2 "$URL")

    if [ "$STATUS" != "200" ]; then
        echo "$TIME ❌ FAIL ($STATUS) from $URL" >> "$LOGFILE"
        COUNT=$(cat "$STATE_FILE" 2>/dev/null || echo 0)
        COUNT=$((COUNT + 1))
        echo $COUNT > "$STATE_FILE"

        if [ "$COUNT" -ge "$MAX_FAIL" ]; then
            echo "$TIME 🔁 Restarting $SERVICE for $DOMAIN due to $MAX_FAIL failures" >> "$LOGFILE"
            systemctl restart $SERVICE
            echo 0 > "$STATE_FILE"
        fi
    else
        echo "$TIME ✅ OK ($STATUS)" >> "$LOGFILE"
        echo 0 > "$STATE_FILE"
    fi
done