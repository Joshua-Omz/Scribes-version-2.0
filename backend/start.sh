#!/bin/sh

set -e

echo "Running database migrations..."
if [ -z "$DATABASE_URL" ]; then
  echo "Error: DATABASE_URL environment variable is not set."
  exit 1
fi

migrate -path /app/migrations -database "$DATABASE_URL" up

echo "Starting API..."
exec /app/api
