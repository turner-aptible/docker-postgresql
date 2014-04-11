#!/usr/bin/env bats

setup() {
  /etc/init.d/postgresql start
}

teardown() {
  /etc/init.d/postgresql stop
}

install-heartbleeder() {
  wget http://gobuild.io/github.com/titanous/heartbleeder/master/linux/amd64
  mv amd64 heartbleeder.zip
  unzip heartbleeder.zip -d heartbleeder/
}

uninstall-heartbleeder() {
  rm -rf heartbleeder.zip heartbleeder
}

@test "It should install PostgreSQL 9.3.4" {
  run /usr/lib/postgresql/9.3/bin/postgres --version
  [[ "$output" =~ "9.3.4"  ]]
}

@test "It should protect against CVE-2014-0160" {
  install-heartbleeder
  ./heartbleeder/heartbleeder -pg localhost
  uninstall-heartbleeder
}

@test "It should require a password" {
  run psql -U postgres -l

}

@test "It should use UTF-8 for the default encoding" {
  sudo -u postgres psql -l | grep en_US.UTF-8
}