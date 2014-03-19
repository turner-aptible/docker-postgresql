# ![](https://gravatar.com/avatar/11d3bc4c3163e3d238d558d5c9d98efe?s=64) aptible/postgresql

PostgreSQL, on top of Ubuntu 12.10.

## Installation and Usage

    docker pull quay.io/aptible/postgresql
    docker run quay.io/aptible/postgresql

This will launch a PostgreSQL server that enforces SSL for any TCP connection. **Important note:** Because the key and certificate used for SSL negotiation are included in the Docker image, and shared by all Docker clients running the same version of the image, a PostgreSQL server launched with just `docker run` is **NOT** suitable for production.

To generate a unique key/certificate pair, you have two options:

1. Build directly from the Dockerfile, disabling caching:

        docker build --no-cache .

2. Initialize a new key and certificate in the host volume (in the PostgreSQL data directory) and mount that directory into the Docker container, as described below.

### Initializing an attached data volume

    id=$(docker run -P -d quay.io/aptible/postgresql)
    docker cp $id:/var/lib/postgresql <host-volume>
    docker stop $id

### Creating a database user with password

    docker run -v <host-volume>:/var/lib/postgresql quay.io/aptible/postgresql sh -c "/etc/init.d/postgresql start && psql --command \"CREATE USER user WITH SUPERUSER PASSWORD 'password';\""

### Creating a database

    docker run -v <host-volume>:/var/lib/postgresql quay.io/aptible/postgresql sh -c "/etc/init.d/postgresql start && psql --command \"CREATE DATABASE db;\""

## Available Tags

* `latest`: Currently PostgreSQL 9.3.3

## Tests

Tests are run as part of the `Dockerfile` build. To execute them separately within a container, run:

    bats test

## Deployment

To push the Docker image to Quay, run the following command:

    make release

## Copyright and License

MIT License, see [LICENSE](LICENSE.md) for details.

Copyright (c) 2014 [Aptible](https://www.aptible.com), [Frank Macreery](https://github.com/fancyremarker), and contributors.
