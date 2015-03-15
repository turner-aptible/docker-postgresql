#!/bin/bash

if [[ "$1" == "--initialize" ]]; then
  chown -R postgres:postgres "$DATA_DIRECTORY"

  su postgres <<COMMANDS
    /usr/lib/postgresql/9.3/bin/initdb -D "$DATA_DIRECTORY"
    /etc/init.d/postgresql start
    psql --command "CREATE USER ${USERNAME:-aptible} WITH SUPERUSER PASSWORD '$PASSPHRASE'"
    psql --command "CREATE DATABASE ${DATABASE:-db}"
    /etc/init.d/postgresql stop
COMMANDS

  exit
fi

# Run postgres in the foreground so the docker container stays alive.
su postgres -c "/usr/lib/postgresql/9.3/bin/postgres -D "$DATA_DIRECTORY" -c config_file=/etc/postgresql/9.3/main/postgresql.conf"
