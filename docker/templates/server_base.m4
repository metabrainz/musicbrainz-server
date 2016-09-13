m4_include(`macros.m4')m4_dnl
m4_dnl The following comment does not apply to this file.
`#' Automatically generated, do not edit.
FROM metabrainz/consul-template-base

ARG DEBIAN_FRONTEND=noninteractive

RUN apt_install(`sudo')

ARG RUN_DEPS=" \
    ca-certificates \
    libdb5.3 \
    libexpat1 \
    libicu55 \
    libpq5 \
    libssl1.0.0 \
    perl \
    postgresql-client-9.5 \
    `#' Provides pg_config.
    postgresql-server-dev-9.5"

ARG BUILD_DEPS=" \
    build-essential \
    libdb-dev \
    libexpat1-dev \
    libicu-dev \
    libperl-dev \
    libpq-dev \
    libssl-dev \
    libxml2-dev"

setup_mbs_root()

COPY cpanfile cpanfile.snapshot ./

ENV PERL_CARTON_PATH /home/musicbrainz/carton-local
ENV PERL_CPANM_OPT --notest --no-interactive

RUN apt_install(`$RUN_DEPS $BUILD_DEPS') && \
    wget -q -O - https://cpanmin.us | perl - App::cpanminus && \
    cpanm Carton && \
    chown_mb(`$PERL_CARTON_PATH') && \
    sudo_mb(`carton install --deployment') && \
    apt_purge(`$BUILD_DEPS')

COPY app.psgi entities.json ./
COPY \
    docker/templates/DBDefs.pm.ctmpl \
    lib/ \
    lib/
COPY docker/scripts/mbs_constants.sh /etc/

RUN chown_mb(`$MBS_ROOT')
