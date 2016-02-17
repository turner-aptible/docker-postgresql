#!/usr/bin/env bats

@test "It should install PostgreSQL 9.3.11" {
  run /usr/lib/postgresql/9.3/bin/postgres --version
  [[ "$output" =~ "9.3.11"  ]]
}
