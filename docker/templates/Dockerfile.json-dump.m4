m4_include(`server_base.m4')m4_dnl

install_new_xz_utils

RUN chown_mb(`/home/musicbrainz/log') && \
    chown_mb(`/home/musicbrainz/json-dumps/full') && \
    chown_mb(`/home/musicbrainz/json-dumps/incremental')

copy_common_mbs_files

COPY docker/musicbrainz-json-dump/crontab /var/spool/cron/crontabs/musicbrainz

RUN chown musicbrainz:musicbrainz /var/spool/cron/crontabs/musicbrainz && \
    chmod 600 /var/spool/cron/crontabs/musicbrainz

COPY docker/scripts/start_musicbrainz_server.sh /usr/local/bin/

git_info
