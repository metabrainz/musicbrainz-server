m4_include(`macros.m4')m4_dnl
m4_dnl The following comment does not apply to this file.
`#' Automatically generated, do not edit.
FROM postgres:9.5.4

ARG DEBIAN_FRONTEND=noninteractive

`#' install_extensions.sh removes certain build dependencies that we need, so we
`#' can't install everything here.
`#' Note: curl is also a dependency of carton.
RUN apt_install(`curl sudo')

RUN cd /tmp && \
    curl -O https://raw.githubusercontent.com/metabrainz/docker-postgres/558325c/postgres-base/install_extensions.sh && \
    chmod +x install_extensions.sh && \
    ./install_extensions.sh && \
    rm install_extensions.sh

ARG RUN_DEPS=" \
    carton \
    postgresql-9.5-pgtap"

ARG BUILD_DEPS=" \
    gcc \
    libc6-dev \
    make \
    postgresql-server-dev-9.5"

setup_mbs_root()

COPY \
    docker/musicbrainz-test-database/cpanfile \
    docker/musicbrainz-test-database/cpanfile.snapshot \
    ./

ENV PERL_CPANM_OPT --notest --no-interactive

RUN apt_install(`$RUN_DEPS $BUILD_DEPS') && \
    sudo_mb(`carton install --deployment') && \
    apt_purge(`$BUILD_DEPS')

COPY admin/ admin/
COPY lib/ lib/
COPY script/ script/
COPY t/sql/initial.sql t/sql/

COPY docker/musicbrainz-test-database/DBDefs.pm lib/

COPY \
    docker/musicbrainz-test-database/create_test_db.sh \
    /docker-entrypoint-initdb.d/
