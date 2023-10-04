#!/bin/bash

function usage() {
    APP_NAME=$(basename "$0")
    cat <<EOT
% ${APP_NAME}(1) user manual
% R. S. Doiel
% 2022-10-20

# NAME

${APP_NAME}

# SYNOPSIS

${APP_NAME} REPO_ID [YYYY-MM-DD]

# DESCRIPTION

Load a snapshot of an RDM database replacing the existing database
if necessary.

# EXAMPLE

~~~
    ${APP_NAME} caltechdata 2022-10-20
~~~

EOT

}

function restore_postgres_from() {
	BACKUP_FILE="$1"
	# Need to figure out which zcat to use, macOS it's gzcat, everything else seems to be zcat.
	if command -v zcat &>/dev/null; then
		ZCAT="zcat"
	elif command -v gzcat &>/dev/null; then
		ZCAT="gzcat"
	fi
	dropdb --if-exists "${DB_NAME}"
	createdb "${DB_NAME}"
	"$ZCAT" "${BACKUP_FILE}" | psql -d "${DB_NAME}"
}

function run_restore() {
	REPO_ID="$1"
	SQL_FILE="$2"
	#
	# Sanity check our requiremented environment
	#
	SCRIPTNAME="$(readlink -f "$0")"
	DNAME="$(dirname "${SCRIPTNAME}")"
	cd "${DNAME}" || exit 1
	# Source the file "${REPO_ID}_postgres_env.cfg" it contains the
	# value $DB_USERNAME.
	if [ -f "${REPO_ID}_postgres_env.cfg" ]; then
		. "${REPO_ID}_postgres_env.cfg"
	fi
	if [ "$DB_NAME" = "" ]; then
		echo "The environment variable DB_NAME is not set."
		exit 1
	fi
	if [ "$DB_USERNAME" = "" ]; then
		echo "The environment variable DB_USERNAME is not set."
		exit 1
	fi
	restore_postgres_from "$SQL_FILE"
}


#
# Main process
#
for ARG in "$@"; do
    case $ARG in
    -h | -help | --help)
        usage
        exit 0
        ;;
    esac
done

case "$#" in
	"0")
    usage
    exit 1
	;;
	"1")
	REPO_ID="$1"
	SNAPSHOT="$(date +%Y-%m-%d)"
	SQL_FILE="sql-dumps/${REPO_ID}-dump_${SNAPSHOT}.sql.gz"
	;;
	*)
	REPO_ID="$1"
	SNAPSHOT="$2"
	SQL_FILE="sql-dumps/${REPO_ID}-dump_${SNAPSHOT}.sql.gz"
	;;
esac
if [ ! -f "${REPO_ID}_postgres_env.cfg" ]; then
	echo "Can't find ${REPO_ID}_postgres_env.cfg configuration file"
	exit 1
fi
if [ ! -f "${SQL_FILE}" ]; then
    echo "Can't find ${SQL_FILE}, aborting"
    exit 1
fi
run_restore "$REPO_ID" "$SQL_FILE"
