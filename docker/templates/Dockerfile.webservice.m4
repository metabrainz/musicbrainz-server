m4_include(`server_base.m4')m4_dnl

copy_common_mbs_files

COPY \
    docker/musicbrainz-webservice/webservice.service \
    /etc/service/webservice/run
RUN chmod 755 /etc/service/webservice/run
RUN touch /etc/service/webservice/down

COPY docker/scripts/start_musicbrainz_server.sh /usr/local/bin/

git_info
