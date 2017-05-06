m4_include(`macros.m4')m4_dnl
FROM metabrainz/consul-template-base:0.18.2

ARG DEBIAN_FRONTEND=noninteractive

RUN apt_install(`sudo')

setup_mbs_root()

RUN chown_mb(`/home/musicbrainz/carton-local')

COPY cpanfile ./

install_perl_modules()
