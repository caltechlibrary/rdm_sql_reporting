% dump-rdm-records.bash() dump-rdm-records.bash user manual
% R. S. Doiel
% August 17, 2022

# NAME

dump-rdm-records.bash

# SYNOPSIS

dump-rdm-records.bash REPO_ID

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
     sudo -u ubuntu dump-rdm-records.bash caltechdata
~~~

