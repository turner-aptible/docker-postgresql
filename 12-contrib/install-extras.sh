#!/bin/bash
set -o errexit
set -o nounset
set -x

# Install packaged extensions first
apt-install "^postgresql-plperl-${PG_VERSION}$"
