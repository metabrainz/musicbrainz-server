m4_include(`macros.m4')m4_dnl
FROM phusion/baseimage:jammy-1.0.1

SHELL ["/bin/bash", "-c"]

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
    add-apt-repository ppa:deadsnakes/ppa && \
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
        postgresql-16
        postgresql-16-pgtap
        redis-server
        runit
        runit-systemd
        sudo
        unzip
        ') && \
    rm -f /etc/apt/sources.list.d/nodesource.list \
        /etc/apt/sources.list.d/pgdg.list && \
    systemctl disable rabbitmq-server && \
    install_ts && \
    install_perl && \
    install_cpanm_and_carton

COPY --chown=musicbrainz:musicbrainz cpanfile cpanfile.snapshot ./
# Install Perl module dependencies for MusicBrainz Server
RUN with_cpanm_cache \
    chown_mb(``/home/musicbrainz/.cpanm'') && \
    chown_mb(``$PERL_CARTON_PATH'') && \
    sudo -E -H -u musicbrainz carton install --deployment && \
    rm cpanfile cpanfile.snapshot

RUN mkdir musicbrainz-server
ENV PG_AMQP_COMMIT 240d477

RUN git clone --depth 1 https://github.com/omniti-labs/pg_amqp.git && \
    cd pg_amqp && \
    git reset --hard $PG_AMQP_COMMIT && \
    make && \
    make install && \
    cd /home/musicbrainz

ARG OPENJDK_VERSION=17.0.11+9
ARG OPENJDK_SRC_SUM=aa7fb6bb342319d227a838af5c363bfa1b4a670c209372f9e6585bd79da6220c

RUN curl -sSLO https://github.com/adoptium/temurin17-binaries/releases/download/jdk-${OPENJDK_VERSION/+/%2B}/OpenJDK17U-jdk_x64_linux_hotspot_${OPENJDK_VERSION/+/_}.tar.gz && \
    echo "$OPENJDK_SRC_SUM *OpenJDK17U-jdk_x64_linux_hotspot_${OPENJDK_VERSION/+/_}.tar.gz" | sha256sum --strict --check - && \
    tar xzf OpenJDK17U-jdk_x64_linux_hotspot_${OPENJDK_VERSION/+/_}.tar.gz && \
    mv "jdk-$OPENJDK_VERSION" /usr/local/jdk && \
    update-alternatives --install /usr/bin/java java /usr/local/jdk/bin/java 10000 && \
    update-alternatives --set java /usr/local/jdk/bin/java && \
    rm OpenJDK17U-jdk_x64_linux_hotspot_${OPENJDK_VERSION/+/_}.tar.gz
ENV JAVA_HOME /usr/local/jdk
ENV PATH $JAVA_HOME/bin:$PATH

ARG SOLR_VERSION=9.4.0
ARG SOLR_SRC_SUM=7147caaec5290049b721f9a4e8b0c09b1775315fc4aa790fa7a88a783a45a61815b3532a938731fd583e91195492c4176f3c87d0438216dab26a07a4da51c1f5

RUN curl -sSLO http://archive.apache.org/dist/solr/solr/$SOLR_VERSION/solr-$SOLR_VERSION.tgz && \
    echo "$SOLR_SRC_SUM *solr-$SOLR_VERSION.tgz" | sha512sum --strict --check - && \
    tar xzf solr-$SOLR_VERSION.tgz solr-$SOLR_VERSION/bin/install_solr_service.sh --strip-components=2 && \
    ./install_solr_service.sh solr-$SOLR_VERSION.tgz && \
    systemctl disable solr

ENV MB_SOLR_TAG master

# Steps taken from https://github.com/metabrainz/mb-solr/blob/master/Dockerfile
RUN sudo -E -H -u musicbrainz git clone --branch $MB_SOLR_TAG --depth 1 --recursive https://github.com/metabrainz/mb-solr.git && \
    cd mb-solr/mmd-schema/brainz-mmd2-jaxb && \
    # Assume that Java classes have been regenerated and patched
    find src/main/java -type f -print0 | xargs -0 touch && \
    mvn install && \
    cd ../../mb-solr && \
    mvn package -DskipTests && \
    cp target/mb-solr-0.0.1-SNAPSHOT-jar-with-dependencies.jar /opt/solr/lib/ && \
    cd .. && \
    mkdir -p /var/solr/data/mycores/mbsssss && \
    cp -R mbsssss /var/solr/data/mycores/mbsssss && \
    chown -R solr:solr /opt/solr/ /var/solr/data/ && \
    cd /home/musicbrainz

ENV SIR_TAG v3.0.1

RUN sudo -E -H -u musicbrainz git clone --branch $SIR_TAG https://github.com/metabrainz/sir.git && \
    cd sir && \
    sudo -E -H -u musicbrainz sh -c 'virtualenv --python=python2 venv; . venv/bin/activate; pip install --upgrade pip; pip install -r requirements.txt; pip install git+https://github.com/esnme/ultrajson.git@7d0f4fb7e911120fd09075049233b587936b0a65' && \
    cd /home/musicbrainz

ENV ARTWORK_INDEXER_COMMIT 776046c

RUN sudo -E -H -u musicbrainz git clone https://github.com/metabrainz/artwork-indexer.git && \
    cd artwork-indexer && \
    sudo -E -H -u musicbrainz git reset --hard $ARTWORK_INDEXER_COMMIT && \
    sudo -E -H -u musicbrainz sh -c 'python3.11 -m venv venv; . venv/bin/activate; pip install -r requirements.txt' && \
    cd /home/musicbrainz

ENV ARTWORK_REDIRECT_COMMIT 9863559

RUN sudo -E -H -u musicbrainz git clone https://github.com/metabrainz/artwork-redirect.git && \
    cd artwork-redirect && \
    sudo -E -H -u musicbrainz git reset --hard $ARTWORK_REDIRECT_COMMIT && \
    sudo -E -H -u musicbrainz sh -c 'python3.11 -m venv venv; . venv/bin/activate; pip install -r requirements.txt' && \
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
    sudo -u postgres /usr/lib/postgresql/16/bin/initdb \
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

COPY docker/musicbrainz-tests/artwork-indexer-config.ini artwork-indexer/config.selenium.ini
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

RUN --mount=type=bind,source=docker/scripts/install_svlogd_services.sh,target=/usr/local/bin/install_svlogd_services.sh \
    install_svlogd_services.sh \
        artwork-indexer \
        artwork-redirect \
        chrome \
        postgresql \
        redis \
        solr \
        ssssss \
        template-renderer \
        vnu \
        website

# Allow the musicbrainz user execute any command with sudo.
# Primarily needed to run rabbitmqctl.
RUN echo 'musicbrainz ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

LABEL com.circleci.preserve-entrypoint=true
