FROM aptible/ubuntu:16.04

RUN apt-get update \
  && apt-get install -yq python-dev build-essential python-pip \
  && pip install sslyze \
  && rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["/usr/local/bin/sslyze"]