m4_include(`macros.m4')m4_dnl
FROM ubuntu:18.04

ARG DEBIAN_FRONTEND=noninteractive

COPY \
    docker/musicbrainz-test-database/install_extensions.sh \
    /usr/local/bin/

RUN install_extensions.sh && \
    rm /usr/local/bin/install_extensions.sh

setup_mbs_root()

copy_mb(`docker/musicbrainz-test-database/cpanfile docker/musicbrainz-test-database/cpanfile.snapshot ./')

ENV PERL_CPANM_OPT --notest --no-interactive

RUN sudo_mb(`carton install --deployment') && \
    apt_purge(`gcc libc6-dev make postgresql-server-dev-10')

copy_mb(`admin/ admin/')
copy_mb(`lib/ lib/')
copy_mb(`script/ script/')
copy_mb(`t/sql/initial.sql t/sql/')
copy_mb(`entities.json entities.json')

RUN mkdir -p '/home/musicbrainz/dumps' && \
    chown -R postgres:postgres /home/musicbrainz/dumps

copy_mb(`docker/musicbrainz-test-database/DBDefs.pm lib/')
copy_mb(`docker/scripts/import_db.sh docker/scripts/')

ENV PGDATA /var/lib/postgresql/10/main

RUN pg_dropcluster --stop 10 main && \
    pg_createcluster --encoding=utf8 --locale=en_US.UTF-8 --user=postgres 10 main

COPY --chown=postgres:postgres \
    docker/musicbrainz-test-database/pg_hba.conf \
    docker/musicbrainz-test-database/postgresql.conf \
    $PGDATA/

RUN sudo -E -H -u postgres touch \
    $PGDATA/pg_ident.conf

COPY \
    docker/musicbrainz-test-database/docker-entrypoint.sh \
    /usr/local/bin/

RUN sudo -E -H -u postgres /usr/lib/postgresql/10/bin/pg_ctl -D /var/lib/postgresql/10/main start && \
    sudo -E -H -u musicbrainz carton exec -- ./script/create_test_db.sh && \
    sudo -E -H -u postgres createdb -O musicbrainz -T musicbrainz_test -U postgres musicbrainz_test_json_dump && \
    sudo -E -H -u postgres createdb -O musicbrainz -T musicbrainz_test -U postgres musicbrainz_test_full_export && \
    sudo -E -H -u postgres createdb -O musicbrainz -T musicbrainz_test -U postgres musicbrainz_test_sitemaps && \
    sudo -E -H -u postgres createdb -O musicbrainz -T musicbrainz_test -U postgres musicbrainz_test_template && \
    sudo -E -H -u postgres /usr/lib/postgresql/10/bin/pg_ctl -D /var/lib/postgresql/10/main -m fast stop

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
