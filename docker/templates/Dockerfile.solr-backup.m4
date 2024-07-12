m4_include(`server_base.m4')m4_dnl

run_with_apt_cache \
    apt_install(`jq zstd')

RUN chown_mb(`/home/musicbrainz/log') && \
    chown_mb(`/home/musicbrainz/solr-backups')

COPY --chown=musicbrainz:musicbrainz --chmod=0600 \
     docker/musicbrainz-solr-backup/crontab \
     /var/spool/cron/crontabs/musicbrainz

ENV MB_CONTAINER_TYPE solr-backup

COPY \
    docker/scripts/create_log_directories.sh \
    /etc/my_init.d/90_create_log_directories.sh

git_info
