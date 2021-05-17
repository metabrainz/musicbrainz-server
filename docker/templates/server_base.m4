m4_include(`macros.m4')m4_dnl
FROM metabrainz/consul-template-base:focal-1.0.0-alpha1_ct_0.25.2

ARG DEBIAN_FRONTEND=noninteractive

RUN apt_install(`rsync sudo')

setup_mbs_root()

copy_mb(`cpanfile cpanfile.snapshot ./')

install_perl_modules(` --deployment')

RUN chown_mb(`/home/musicbrainz/data-dumps')
