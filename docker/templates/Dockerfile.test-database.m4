m4_include(`macros.m4')m4_dnl
FROM postgres:9.5.6

ARG DEBIAN_FRONTEND=noninteractive

# install_extensions.sh removes certain build dependencies that we need, so we
# can't install everything here.
# Note: curl is also a dependency of carton.
RUN apt_install(`ca-certificates curl sudo')

RUN cd /tmp && \
    curl -O https://raw.githubusercontent.com/metabrainz/docker-postgres/1ce35dc/postgres-base/install_extensions.sh && \
    chmod +x install_extensions.sh && \
    ./install_extensions.sh && \
    rm install_extensions.sh

setup_mbs_root()

COPY \
    docker/musicbrainz-test-database/cpanfile \
    docker/musicbrainz-test-database/cpanfile.snapshot \
    ./

ENV PERL_CPANM_OPT --notest --no-interactive

RUN apt_install(`test_db_build_deps test_db_run_deps') && \
    sudo_mb(`carton install --deployment') && \
    apt_purge(`test_db_build_deps')

COPY admin/ admin/
COPY lib/ lib/
COPY script/ script/
COPY t/sql/initial.sql t/sql/

COPY docker/musicbrainz-test-database/DBDefs.pm lib/

COPY \
    docker/musicbrainz-test-database/create_test_db.sh \
    /docker-entrypoint-initdb.d/
