m4_include(`server_base.m4')m4_dnl

COPY --chmod=0755 \
    docker/musicbrainz-webservice/webservice.service \
    /etc/service/webservice/run
RUN touch /etc/service/webservice/down

COPY docker/scripts/start_musicbrainz_server.sh /usr/local/bin/

git_info
