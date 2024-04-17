m4_include(`server_base.m4')m4_dnl

run_with_apt_cache \
    apt_install(``xz-utils'') && \
    chown_mb(`/home/musicbrainz/log') && \
    chown_mb(`/home/musicbrainz/json-dumps/full')

COPY --chown=musicbrainz:musicbrainz --chmod=0600 \
     docker/musicbrainz-json-dump/crontab \
     /var/spool/cron/crontabs/musicbrainz

ENV MB_CONTAINER_TYPE json-dump

COPY \
    docker/scripts/create_log_directories.sh \
    /etc/my_init.d/90_create_log_directories.sh

COPY docker/scripts/start_musicbrainz_server.sh /usr/local/bin/

git_info
