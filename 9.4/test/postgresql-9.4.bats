#!/usr/bin/env bats

@test "It should install PostgreSQL 9.4.7" {
  run /usr/lib/postgresql/9.4/bin/postgres --version
  [[ "$output" =~ "9.4.8"  ]]
}
