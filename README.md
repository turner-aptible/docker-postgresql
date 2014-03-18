# ![](https://gravatar.com/avatar/11d3bc4c3163e3d238d558d5c9d98efe?s=64) aptible/postgresql

PostgreSQL, on top of Ubuntu 12.10.

## Installation and Usage

    docker pull quay.io/aptible/postgresql
    docker run quay.io/aptible/postgresql [options]

### Initializing an Attached Data Volume

    id=$(docker run -P -d quay.io/aptible/postgresql)
    docker cp $id:/var/lib/postgresql /host/volume
    docker stop $id

### Creating a database user with password

    docker run -v /host/volume/postgresql:/var/lib/postgresql quay.io/aptible/postgresql sh -c "/etc/init.d/postgresql start && psql --command \"CREATE USER user WITH SUPERUSER PASSWORD 'password';\""

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
