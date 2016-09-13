FROM metabrainz/consul-template-base

ARG DEBIAN_FRONTEND=noninteractive

ARG RUN_DEPS=" \
    ca-certificates \
    gettext \
    git \
    libdb5.3 \
    libexpat1 \
    libicu55 \
    libpq5 \
    libssl1.0.0 \
    nodejs \
    nodejs-legacy \
    perl \
    postgresql-client-9.5 \
    # Provides pg_config.
    postgresql-server-dev-9.5 \
    rsync \
    zopfli"

ARG BUILD_DEPS=" \
    build-essential \
    libdb-dev \
    libexpat1-dev \
    libicu-dev \
    libperl-dev \
    libpq-dev \
    libssl-dev \
    libxml2-dev \
    npm"

RUN apt-get update && \
    apt-get install \
        --no-install-suggests \
        --no-install-recommends \
        -y \
        $BUILD_DEPS \
        $RUN_DEPS && \
    rm -rf /var/lib/apt/lists/*

RUN wget -q -O - https://cpanmin.us | perl - App::cpanminus && \
    cpanm Carton

RUN useradd --create-home --shell /bin/bash musicbrainz
USER musicbrainz

ARG MBS_ROOT=/home/musicbrainz/musicbrainz-server
# WORKDIR would create this for us, but this ensures it has the correct owner.
RUN mkdir -p $MBS_ROOT
WORKDIR $MBS_ROOT

COPY cpanfile cpanfile.snapshot ./
COPY docker/musicbrainz-server/get_carton_bundle.sh docker/musicbrainz-server/
RUN ./docker/musicbrainz-server/get_carton_bundle.sh

ENV PERL_CARTON_PATH ~/carton-local
ENV PERL_CPANM_OPT --notest --no-interactive
RUN eval "mkdir $PERL_CARTON_PATH" && \
    carton install --cached --deployment

COPY package.json npm-shrinkwrap.json ./
RUN npm install --only=production

COPY po/ po/
RUN make -C po all_quiet && \
    make -C po deploy

USER root

RUN apt-get purge -y $BUILD_DEPS && \
    apt-get autoremove -y

COPY ./ ./

# https://github.com/docker/docker/issues/6119
RUN mkdir -p /tmp/ttc && \
    chown -R musicbrainz:musicbrainz $MBS_ROOT /tmp/ttc

RUN ln -s \
        $MBS_ROOT/docker/musicbrainz-server/consul-template.conf \
        $MBS_ROOT/docker/musicbrainz-server/mbs_service_functions.sh \
        $MBS_ROOT/docker/musicbrainz-server/rsync_password_file.ctmpl \
        /etc/ && \
    mkdir -p /etc/service/musicbrainz-server && \
    ln -sf \
        $MBS_ROOT/docker/musicbrainz-server/cron.service \
        /etc/service/cron/run && \
    ln -s \
        $MBS_ROOT/docker/musicbrainz-server/musicbrainz-server.service \
        /etc/service/musicbrainz-server/run
