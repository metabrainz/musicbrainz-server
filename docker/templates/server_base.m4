m4_include(`macros.m4')m4_dnl
FROM metabrainz/consul-template-base

ARG DEBIAN_FRONTEND=noninteractive

RUN apt_install(`sudo')

setup_mbs_root()

COPY cpanfile cpanfile.snapshot ./

install_perl_modules(` --deployment')

COPY app.psgi entities.json ./
COPY \
    docker/templates/DBDefs.pm.ctmpl \
    lib/ \
    lib/
COPY docker/scripts/mbs_constants.sh /etc/

RUN chown_mb(`$MBS_ROOT')
