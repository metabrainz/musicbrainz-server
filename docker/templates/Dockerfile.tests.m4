m4_include(`server_base.m4')m4_dnl

install_javascript_and_templates()

RUN touch /etc/service/consul-template/down

COPY docker/musicbrainz-tests/DBDefs.pm lib/
