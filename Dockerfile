# Multi-stage build for Cloud189 Checkin
FROM node:18-alpine AS builder

WORKDIR /app

# Copy package files
COPY package.json yarn.lock ./

# Install dependencies
RUN yarn install --frozen-lockfile --production

# Final stage
FROM node:18-alpine

WORKDIR /app

# Install tzdata for timezone support
# Note: BusyBox crond is already included in Alpine
RUN apk add --no-cache tzdata

# Set default timezone to Asia/Shanghai
ENV TZ=Asia/Shanghai

# Copy node_modules from builder
COPY --from=builder /app/node_modules ./node_modules

# Copy application files
COPY package.json ./
COPY accounts.js ./
COPY src ./src

# Create directories for token storage and logs
RUN mkdir -p .token .logs

# Copy entrypoint script
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

# Environment variables
# CRON_SCHEDULE: cron schedule expression (default: run at 10:35 AM every day)
# RUN_IMMEDIATELY: whether to run immediately on container start (default: true)
ENV CRON_SCHEDULE="35 10 * * *" \
    RUN_IMMEDIATELY="true"

# Volume for token persistence
VOLUME ["/app/.token"]

ENTRYPOINT ["/docker-entrypoint.sh"]
