#!/usr/bin/env bats

@test "It should install PostgreSQL 9.3.3" {
  run /usr/lib/postgresql/9.3/bin/postgres --version
  [[ "$output" =~ "9.3.3"  ]]
}

@test "It should enforce SSL" {
  skip
}

@test "It should require a password" {
  skip
}
