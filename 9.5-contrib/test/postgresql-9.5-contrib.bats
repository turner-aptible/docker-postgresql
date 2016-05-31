#!/usr/bin/env bats

source "${BATS_TEST_DIRNAME}/test_helper.sh"

@test "It should install PostgreSQL 9.5.2" {
  run /usr/lib/postgresql/9.5/bin/postgres --version
  [[ "$output" =~ "9.5.3"  ]]
}

@test "It should support PLV8" {
  sudo -u postgres psql --command "CREATE EXTENSION plv8;"
  sudo -u postgres psql --command "CREATE EXTENSION plls;"
  sudo -u postgres psql --command "CREATE EXTENSION plcoffee;"
}

@test "It should support tds_fdw" {
  sudo -u postgres psql --command "CREATE EXTENSION tds_fdw;"
}

@test "It should support plpythonu" {
  sudo -u postgres psql --command "CREATE EXTENSION plpythonu;"
}

@test "It should support plpython2u" {
  sudo -u postgres psql --command "CREATE EXTENSION plpython2u;"
}

@test "It should support plpython3u" {
  sudo -u postgres psql --command "CREATE EXTENSION plpython3u;"
}

@test "It should support mysql_fdw" {
  sudo -u postgres psql --command "CREATE EXTENSION mysql_fdw;"
}
