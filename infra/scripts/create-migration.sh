#!/usr/bin/env sh
set -eu

DESCRIPTION="${1:-}"

if [ -z "$DESCRIPTION" ]; then
  echo "Usage: create-migration.sh <description>"
  echo "Example: create-migration.sh create_users_table"
  exit 1
fi

MIGRATIONS_DIR="infra/migrations"

LAST=$(ls "$MIGRATIONS_DIR"/V*.sql 2>/dev/null | grep -oE 'V[0-9]+__' | grep -oE '[0-9]+' | sort -n | tail -1)
NEXT=$(printf "%03d" $((${LAST:-0} + 1)))

FILENAME="$MIGRATIONS_DIR/V${NEXT}__${DESCRIPTION}.sql"
touch "$FILENAME"
echo "Created: $FILENAME"
