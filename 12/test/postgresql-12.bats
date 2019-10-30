#!/usr/bin/env bats

@test "It should install PostgreSQL 12.0" {
  /usr/lib/postgresql/12/bin/postgres --version | grep "12.0"
}
