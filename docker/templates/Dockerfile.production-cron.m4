m4_include(`server_base.m4')m4_dnl

RUN apt_install(`rsync')

RUN chown_mb(`/home/musicbrainz/backup') && \
    chown_mb(`/var/ftp/pub/musicbrainz/data')

COPY admin/ admin/
COPY bin/ bin/

COPY docker/musicbrainz-production-cron/consul-template.conf /etc/

COPY \
    docker/musicbrainz-production-cron/crontab \
    /var/spool/cron/crontabs/musicbrainz

RUN chown musicbrainz:musicbrainz /var/spool/cron/crontabs/musicbrainz && \
    chmod 600 /var/spool/cron/crontabs/musicbrainz
