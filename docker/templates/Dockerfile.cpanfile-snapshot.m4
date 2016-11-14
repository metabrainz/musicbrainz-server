m4_include(`macros.m4')m4_dnl
m4_dnl The following comment does not apply to this file.
`#' Automatically generated, do not edit.
FROM metabrainz/consul-template-base

ARG DEBIAN_FRONTEND=noninteractive

RUN apt_install(`sudo')

setup_mbs_root()

COPY carton-local/ /home/musicbrainz/carton-local/
RUN chown_mb(`/home/musicbrainz/carton-local')

COPY cpanfile ./

install_perl_modules()
