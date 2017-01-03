#!/usr/bin/env bats

source "${BATS_TEST_DIRNAME}/test_helper.sh"

PG_URL="postgresql://aptible:foobar@127.0.0.1:5432/db"

make_random_cert() {
  local cert_dir="${WORK_DIR}/cert"

  export SSL_CERTIFICATE_PATH="${dir}/server.crt"
  export SSL_KEY_PATH="${dir}/server.key"

  SUBJ="/C=US/ST=New York/L=New York/O=Example/CN=MyPostgreSQL"
  openssl req -nodes -new -x509 -sha256 -subj "$SUBJ" \
    -out "$SSL_CERTIFICATE_PATH" -keyout "$SSL_KEY_PATH"
}

@test "It should auto-generate a SSL certificate at --initialize, and reuse it at runtime" {
  PASSPHRASE=foobar run-database.sh --initialize

  run-database.sh 2>&1 &
  wait_for_pg

  # The right cert should work
  PGSSLMODE=verify-ca PGSSLROOTCERT="${CONF_DIRECTORY}/ssl/server.crt" psql "$PG_URL"

  # However, using another cert should trigger an error.
  make_random_cert
  PGSSLMODE=verify-ca PGSSLROOTCERT="$SSL_CERTIFICATE_PATH" run psql "$PG_URL"
  [[ ! "$status" -eq 0 ]]
}

@test "It should accept a certificate from the environment at --initialize" {
  make_random_cert
  SSL_KEY="$(cat "$SSL_KEY_PATH")" SSL_CERTIFICATE="$(cat "$SSL_CERTIFICATE_PATH")" \
    PASSPHRASE=foobar run-database.sh --initialize

  run-database.sh 2>&1 &
  wait_for_pg

  PGSSLMODE=verify-ca PGSSLROOTCERT="$SSL_CERTIFICATE_PATH" psql "$PG_URL"
}

@test "It should accept a replacement certificate from the environment at runtime" {
  PASSPHRASE=foobar run-database.sh --initialize

  make_random_cert
  SSL_KEY="$(cat "$SSL_KEY_PATH")" SSL_CERTIFICATE="$(cat "$SSL_CERTIFICATE_PATH")" \
    run-database.sh 2>&1 &
  wait_for_pg

  PGSSLMODE=verify-ca PGSSLROOTCERT="$SSL_CERTIFICATE_PATH" psql "$PG_URL"
}
