m4_include(`server_base.m4')m4_dnl

COPY docker/musicbrainz-sitemaps/consul-template.conf /etc/

COPY docker/musicbrainz-sitemaps/crontab /var/spool/cron/crontabs/musicbrainz

RUN chown musicbrainz:musicbrainz /var/spool/cron/crontabs/musicbrainz && \
    chmod 600 /var/spool/cron/crontabs/musicbrainz

COPY docker/scripts/start_musicbrainz_server.sh /usr/local/bin/

git_info
