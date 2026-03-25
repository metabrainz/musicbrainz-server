m4_include(`macros.m4')m4_dnl
FROM metabrainz/base-image:noble-1.0.2-v0.1

ARG DEBIAN_FRONTEND=noninteractive

run_with_apt_cache \
    keep_apt_cache && \
    apt_install(`rsync sudo')

setup_mbs_root()

install_perl_and_mbs_run_deps()

copy_mb(`cpanfile cpanfile.snapshot ./')

install_perl_modules(` --deployment')

RUN chown_mb(`/home/musicbrainz/data-dumps')

copy_common_mbs_files
