m4_include(`server_base.m4')m4_dnl

RUN apt_install(`libxml2')

copy_common_mbs_files

COPY docker/musicbrainz-sitemaps/consul-template.conf /etc/

COPY docker/musicbrainz-sitemaps/crontab /var/spool/cron/crontabs/musicbrainz

RUN chown musicbrainz:musicbrainz /var/spool/cron/crontabs/musicbrainz && \
    chmod 600 /var/spool/cron/crontabs/musicbrainz

COPY docker/scripts/start_musicbrainz_server.sh /usr/local/bin/

COPY docker/templates/DBDefs.pm.ctmpl lib/

RUN chown_mb(`/home/musicbrainz/log')

git_info
