m4_include(`macros.m4')m4_dnl
FROM postgres:16

ARG DEBIAN_FRONTEND=noninteractive

# install_extensions.sh removes certain build dependencies that we need, so we
# can't install everything here.
# Note: curl is also a dependency of carton.
run_with_apt_cache \
    keep_apt_cache && \
    apt_install(`bzip2 ca-certificates curl sudo')

RUN cd /tmp && \
    curl -sSLO https://raw.githubusercontent.com/metabrainz/docker-postgres/0daa45e/postgres-master/install_extensions.sh && \
    chmod +x install_extensions.sh && \
    ./install_extensions.sh && \
    rm install_extensions.sh

setup_mbs_root()

set_perl_install_args

set_cpanm_and_carton_env

set_cpanm_install_args

run_with_apt_cache \
    apt_install(`test_db_build_deps test_db_run_deps') && \
    install_perl && \
    install_cpanm_and_carton && \
    apt_purge(`test_db_build_deps')

copy_mb(`docker/musicbrainz-test-database/cpanfile docker/musicbrainz-test-database/cpanfile.snapshot ./')

run_with_apt_cache \
    with_cpanm_cache \
    apt_install(`test_db_build_deps') && \
    chown_mb(``/home/musicbrainz/.cpanm'') && \
    chown_mb(``$PERL_CARTON_PATH'') && \
    sudo_mb(`carton install --deployment') && \
    apt_purge(`test_db_build_deps')

copy_mb(`admin/ admin/')
copy_mb(`lib/ lib/')
copy_mb(`script/ script/')
copy_mb(`t/sql/initial.sql t/sql/')
copy_mb(`entities.json entities.json')
copy_mb(`entities.mjs entities.mjs')

RUN mkdir -p '/home/musicbrainz/dumps' && \
    chown -R postgres:postgres /home/musicbrainz/dumps

copy_mb(`docker/musicbrainz-test-database/DBDefs.pm lib/')
copy_mb(`docker/scripts/import_db.sh docker/scripts/')

COPY \
    docker/musicbrainz-test-database/create_test_db.sh \
    /docker-entrypoint-initdb.d/
