FROM phusion/baseimage:0.11

RUN useradd --create-home --shell /bin/bash musicbrainz

WORKDIR /home/musicbrainz

COPY docker/yarn_pubkey.txt .

RUN apt-get update && \
    apt-get install \
        --no-install-recommends \
        --no-install-suggests \
        -y \
        ca-certificates \
        curl \
        gnupg && \
    apt-key add yarn_pubkey.txt && \
    rm yarn_pubkey.txt && \
    apt-key adv --keyserver keyserver.ubuntu.com --refresh-keys 'Yarn' && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    curl -sLO https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    curl -sLO https://deb.nodesource.com/node_10.x/pool/main/n/nodejs/nodejs_10.10.0-1nodesource1_amd64.deb && \
    apt-get update && \
    apt-get install \
        --no-install-recommends \
        --no-install-suggests \
        -y \
        ./google-chrome-stable_current_amd64.deb \
        ./nodejs_10.10.0-1nodesource1_amd64.deb \
        build-essential \
        bzip2 \
        default-jre \
        gcc \
        gettext \
        git \
        language-pack-de \
        language-pack-el \
        language-pack-es \
        language-pack-et \
        language-pack-fi \
        language-pack-fr \
        language-pack-it \
        language-pack-ja \
        language-pack-nl \
        libc6-dev \
        libdb-dev \
        libdb5.3 \
        libexpat1 \
        libexpat1-dev \
        libicu-dev \
        libicu60 \
        libperl-dev \
        libpq-dev \
        libpq5 \
        libssl-dev \
        libssl1.0.0 \
        libxml2 \
        libxml2-dev \
        locales \
        make \
        openssh-client \
        perl \
        postgresql \
        postgresql-10-pgtap \
        postgresql-contrib \
        postgresql-server-dev-10 \
        python-minimal \
        redis-server \
        runit \
        runit-systemd \
        sudo \
        unzip \
        yarn && \
    rm -rf /var/lib/apt/lists/* && \
    rm google-chrome-stable_current_amd64.deb && \
    rm nodejs_10.10.0-1nodesource1_amd64.deb

RUN wget -q -O - https://cpanmin.us | perl - App::cpanminus && \
    cpanm Carton JSON::XS

RUN curl -sLO https://chromedriver.storage.googleapis.com/74.0.3729.6/chromedriver_linux64.zip && \
    unzip chromedriver_linux64.zip -d /usr/local/bin && \
    chmod +x /usr/local/bin/chromedriver && \
    rm chromedriver_linux64.zip

RUN curl -sLO https://github.com/validator/validator/releases/download/18.11.5/vnu.jar_18.11.5.zip && \
    unzip -d vnu -j vnu.jar_18.11.5.zip && \
    rm vnu.jar_18.11.5.zip

RUN echo 'en_US.UTF-8 UTF-8' > /etc/locale.gen && \
    locale-gen

ENV PGDATA /home/musicbrainz/pgdata

RUN pg_dropcluster --stop 10 main && \
    pg_createcluster --datadir="$PGDATA" --encoding=utf8 --locale=en_US.UTF-8 --user=postgres 10 main

COPY --chown=postgres:postgres \
    docker/musicbrainz-tests/pg_hba.conf \
    docker/musicbrainz-tests/postgresql.conf \
    $PGDATA/

RUN sudo -E -H -u postgres touch \
    $PGDATA/pg_ident.conf

COPY \
    docker/musicbrainz-tests/chrome.service \
    /etc/service/chrome/run
COPY \
    docker/musicbrainz-tests/postgresql.service \
    /etc/service/postgresql/run
COPY \
    docker/musicbrainz-tests/redis.service \
    /etc/service/redis/run
COPY \
    docker/scripts/start_template_renderer.sh \
    /etc/service/template-renderer/run
COPY \
    docker/musicbrainz-tests/vnu.service \
    /etc/service/vnu/run
COPY \
    docker/musicbrainz-tests/website.service \
    /etc/service/website/run
RUN chmod 755 \
        /etc/service/chrome/run \
        /etc/service/postgresql/run \
        /etc/service/redis/run \
        /etc/service/template-renderer/run \
        /etc/service/vnu/run \
        /etc/service/website/run
RUN touch \
    /etc/service/chrome/down \
    /etc/service/postgresql/down \
    /etc/service/redis/down \
    /etc/service/template-renderer/down \
    /etc/service/vnu/down \
    /etc/service/website/down

LABEL com.circleci.preserve-entrypoint=true
