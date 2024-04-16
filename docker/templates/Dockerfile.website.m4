m4_include(`server_base.m4')m4_dnl

run_with_apt_cache \
    apt_install(`lsof')

git_info

install_translations()

install_javascript_and_templates

COPY --chmod=0755 \
    docker/musicbrainz-website/template-renderer.service \
    /etc/service/template-renderer/run
COPY --chmod=0755 \
    docker/musicbrainz-website/website.service \
    /etc/service/website/run
RUN touch \
        /etc/service/template-renderer/down \
        /etc/service/website/down

COPY --chmod=0755 \
    docker/scripts/start_musicbrainz_server.sh \
    docker/scripts/start_template_renderer.sh \
    docker/musicbrainz-website/dbdefs_to_js.sh \
    /usr/local/bin/
