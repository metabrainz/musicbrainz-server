m4_include(`server_base.m4')m4_dnl

ARG DEBIAN_FRONTEND=noninteractive

RUN apt_install(`lsof')

copy_common_mbs_files

git_info

install_javascript_and_templates(` --only=production')

install_translations()

COPY \
    docker/musicbrainz-website/consul-template-template-renderer.conf \
    docker/musicbrainz-website/consul-template-website.conf \
    /etc/

COPY \
    docker/musicbrainz-website/template-renderer.service \
    /etc/service/template-renderer/run
COPY \
    docker/musicbrainz-website/website.service \
    /etc/service/website/run
RUN chmod 755 \
        /etc/service/template-renderer/run \
        /etc/service/website/run

COPY \
    docker/scripts/start_musicbrainz_server.sh \
    docker/scripts/start_template_renderer.sh \
    /usr/local/bin/

copy_mb(`docker/templates/DBDefs.pm.ctmpl lib/')
