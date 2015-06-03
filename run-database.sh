#!/bin/bash

command="/usr/lib/postgresql/9.4/bin/postgres -D "$DATA_DIRECTORY" -c config_file=/etc/postgresql/9.4/main/postgresql.conf"

if [[ "$1" == "--initialize" ]]; then
  chown -R postgres:postgres "$DATA_DIRECTORY"

  su postgres <<COMMANDS
    /usr/lib/postgresql/9.4/bin/initdb -D "$DATA_DIRECTORY"
    /etc/init.d/postgresql start
    psql --command "CREATE USER ${USERNAME:-aptible} WITH SUPERUSER PASSWORD '$PASSPHRASE'"
    psql --command "CREATE DATABASE ${DATABASE:-db}"
    /etc/init.d/postgresql stop
COMMANDS

elif [[ "$1" == "--client" ]]; then
  [ -z "$2" ] && echo "docker run -it aptible/postgresql --client postgresql://..." && exit
  psql "$2"

elif [[ "$1" == "--dump" ]]; then
  [ -z "$2" ] && echo "docker run aptible/postgresql --dump postgresql://... > dump.psql" && exit
  pg_dump "$2"

elif [[ "$1" == "--restore" ]]; then
  [ -z "$2" ] && echo "docker run -i aptible/postgresql --restore postgresql://... < dump.psql" && exit
  psql "$2"

elif [[ "$1" == "--readonly" ]]; then
  echo "Starting PostgreSQL in read-only mode..."
  su postgres -c "$command --default_transaction_read_only=on"

else
  su postgres -c "$command"

fi
