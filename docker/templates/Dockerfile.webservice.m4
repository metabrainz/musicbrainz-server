m4_include(`server_base.m4')m4_dnl

copy_common_mbs_files

COPY docker/musicbrainz-webservice/consul-template-webservice.conf /etc/

COPY \
    docker/musicbrainz-webservice/webservice.service \
    /etc/service/webservice/run
RUN chmod 755 /etc/service/webservice/run

COPY docker/scripts/start_musicbrainz_server.sh /usr/local/bin/

COPY docker/templates/DBDefs.pm.ctmpl lib/
