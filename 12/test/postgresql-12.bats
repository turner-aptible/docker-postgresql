#!/usr/bin/env bats

@test "It should install PostgreSQL 12.1" {
  /usr/lib/postgresql/12/bin/postgres --version | grep "12.1"
}
