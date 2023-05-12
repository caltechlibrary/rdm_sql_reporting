
RDM SQL reporting
=================

This repository holds a collection of shell (Bash) scripts for working with the Postgres databases associated with Invenio RDM instances. In some cases the Bash scripts may include the use of tools from the [datatools project](https://github.com/caltechlibrary/datatools/latest/release), Stephen Dolan's [jq](https://stedolan.github.io/jq/), [Pandoc](https://pandoc.org), [PostgREST](https://postgrest.org) and [irdmtools](https://github.com/caltechlibrary/irdmtools). Bash scripts that interact with Postgres via the `psql` client or via datatools' [sql2csv](https://caltechlibrary.github.io/datatools/sql2csv.1.html).  The command line programs provided directly in this repository generate SQL documents that can be run in the Postgres client. The output from the client is then processed with common POSIX utilities (e.g. grep, sort, sed) or serve as input for the next stage of processing.

Requirements
------------

- make (e.g. GNU Make)
- Pandoc >= 3 (for generating HTML and man pages)
- bash
- datatools >= 1.2.2 (provides urlparse and sql2csv)
- Stephen Dolan's [jq](https://stedolan.github.io/jq/)
- Postgres >= 15
- PostgREST >= 11

More info
---------

Documentation provided in the [user manual](user-manual.html)

See [about](about.md) for credits

For questions see [GitHub Issues](https://github.com/caltechlibrary/rdm_sql_reporting/issues)

[License](LICENSE)

