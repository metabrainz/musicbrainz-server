m4_include(`server_base.m4')m4_dnl

copy_common_mbs_files

COPY docker/musicbrainz-webservice/consul-template.conf /etc/

COPY docker/scripts/start_musicbrainz_server.sh /usr/local/bin/

COPY docker/templates/DBDefs.pm.ctmpl lib/
