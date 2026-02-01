#!/bin/sh
set -e

# Function to run the checkin task
run_checkin() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Running Cloud189 Checkin..."
    cd /app && node --unhandled-rejections=strict ./src/app.js
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Checkin completed."
}

# Export environment variables for cron
printenv | grep -E '^(TY_|SENDKEY|TELEGRAM_|WECOM_|WX_PUSHER_|PUSH_PLUS_|SHOWDOC_|BARK_|CLOUD189_)' > /app/.env.cron 2>/dev/null || true

# Create cron job script
cat > /app/run-checkin.sh << 'EOF'
#!/bin/sh
# Load environment variables
set -a
. /app/.env.cron 2>/dev/null || true
set +a
cd /app && node --unhandled-rejections=strict ./src/app.js >> /app/.logs/cron.log 2>&1
EOF
chmod +x /app/run-checkin.sh

# Setup cron job
echo "${CRON_SCHEDULE} /app/run-checkin.sh" > /etc/crontabs/root

# Run immediately if configured
if [ "${RUN_IMMEDIATELY}" = "true" ]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Running initial checkin..."
    run_checkin || echo "Initial checkin failed, but continuing..."
fi

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Starting cron daemon with schedule: ${CRON_SCHEDULE}"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Timezone: ${TZ}"

# Start cron daemon in foreground
exec crond -f -l 2
