
# Connecting to Postgres running in Docker

Currently we deploy RDM via docker containers. This includes Postgres.
It would be terribly convient to have access to the Postgres running inside Docker without needing to use the docker wrapper command.

~~~
docker run --name $POSTRES_CONTAINER_NAME \
           -e POSTGRES_PASSWORD=$PG_PASSWORD \
           -it -p 5432:5432 postgres
~~~

If the port 5432 is not available (e.g. it is taken by another Postgres instance) in the host you can change the mapping to a free port .

Once the container port is mapped to the host's localhost port you
should be able to access it in the usual way using `psql`.

~~~
psql -h localhost -p 5432 -U <my-user> -d <my-database>
~~~


# Reference links

- [from stack overflow](https://stackoverflow.com/questions/37694987/connecting-to-postgresql-in-a-docker-container-from-outside)
