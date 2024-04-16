m4_include(`macros.m4')m4_dnl
FROM phusion/baseimage:jammy-1.0.1

RUN useradd --create-home --shell /bin/bash musicbrainz

WORKDIR /home/musicbrainz

set_perl_install_args

set_cpanm_and_carton_env

set_cpanm_install_args

run_with_apt_cache \
    --mount=type=bind,source=docker/nodesource_pubkey.txt,target=/etc/apt/keyrings/nodesource.asc \
    --mount=type=bind,source=docker/pgdg_pubkey.txt,target=/etc/apt/keyrings/pgdg.asc \
    keep_apt_cache && \
    apt_install(``ca-certificates curl gnupg'') && \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.asc] https://deb.nodesource.com/node_20.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list && \
    echo "deb [signed-by=/etc/apt/keyrings/pgdg.asc] http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list && \
    apt_install(`m4_dnl
        mbs_build_deps
        mbs_javascript_deps
        mbs_run_deps
        mbs_translations_deps
        test_db_build_deps
        chrome_for_testing_deps
        search_deps
        selenium_caa_deps
        locales
        openssh-client
        postgresql-12
        postgresql-12-pgtap
        redis-server
        runit
        runit-systemd
        sudo
        unzip
        ') && \
    rm -f /etc/apt/sources.list.d/nodesource.list \
        /etc/apt/sources.list.d/pgdg.list && \
    update-java-alternatives -s java-1.8.0-openjdk-amd64 && \
    systemctl disable rabbitmq-server && \
    install_ts && \
    install_perl && \
    install_cpanm_and_carton

# Install Perl module dependencies for MusicBrainz Server
RUN with_cpanm_cache \
    with_cpanfile_and_snapshot \
    chown_mb(``/home/musicbrainz/.cpanm'') && \
    chown_mb(``$PERL_CARTON_PATH'') && \
    sudo -E -H -u musicbrainz carton install --deployment

RUN mkdir musicbrainz-server
ENV PG_AMQP_COMMIT 240d477

RUN git clone --depth 1 https://github.com/omniti-labs/pg_amqp.git && \
    cd pg_amqp && \
    git reset --hard $PG_AMQP_COMMIT && \
    make && \
    make install && \
    cd /home/musicbrainz

ENV SOLR_VERSION 7.7.3
ENV SOLR_HOME /opt/solr/server/solr

RUN curl -sSLO http://archive.apache.org/dist/lucene/solr/$SOLR_VERSION/solr-$SOLR_VERSION.tgz && \
    tar xzf solr-$SOLR_VERSION.tgz solr-$SOLR_VERSION/bin/install_solr_service.sh --strip-components=2 && \
    ./install_solr_service.sh solr-$SOLR_VERSION.tgz && \
    systemctl disable solr

ENV MB_SOLR_TAG v3.4.2

# Steps taken from https://github.com/metabrainz/mb-solr/blob/master/Dockerfile
RUN sudo -E -H -u musicbrainz git clone --branch $MB_SOLR_TAG --depth 1 --recursive https://github.com/metabrainz/mb-solr.git && \
    cd mb-solr/mmd-schema/brainz-mmd2-jaxb && \
    mvn install && \
    cd ../../mb-solr && \
    mvn package -DskipTests && \
    mkdir -p /opt/solr/lib $SOLR_HOME && \
    cp target/mb-solr-0.0.1-SNAPSHOT-jar-with-dependencies.jar /opt/solr/lib/ && \
    cd .. && \
    cp -R mbsssss $SOLR_HOME/mycores/ && \
    sed -i'' 's|</solr>|<str name="sharedLib">/opt/solr/lib</str></solr>|' $SOLR_HOME/solr.xml && \
    mkdir $SOLR_HOME/data && \
    chown -R solr:solr /opt/solr/ && \
    cd /home/musicbrainz

ENV SIR_TAG v3.0.1

RUN sudo -E -H -u musicbrainz git clone --branch $SIR_TAG https://github.com/metabrainz/sir.git && \
    cd sir && \
    sudo -E -H -u musicbrainz sh -c 'virtualenv --python=python2 venv; . venv/bin/activate; pip install --upgrade pip; pip install -r requirements.txt; pip install git+https://github.com/esnme/ultrajson.git@7d0f4fb7e911120fd09075049233b587936b0a65' && \
    cd /home/musicbrainz

ENV ARTWORK_INDEXER_COMMIT c8731b5

RUN sudo -E -H -u musicbrainz git clone https://github.com/metabrainz/artwork-indexer.git && \
    cd artwork-indexer && \
    sudo -E -H -u musicbrainz git reset --hard $ARTWORK_INDEXER_COMMIT && \
    sudo -E -H -u musicbrainz sh -c 'python3 -m venv venv; . venv/bin/activate; pip install -r requirements.txt' && \
    cd /home/musicbrainz

ENV ARTWORK_REDIRECT_COMMIT c632ecf

RUN sudo -E -H -u musicbrainz git clone https://github.com/metabrainz/artwork-redirect.git && \
    cd artwork-redirect && \
    sudo -E -H -u musicbrainz git reset --hard $ARTWORK_REDIRECT_COMMIT && \
    sudo -E -H -u musicbrainz sh -c 'python3 -m venv venv; . venv/bin/activate; pip install -r requirements.txt' && \
    cd /home/musicbrainz

RUN curl -sSLO https://edgedl.me.gvt1.com/edgedl/chrome/chrome-for-testing/119.0.6045.105/linux64/chrome-linux64.zip && \
    unzip chrome-linux64.zip -d /opt && \
    rm chrome-linux64.zip

RUN curl -sSLO https://edgedl.me.gvt1.com/edgedl/chrome/chrome-for-testing/119.0.6045.105/linux64/chromedriver-linux64.zip && \
    unzip chromedriver-linux64.zip -d /tmp && \
    mv /tmp/chromedriver-linux64/chromedriver /usr/local/bin/ && \
    chmod +x /usr/local/bin/chromedriver && \
    rm -r chromedriver-linux64.zip /tmp/chromedriver-linux64

RUN curl -sSLO https://github.com/validator/validator/releases/download/18.11.5/vnu.jar_18.11.5.zip && \
    unzip -d vnu -j vnu.jar_18.11.5.zip && \
    rm vnu.jar_18.11.5.zip

RUN echo 'en_US.UTF-8 UTF-8' > /etc/locale.gen && \
    locale-gen

ENV PGHOME /var/lib/postgresql
ENV PGDATA "$PGHOME"/data

RUN mkdir -p "$PGDATA" && \
    chown -R postgres:postgres "$PGHOME" && \
    cd "$PGHOME" && \
    chmod 700 "$PGDATA" && \
    sudo -u postgres /usr/lib/postgresql/12/bin/initdb \
        --data-checksums \
        --encoding utf8 \
        --locale en_US.UTF8 \
        --username postgres \
        --pgdata "$PGDATA" && \
    cd -

COPY --chown=postgres:postgres \
    docker/musicbrainz-tests/pg_hba.conf \
    docker/musicbrainz-tests/postgresql.conf \
    $PGDATA/

RUN sudo -E -H -u postgres touch \
    $PGDATA/pg_ident.conf

COPY docker/musicbrainz-tests/artwork-indexer-config.ini artwork-indexer/config.ini
COPY docker/musicbrainz-tests/artwork-redirect-config.ini artwork-redirect/config.ini
COPY docker/musicbrainz-tests/sir-config.ini sir/config.ini

COPY --chmod=0755 \
    docker/musicbrainz-tests/artwork-indexer.service \
    /etc/service/artwork-indexer/run
COPY --chmod=0755 \
    docker/musicbrainz-tests/artwork-redirect.service \
    /etc/service/artwork-redirect/run
COPY --chmod=0755 \
    docker/musicbrainz-tests/chrome.service \
    /etc/service/chrome/run
COPY --chmod=0755 \
    docker/musicbrainz-tests/postgresql.service \
    /etc/service/postgresql/run
COPY --chmod=0755 \
    docker/musicbrainz-tests/redis.service \
    /etc/service/redis/run
COPY --chmod=0755 \
    docker/musicbrainz-tests/solr.service \
    /etc/service/solr/run
COPY --chmod=0755 \
    docker/musicbrainz-tests/ssssss.service \
    /etc/service/ssssss/run
COPY --chmod=0755 \
    docker/musicbrainz-tests/template-renderer.service \
    /etc/service/template-renderer/run
COPY --chmod=0755 \
    docker/musicbrainz-tests/vnu.service \
    /etc/service/vnu/run
COPY --chmod=0755 \
    docker/musicbrainz-tests/website.service \
    /etc/service/website/run
RUN touch \
    /etc/service/artwork-indexer/down \
    /etc/service/artwork-redirect/down \
    /etc/service/chrome/down \
    /etc/service/postgresql/down \
    /etc/service/redis/down \
    /etc/service/solr/down \
    /etc/service/ssssss/down \
    /etc/service/template-renderer/down \
    /etc/service/vnu/down \
    /etc/service/website/down

COPY --chmod=0755 \
    docker/scripts/start_template_renderer.sh \
    /usr/local/bin/

COPY --chmod=0755 \
    docker/scripts/install_svlogd_services.sh \
    /usr/local/bin/
RUN install_svlogd_services.sh \
        artwork-indexer \
        artwork-redirect \
        chrome \
        postgresql \
        redis \
        solr \
        ssssss \
        template-renderer \
        vnu \
        website && \
    rm /usr/local/bin/install_svlogd_services.sh

# Allow the musicbrainz user execute any command with sudo.
# Primarily needed to run rabbitmqctl.
RUN echo 'musicbrainz ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

LABEL com.circleci.preserve-entrypoint=true
