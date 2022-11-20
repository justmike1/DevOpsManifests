#!/bin/bash

set -e

google_sql_migrator_folder="${BASH_SOURCE[0]%/*}/"
PG_USER=$(id -un)

# source venv
. ./venv/bin/activate

# start postgres service
if ! launchctl list | grep homebrew | grep postgres; then brew services start postgresql; fi

postgres_exists() {
    _o=$(psql postgres -tAc "SELECT 1 FROM pg_roles WHERE rolname='postgres'")
    if [[ $_o == 1 ]]; then return 0; else return 1;fi
}

if ! postgres_exists; then
    psql -U "$PG_USER" -d postgres -c "CREATE ROLE postgres WITH LOGIN SUPERUSER PASSWORD 'password';"
fi

pushd "$google_sql_migrator_folder" &> /dev/null || exit 1
python migrate.py --ex_sql develop --im_sql localhost --ex_databases "$@"
popd &> /dev/null || exit 1
