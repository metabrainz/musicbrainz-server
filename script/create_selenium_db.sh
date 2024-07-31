#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail

MB_SERVER_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/../" && pwd)
cd "$MB_SERVER_ROOT"

./script/create_test_db.sh SELENIUM

./admin/psql SELENIUM < ./t/sql/selenium.sql

if [[ $# -gt 0 ]]; then
    EXTRA_SQL="$1"
    if [[ -f "$EXTRA_SQL" ]]; then
        ./admin/psql SELENIUM < "$EXTRA_SQL"
    fi
fi

DROP_SQL=$(cat <<'SQL'
\set ON_ERROR_STOP 1
DROP EXTENSION IF EXISTS amqp CASCADE;
DROP SCHEMA IF EXISTS artwork_indexer CASCADE;
SQL
)
echo "$DROP_SQL" | ./admin/psql --system SELENIUM

SIR_DIR="${SIR_DIR:="$MB_SERVER_ROOT"/../sir}"

if [ -d "$SIR_DIR" ]; then
    ./admin/psql --system SELENIUM < "$SIR_DIR"/sql/CreateExtension.sql
    ./admin/psql SELENIUM < "$SIR_DIR"/sql/CreateFunctions.sql
    ./admin/psql SELENIUM < "$SIR_DIR"/sql/CreateTriggers.sql
fi

ARTWORK_INDEXER_DIR="${ARTWORK_INDEXER_DIR:="$MB_SERVER_ROOT"/../artwork-indexer}"

if [ -d "$ARTWORK_INDEXER_DIR" ]; then
    pushd "$ARTWORK_INDEXER_DIR"
    VENV_DIR="$([ -d .venv ] && echo .venv || echo venv)"
    . "$VENV_DIR"/bin/activate
    python indexer.py --config=config.selenium.ini --setup-schema
    popd
fi
