#!/bin/bash
set -o errexit
set -o nounset

IMG="$1"

PG_CONTAINER="postgres"
DATA_CONTAINER="${PG_CONTAINER}-data"

function cleanup {
  echo "Cleaning up"
  docker rm -f "$PG_CONTAINER" "$DATA_CONTAINER" >/dev/null 2>&1 || true
}

function wait_for_pg {
  for _ in $(seq 1 1000); do
    if docker exec -it "$PG_CONTAINER" gosu postgres psql db -c 'SELECT 1;' >/dev/null 2>&1; then
      return 0
    fi
    sleep 0.1
  done

  echo "DB never came online"
  docker logs "$PG_CONTAINER"
  return 1
}

trap cleanup EXIT
cleanup

echo "Creating data container"
docker create --name "$DATA_CONTAINER" "$IMG"

echo "Starting DB"
docker run -it --rm \
  -e USERNAME=user -e PASSPHRASE=pass -e DATABASE=db \
  --volumes-from "$DATA_CONTAINER" \
  "$IMG" --initialize \
  >/dev/null 2>&1

docker run -d --name="$PG_CONTAINER" \
  -e EXPOSE_HOST=127.0.0.1 -e EXPOSE_PORT_27217=27217 \
  --volumes-from "$DATA_CONTAINER" \
  "$IMG"

echo "Waiting for DB to come online"
wait_for_pg

echo "Verifying DB shutdown message isn't present"
docker logs "$PG_CONTAINER" 2>&1 | grep -vqi "database system is shut down"

echo "Restarting DB container"
date
docker top "$PG_CONTAINER"
docker restart -t 10 "$PG_CONTAINER"

echo "Waiting for DB to come back online"
wait_for_pg

echo "DB came back online; checking for clean shutdown and recovery"
date
docker logs "$PG_CONTAINER" 2>&1 | grep -qi "database system is shut down"
docker logs "$PG_CONTAINER" 2>&1 | grep -vqi "database system was not properly shut down"

echo "Attempting unclean shutdown"
docker kill -s KILL "$PG_CONTAINER"
docker start "$PG_CONTAINER"

echo "Waiting for DB to come back online"
wait_for_pg

docker logs "$PG_CONTAINER" 2>&1 | grep -qi "database system was not properly shut down"
