#!/bin/bash

set -e

apt-get update
apt-get install \
    --no-install-recommends \
    --no-install-suggests \
    -y \
    ca-certificates \
    carton \
    curl \
    gcc \
    git \
    libc6-dev \
    libicu-dev \
    libicu60 \
    locales \
    make \
    postgresql \
    postgresql-10-pgtap \
    postgresql-contrib \
    postgresql-server-dev-10 \
    sudo

echo 'en_US.UTF-8 UTF-8' > /etc/locale.gen
locale-gen

make_extension() {
    local ORG=$1
    local REPO=$2
    local COMMIT=$3

    cd /tmp
    git clone https://github.com/$ORG/$REPO.git
    pushd $REPO
    git reset --hard $COMMIT
    make && make install
    popd
    rm -rf $REPO
}

make_extension 'metabrainz' 'postgresql-musicbrainz-collate' '958142e'
make_extension 'metabrainz' 'postgresql-musicbrainz-unaccent' 'b727896'

apt-get purge -y $BUILD_DEPS
apt-get autoremove -y
rm -rf /var/lib/apt/lists/*
