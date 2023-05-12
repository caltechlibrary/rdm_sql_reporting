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

# EXAMPLES

Backup the Postgres running for caltechdata running on CaltechDATA.

~~~shell
     sudo -u ubuntu dump-rdm-records.bash caltechdata
~~~

