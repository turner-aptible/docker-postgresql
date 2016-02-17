#!/bin/bash

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
