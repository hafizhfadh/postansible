#!/bin/bash
set -e
PGPOOL_HOST=172.28.0.10
PGPOOL_PORT=5432
echo "Testing Pgpool-II connectivity at $PGPOOL_HOST:$PGPOOL_PORT..."
nc -z $PGPOOL_HOST $PGPOOL_PORT && echo "Pgpool-II is reachable."

echo "Testing query routing..."
psql -h $PGPOOL_HOST -p $PGPOOL_PORT -U postgres -c "SELECT now();"
