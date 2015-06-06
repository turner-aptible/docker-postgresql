# ![](https://gravatar.com/avatar/11d3bc4c3163e3d238d558d5c9d98efe?s=64) aptible/postgresql
[![Docker Repository on Quay.io](https://quay.io/repository/aptible/postgresql/status "Docker Repository on Quay.io")](https://quay.io/repository/aptible/postgresql)

PostgreSQL, on top of Debian Wheezy.

## Installation and Usage

    docker pull quay.io/aptible/postgresql

This is an image conforming to the [Aptible database specification](https://support.aptible.com/topics/paas/deploy-custom-database/). To run a server for development purposes, execute

    docker create --name data quay.io/aptible/postgresql
    docker run --volumes-from data -e USERNAME=aptible -e PASSPHRASE=pass -e DB=db quay.io/aptible/postgresql --initialize
    docker run --volumes-from data -P quay.io/aptible/postgresql

The first command sets up a data container named `data` which will hold the configuration and data for the database. The second command creates a PostgreSQL instance with a username, passphrase and database name of your choice. The third command starts the database server.

### SSL

The PostgreSQL server is configured to enforce SSL for any TCP connection. **Important note:** Because the key and certificate used for SSL negotiation are included in the Docker image, and shared by all Docker clients running the same version of the image, a PostgreSQL server launched with just `docker run` is **NOT** suitable for production.

To generate a unique key/certificate pair, you have two options:

1. Build directly from the Dockerfile, disabling caching:

        docker build --no-cache .

2. Initialize a new key and certificate in the host volume and mount that directory into the Docker container, as follows:

        cd <host-mountpoint>/ssl
        openssl req -new -newkey rsa:1024 -days 365000 -nodes -x509 \
          -keyout server.key -subj "/CN=PostgreSQL" -out server.crt
        chmod og-rwx server.key
        docker run -v <host-mountpoint>/ssl:/etc/postgresql/9.4/ssl -u root \
          quay.io/aptible/postgresql chown -R postgres:postgres /etc/postgresql/9.4
        docker run -v <host-mountpoint>/ssl:/etc/postgresql/9.4/ssl \
          quay.io/aptible/postgresql

## Available Tags

* `latest`: Currently PostgreSQL 9.4.2

## Tests

Tests are run as part of the `Dockerfile` build. To execute them separately within a container, run:

    bats test

## Deployment

To push the Docker image to Quay, run the following command:

    make release

## Copyright and License

MIT License, see [LICENSE](LICENSE.md) for details.

Copyright (c) 2014 [Aptible](https://www.aptible.com) and contributors.

[<img src="https://s.gravatar.com/avatar/f7790b867ae619ae0496460aa28c5861?s=60" style="border-radius: 50%;" alt="@fancyremarker" />](https://github.com/fancyremarker)
