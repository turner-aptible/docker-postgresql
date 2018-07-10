#!/bin/bash
set -o errexit
set -o nounset

IMG="$REGISTRY/$REPOSITORY:$TAG"

./test-ssl.sh "$IMG"
./test-restart.sh "$IMG"
./test-replication.sh "$IMG"

echo "#############"
echo "# Tests OK! #"
echo "#############"
