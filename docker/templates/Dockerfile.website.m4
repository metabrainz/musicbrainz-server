m4_include(`server_base.m4')m4_dnl

ARG DEBIAN_FRONTEND=noninteractive

RUN apt_install(`rsync zopfli')

install_javascript_and_templates()

install_translations()

COPY \
    docker/musicbrainz-website/consul-template.conf \
    docker/musicbrainz-website/staticbrainz_rsync_password.ctmpl \
    /etc/

COPY docker/musicbrainz-website/deploy_static_resources.sh /usr/local/bin/

COPY \
    docker/scripts/musicbrainz-server.service \
    /etc/service/musicbrainz-server/run
