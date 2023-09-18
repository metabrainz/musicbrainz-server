m4_include(`server_base.m4')m4_dnl

install_new_xz_utils

RUN chown_mb(`/home/musicbrainz/backup') && \
    chown_mb(`/var/ftp/pub/musicbrainz/data')

copy_common_mbs_files

COPY \
    docker/musicbrainz-production-cron/crontab \
    /var/spool/cron/crontabs/musicbrainz

RUN chown musicbrainz:musicbrainz /var/spool/cron/crontabs/musicbrainz && \
    chmod 600 /var/spool/cron/crontabs/musicbrainz

ENV MB_CONTAINER_TYPE production-cron

COPY \
    docker/scripts/create_log_directories.sh \
    /etc/my_init.d/90_create_log_directories.sh

git_info
