#!/usr/bin/env bats

@test "It should install PostgreSQL 9.5.2" {
  run /usr/lib/postgresql/9.5/bin/postgres --version
  [[ "$output" =~ "9.5.2"  ]]
}
