m4_include(`server_base.m4')m4_dnl

COPY docker/musicbrainz-webservice/consul-template.conf /etc/

COPY \
    docker/scripts/musicbrainz-server.service \
    /etc/service/musicbrainz-server/run
