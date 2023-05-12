#!/bin/bash
APP_NAME="$(basename "$0")"

#
# This script can bring invenio-rdm down in an orderly fashion
# or start it back up.
#

function usage() {
	cat <<EOT
% ${APP_NAME}() ${APP_NAME} user manual
% R. S. Doiel
% August 17, 2022

# NAME

${APP_NAME}

# SYNOPSIS

${APP_NAME} REPO_ID

# DESCRIPTION

Dump the Postgres database for an Invenio RDM instance.
The resulting SQL files will include a datestamp in their
name and be saved to a directory called "sql-dumps".

# SETUP

This script loads a configuration environment based on
the repository name. The configuration file looks like
this

~~~
export DB_NAME="<DB_NAME_GOES_HERE>"
export DB_USERNAME="<DB_USERNAME_GOES_HERE>"
~~~

You'd replace the contents in the angle brackes with appropriate
values. The repository id (name) is included in the name of
the configuration file. E.g. caltechauthors repository name would
use a configuration file of "caltechauthors_postgres_env.cfg".

# EXAMPLES

Backup the Postgres running for caltechdata running on CaltechDATA.

~~~shell
     sudo -u ubuntu ${APP_NAME} caltechdata
~~~

EOT

}

function backup_postgres_to() {
	DOCKER="$1"
	REPO_ID="$2"
	CONTAINER="${REPO_ID}_db_1"
	BACKUP_DIR="$3"
	if [ "${CONTAINER}" = "" ]; then
		echo "Missing the container name"
		exit 1
	fi
	if [ "${BACKUP_DIR}" = "" ]; then
		echo "Missing the backup directory name"
		exit 1
	fi
	if [ ! -d "${BACKUP_DIR}" ]; then
		echo "${BACKUP_DIR} does not exist"
		exit 1
	fi
	BACKUP_FILE="${BACKUP_DIR}/${REPO_ID}-dump_$(date +%Y-%m-%d).sql"
	$DOCKER container exec \
		"${CONTAINER}" /usr/bin/pg_dump \
		--username="${DB_USERNAME}" \
		--column-inserts \
		"${DB_NAME}" \
		>"${BACKUP_FILE}"
	if [ -f "${BACKUP_FILE}" ]; then
		gzip "${BACKUP_FILE}"
	else
		echo "WARNING: ${BACKUP_FILE} not found!"
	fi
}

function run_backups() {
	#
	# Sanity check our requiremented environment
	#
	SCRIPTNAME="$(readlink -f "$0")"
	DNAME="$(dirname "${SCRIPTNAME}")"
	cd "${DNAME}" || exit 1
	# Source the file "postgres_env.cfg" it contains the
	# value $DB_USERNAME.
	if [ -f postgres_env.cfg ]; then
		. postgres_env.cfg
	fi
	if [ "$DB_NAME" = "" ]; then
		echo "The environment variable DB_NAME is not set."
		exit 1
	fi
	if [ "$DB_USERNAME" = "" ]; then
		echo "The environment variable DB_USERNAME is not set."
		exit 1
	fi

	DOCKER="/usr/bin/docker"
	if [ ! -f "${DOCKER}" ]; then
		DOCKER=$(which docker)
	fi
	if [ "${DOCKER}" = "" ]; then
		echo "Cannot find docker program, aborting"
		exit 1
	fi
	backup_postgres_to "$DOCKER" "$1" "$2"
}

#
# Main entry script point.
#
case "$1" in
h | help | -h | --help)
	usage
	exit 0
	;;
*)
	if [ "$1" = "" ]; then
		usage
		exit 1
	fi
	mkdir -p sql-dumps
	run_backups "$1" "sql-dumps"
	;;
esac
