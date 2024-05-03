m4_include(`macros.m4')m4_dnl
FROM metabrainz/base-image:jammy-1.0.1-v0.4

ARG DEBIAN_FRONTEND=noninteractive

run_with_apt_cache \
    keep_apt_cache && \
    apt_install(`sudo')

setup_mbs_root()

install_perl_and_mbs_run_deps()

copy_mb(`cpanfile ./')

install_perl_modules()
