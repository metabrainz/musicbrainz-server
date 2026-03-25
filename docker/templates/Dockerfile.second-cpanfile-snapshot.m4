m4_include(`macros.m4')m4_dnl
FROM metabrainz/base-image:noble-1.0.2-v0.1

ARG DEBIAN_FRONTEND=noninteractive

run_with_apt_cache \
    keep_apt_cache && \
    apt_install(`sudo')

setup_mbs_root()

install_second_perl_and_mbs_run_deps()

copy_mb(`cpanfile ./')

install_perl_modules()
