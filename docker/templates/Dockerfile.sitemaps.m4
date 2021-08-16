m4_include(`server_base.m4')m4_dnl

copy_common_mbs_files

COPY \
    docker/musicbrainz-sitemaps/sitemaps.service \
    /etc/service/sitemaps/run
RUN chmod 755 /etc/service/sitemaps/run

COPY docker/musicbrainz-sitemaps/crontab /var/spool/cron/crontabs/musicbrainz

RUN chown musicbrainz:musicbrainz /var/spool/cron/crontabs/musicbrainz && \
    chmod 600 /var/spool/cron/crontabs/musicbrainz

COPY docker/scripts/start_musicbrainz_server.sh /usr/local/bin/

RUN chown_mb(`/home/musicbrainz/log MBS_ROOT/root/static/sitemaps')

git_info

RUN chmod 644 /etc/container_environment.sh
