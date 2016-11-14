m4_include(`server_base.m4')m4_dnl

ARG DEBIAN_FRONTEND=noninteractive

RUN apt_install(`rsync zopfli')

install_javascript_and_templates(` --only=production')

install_translations()

copy_common_mbs_files

COPY docker/musicbrainz-website/consul-template.conf /etc/

COPY \
    docker/musicbrainz-website/deploy_static_resources.sh \
    docker/musicbrainz-website/install_language_packs.pl \
    docker/musicbrainz-website/start_musicbrainz_website.sh \
    docker/scripts/start_musicbrainz_server.sh \
    /usr/local/bin/

COPY docker/templates/DBDefs.pm.ctmpl lib/

git_info
