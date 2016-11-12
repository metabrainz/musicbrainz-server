m4_include(`macros.m4')m4_dnl
m4_dnl The following comment does not apply to this file.
`#' Automatically generated, do not edit.
FROM metabrainz/consul-template-base

ARG DEBIAN_FRONTEND=noninteractive

RUN apt_install(`sudo')

setup_mbs_root()

install_javascript()

install_translations()

COPY entities.json ./
COPY root/layout/components/ root/layout/components/
COPY root/layout/index.js root/layout/
COPY root/main/404.js root/main/
COPY root/server.js root/
COPY root/server/gettext.js root/server/
COPY root/static/lib/ root/static/lib/
COPY root/static/manifest.js root/static/
COPY root/static/scripts/ root/static/scripts/
COPY root/utility/ root/utility/

COPY \
    docker/musicbrainz-template-renderer/consul-template.conf \
    docker/scripts/mbs_constants.sh \
    /etc/

COPY \
    docker/musicbrainz-template-renderer/DBDefs.js.ctmpl \
    $MBS_ROOT/root/static/scripts/common/

RUN chown_mb(`$MBS_ROOT')

git_info
