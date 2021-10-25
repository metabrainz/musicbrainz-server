#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE[0]}")/../"

QUERY=$(cat <<'SQL'
SELECT json_build_object('tup_inserted', tup_inserted,
                         'tup_updated', tup_updated,
                         'tup_deleted', tup_deleted)
  FROM pg_stat_database
 WHERE datname = current_database();
SQL
)

exec ./admin/psql SELENIUM -- -qAtc "$QUERY"
