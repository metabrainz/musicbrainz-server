m4_include(`server_base.m4')m4_dnl

RUN apt_install(`jq zstd')

RUN chown_mb(`/home/musicbrainz/log') && \
    chown_mb(`/home/musicbrainz/search-index-dumps')

copy_common_mbs_files

COPY docker/musicbrainz-search-indexes-dump/crontab /var/spool/cron/crontabs/musicbrainz

RUN chown musicbrainz:musicbrainz /var/spool/cron/crontabs/musicbrainz && \
    chmod 600 /var/spool/cron/crontabs/musicbrainz

ENV MB_CONTAINER_TYPE search-indexes-dump

COPY \
    docker/scripts/create_log_directories.sh \
    /etc/my_init.d/90_create_log_directories.sh

git_info
