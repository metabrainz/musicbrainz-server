m4_include(`server_base.m4')m4_dnl

run_with_apt_cache \
    apt_install(``xz-utils'') && \
    chown_mb(`/home/musicbrainz/backup') && \
    chown_mb(`/var/ftp/pub/musicbrainz/data')

COPY --chown=musicbrainz:musicbrainz --chmod=0600 \
    docker/musicbrainz-production-cron/crontab \
    /var/spool/cron/crontabs/musicbrainz

ENV MB_CONTAINER_TYPE production-cron

COPY \
    docker/scripts/create_log_directories.sh \
    /etc/my_init.d/90_create_log_directories.sh

git_info
