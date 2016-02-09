#!/usr/bin/env bats

setup() {
  export OLD_DATA_DIRECTORY="$DATA_DIRECTORY"
  export DATA_DIRECTORY=/tmp/datadir
  mkdir "$DATA_DIRECTORY"
  PASSPHRASE=foobar /usr/bin/run-database.sh --initialize
  /usr/bin/run-database.sh > /tmp/postgres.log 2>&1 &
  until /etc/init.d/postgresql status; do sleep 0.1; done
}

teardown() {
  /etc/init.d/postgresql stop
  while /etc/init.d/postgresql status; do sleep 0.1; done
  rm -rf "$DATA_DIRECTORY"
  export DATA_DIRECTORY="$OLD_DATA_DIRECTORY"
  unset OLD_DATA_DIRECTORY
  rm -f "/etc/postgresql/${PG_VERSION}/main/postgresql.conf"
}

install-heartbleeder() {
  wget http://gobuild.io/github.com/titanous/heartbleeder/master/linux/amd64
  mv amd64 heartbleeder.zip
  unzip heartbleeder.zip -d heartbleeder/
}

uninstall-heartbleeder() {
  rm -rf heartbleeder.zip heartbleeder
}

@test "It should bring up a working PostgreSQL instance" {
  su postgres -c "psql --command \"CREATE TABLE foo (i int);\""
  su postgres -c "psql --command \"INSERT INTO foo VALUES (1234);\""
  run su postgres -c "psql --command \"SELECT * FROM foo;\""
  [ "$status" -eq "0" ]
  [ "${lines[0]}" = "  i   " ]
  [ "${lines[1]}" = "------" ]
  [ "${lines[2]}" = " 1234" ]
  [ "${lines[3]}" = "(1 row)" ]
}

@test "It should protect against CVE-2014-0160" {
  skip
  install-heartbleeder
  ./heartbleeder/heartbleeder -pg localhost
  uninstall-heartbleeder
}

@test "It should require a password" {
  run psql -U postgres -l
  [ "$status" -ne "0" ]
}

@test "It should use UTF-8 for the default encoding" {
  su postgres -c "psql -l" | grep en_US.utf8
}

@test "It should support PostGIS" {
  run su postgres -c "psql --command \"CREATE EXTENSION postgis;\""
  [ "$status" -eq "0" ]
}

@test "It should dump to stdout by default" {
  run /usr/bin/run-database.sh --dump postgresql://aptible:foobar@127.0.0.1:5432/db
  [ "$status" -eq "0" ]
  [ "${lines[1]}" = "-- PostgreSQL database dump" ]
  [ "${lines[-2]}" = "-- PostgreSQL database dump complete" ]
}

@test "It should restore from stdin by default" {
  /usr/bin/run-database.sh --dump postgresql://aptible:foobar@127.0.0.1:5432/db > /tmp/restore-test
  echo "CREATE TABLE foo (i int);" >> /tmp/restore-test
  echo "INSERT INTO foo VALUES (1);" >> /tmp/restore-test
  run /usr/bin/run-database.sh --restore postgresql://aptible:foobar@127.0.0.1:5432/db < /tmp/restore-test
  rm /tmp/restore-test
  [ "$status" -eq "0" ]
  [ "${lines[-2]}" = "CREATE TABLE" ]
  [ "${lines[-1]}" = "INSERT 0 1" ]
}

@test "It should dump to /dump-output if /dump-output exists" {
  touch /dump-output
  run /usr/bin/run-database.sh --dump postgresql://aptible:foobar@127.0.0.1:5432/db
  [ "$status" -eq "0" ]
  [ "$output" = "" ]
  run cat dump-output
  rm /dump-output
  [ "${lines[1]}" = "-- PostgreSQL database dump" ]
  [ "${lines[-2]}" = "-- PostgreSQL database dump complete" ]
}

@test "It should restore from /restore-input if /restore-input exists" {
  /usr/bin/run-database.sh --dump postgresql://aptible:foobar@127.0.0.1:5432/db > /restore-input
  echo "CREATE TABLE foo (i int);" >> /restore-input
  echo "INSERT INTO foo VALUES (1);" >> /restore-input
  run /usr/bin/run-database.sh --restore postgresql://aptible:foobar@127.0.0.1:5432/db
  rm /restore-input
  [ "$status" -eq "0" ]
  [ "${lines[-2]}" = "CREATE TABLE" ]
  [ "${lines[-1]}" = "INSERT 0 1" ]
}

@test "It should create a replication user and print a connection URL" {
  run /usr/bin/run-database.sh --activate-leader postgresql://aptible:foobar@127.0.0.1:5432/db
  [ "$status" -eq "0" ]
  run psql --command '\dt' $output
}

@test "It should set up a follower" {
  export FOLLOWER_DIRECTORY=/tmp/follower
  FOLLOWER_DATA="${FOLLOWER_DIRECTORY}/data"
  FOLLOWER_CONF="${FOLLOWER_DIRECTORY}/conf"
  FOLLOWER_RUN="${FOLLOWER_DIRECTORY}/run"
  mkdir -p "$FOLLOWER_DIRECTORY"

  MASTER_PORT=5432
  SLAVE_PORT=5433

  # Bring over master conf as template for slave. Use empty data dir.
  cp -pr "$CONF_DIRECTORY" "$FOLLOWER_CONF"
  mkdir "$FOLLOWER_DATA"
  mkdir "$FOLLOWER_RUN" && chown postgres:postgres "$FOLLOWER_RUN"

  export $(/usr/bin/run-database.sh --activate-leader postgresql://aptible:foobar@127.0.0.1:$MASTER_PORT/db)

  DATA_DIRECTORY="$FOLLOWER_DATA" CONF_DIRECTORY="$FOLLOWER_CONF" /usr/bin/run-database.sh --initialize-follower

  su postgres -c "/usr/lib/postgresql/$PG_VERSION/bin/postgres -D "$FOLLOWER_DIRECTORY" \
                  -c config_file=$FOLLOWER_CONF/main/postgresql.conf \
                  -c port=$SLAVE_PORT -c data_directory=$FOLLOWER_DATA \
                  -c external_pid_file=$FOLLOWER_RUN/9.4-main.pid" &

  until su postgres -c "psql --command '\dt' -p $SLAVE_PORT"; do sleep 0.1; done

  su postgres -c "psql -p $MASTER_PORT --command \"CREATE TABLE foo (i int);\""
  su postgres -c "psql -p $MASTER_PORT --command \"INSERT INTO foo VALUES (1234);\""
  until su postgres -c "psql -p $SLAVE_PORT --command \"SELECT * FROM foo;\""; do sleep 0.1; done
  run su postgres -c "psql -p $SLAVE_PORT --command \"SELECT * FROM foo;\""
  [ "$status" -eq "0" ]
  [ "${lines[0]}" = "  i   " ]
  [ "${lines[1]}" = "------" ]
  [ "${lines[2]}" = " 1234" ]
  [ "${lines[3]}" = "(1 row)" ]

  kill $(cat $FOLLOWER_RUN/9.4-main.pid)
  rm -rf $FOLLOWER_DIRECTORY
}
