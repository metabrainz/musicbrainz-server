m4_include(`server_base.m4')m4_dnl

RUN apt_install(`pixz rsync')

RUN chown_mb(`/home/musicbrainz/log') && \
    chown_mb(`/home/musicbrainz/json-dumps/full') && \
    chown_mb(`/home/musicbrainz/json-dumps/incremental')

copy_common_mbs_files

COPY \
    docker/musicbrainz-json-dump/consul-template-json-dump.conf \
    /etc/

COPY \
    docker/musicbrainz-json-dump/consul-template.service \
    /etc/service/consul-template/run
RUN chmod 755 /etc/service/consul-template/run

COPY docker/musicbrainz-json-dump/crontab /var/spool/cron/crontabs/musicbrainz

RUN chown musicbrainz:musicbrainz /var/spool/cron/crontabs/musicbrainz && \
    chmod 600 /var/spool/cron/crontabs/musicbrainz

COPY docker/scripts/start_musicbrainz_server.sh /usr/local/bin/

COPY docker/templates/DBDefs.pm.ctmpl lib/

git_info
