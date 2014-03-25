#!/usr/bin/env bats

setup() {
  /etc/init.d/postgresql start
}

teardown() {
  /etc/init.d/postgresql stop
}

@test "It should install PostgreSQL 9.3.4" {
  run /usr/lib/postgresql/9.3/bin/postgres --version
  [[ "$output" =~ "9.3.4"  ]]
}

@test "It should enforce SSL" {
  skip
}

@test "It should require a password" {
  skip
}

@test "It should use UTF-8 for the default encoding" {
  psql -l | grep en_US.UTF-8
}