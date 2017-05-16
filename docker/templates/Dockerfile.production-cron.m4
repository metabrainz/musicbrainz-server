m4_include(`server_base.m4')m4_dnl

RUN apt_install(`rsync')

RUN chown_mb(`/home/musicbrainz/backup') && \
    chown_mb(`/var/ftp/pub/musicbrainz/data')

copy_common_mbs_files

COPY \
    docker/musicbrainz-production-cron/consul-template-production-cron.conf \
    /etc/

COPY \
    docker/musicbrainz-production-cron/consul-template.service \
    /etc/service/consul-template/run
RUN chmod 755 /etc/service/consul-template/run

COPY \
    docker/musicbrainz-production-cron/crontab \
    /var/spool/cron/crontabs/musicbrainz

RUN chown musicbrainz:musicbrainz /var/spool/cron/crontabs/musicbrainz && \
    chmod 600 /var/spool/cron/crontabs/musicbrainz

COPY docker/templates/DBDefs.pm.ctmpl lib/

git_info
