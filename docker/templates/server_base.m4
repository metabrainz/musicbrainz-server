m4_include(`macros.m4')m4_dnl
FROM metabrainz/base-image:jammy-1.0.1-v0.4

ARG DEBIAN_FRONTEND=noninteractive

run_with_apt_cache \
    keep_apt_cache && \
    apt_install(`rsync sudo')

setup_mbs_root()

copy_mb(`cpanfile cpanfile.snapshot ./')

install_perl_modules(` --deployment')

RUN chown_mb(`/home/musicbrainz/data-dumps')

copy_common_mbs_files
