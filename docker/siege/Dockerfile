FROM ubuntu:focal
ARG DEBIAN_FRONTEND=noninteractive

RUN set -eux; \
    apt-get update -qq; \
    apt-get install -qqq --yes \
        siege \
        jq; \
    rm -rf /var/lib/apt/lists/* /var/tmp/* /tmp/* /usr/share/man/* /root/.cache;

CMD ["/bin/bash", "--login"]
