FROM ubuntu:focal
MAINTAINER Micheal Waltz <ecliptik@gmail.com>

# Set environment vars
ENV DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    LC_ALL=C.UTF-8 \
    LANGUAGE=en_US.UTF-8 \
    APP_DIR=/app \
    SIEGE_VERSION=4.1.5

# Create app dir
RUN mkdir -p ${APP_DIR}
WORKDIR ${APP_DIR}

# Install and build Siege from source
RUN set -ex && \
        buildDeps=' \
                build-essential \
                libssl-dev \
                curl \
        ' && \
        runDeps=' \
                ca-certificates \
        ' && \
        apt-get update && \
        apt-get install -y --no-install-recommends $buildDeps $runDeps && \
        curl -O https://download.joedog.org/siege/siege-${SIEGE_VERSION}.tar.gz && \
        tar -xvzf siege-${SIEGE_VERSION}.tar.gz && \
        cd siege-${SIEGE_VERSION} && \
        ./configure && \
        make && \
        make install && \
        cd ${APP_DIR} && \
        apt-get purge -y --auto-remove $buildDeps && \
        rm -rf /var/lib/apt/lists/* ${APP_DIR}/siege-${SIEGE_VERSION}*

# Copy siege files
COPY . ${APP_DIR}/

# App command
ENTRYPOINT [ "/usr/local/bin/siege" ]
CMD [ "--help" ]
