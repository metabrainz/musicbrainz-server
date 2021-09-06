m4_include(`server_base.m4')m4_dnl

RUN apt_install(`jq zstd')

RUN chown_mb(`/home/musicbrainz/log') && \
    chown_mb(`/home/musicbrainz/search-index-dumps')

copy_common_mbs_files

COPY docker/musicbrainz-search-indexes-dump/crontab /var/spool/cron/crontabs/musicbrainz

RUN chown musicbrainz:musicbrainz /var/spool/cron/crontabs/musicbrainz && \
    chmod 600 /var/spool/cron/crontabs/musicbrainz

git_info
