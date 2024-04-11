m4_divert(-1)

m4_define(
    `keep_apt_cache',
    `m4_dnl
rm -f /etc/apt/apt.conf.d/docker-clean && \
    echo Binary::apt::APT::Keep-Downloaded-Packages \"true\"\; \
        > /etc/apt/apt.conf.d/keep-cache')

m4_define(
    `run_with_apt_cache',
    `m4_dnl
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked')

m4_define(
    `apt_install',
    `m4_dnl
apt-get update && \
    apt-get install --no-install-suggests --no-install-recommends -y \
m4_patsubst(m4_patsubst(m4_patsubst(m4_patsubst(m4_dnl
m4_patsubst(m4_patsubst(m4_dnl
m4_patsubst($1, `^ +', `'), `
', ` '), ` +$', `'), ` +', `
'), `^', `        '), `
', ` \\
'), ` $', `')')

m4_define(`apt_purge', `apt-get purge --auto-remove -y \
m4_patsubst(m4_patsubst(m4_patsubst(m4_patsubst(m4_dnl
m4_patsubst(m4_patsubst(m4_dnl
m4_patsubst($1, `^ +', `'), `
', ` '), ` +$', `'), ` +', `
'), `^', `        '), `
', ` \\
'), ` $', `')')

m4_define(`sudo_mb', `sudo -E -H -u musicbrainz $1')

m4_define(
    `mbs_javascript_deps',
    `m4_dnl
git
nodejs
python3-minimal
')

m4_define(
    `install_javascript',
    `m4_dnl
copy_mb(``package.json yarn.lock .yarnrc.yml ./'')
run_with_apt_cache \
    --mount=type=bind,source=docker/nodesource_pubkey.txt,target=/etc/apt/keyrings/nodesource.asc \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.asc] https://deb.nodesource.com/node_20.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list && \
    apt_install(`git nodejs python3-minimal') && \
    rm -f /etc/apt/sources.list.d/nodesource.list && \
    corepack enable && \
    sudo_mb(``yarn'')
copy_mb(``babel.config.cjs ./'')')

m4_define(
    `install_javascript_and_templates',
    `m4_dnl
install_javascript

copy_mb(``docker/scripts/compile_resources_for_image.sh docker/scripts/'')
copy_mb(``root/ root/'')
copy_mb(``script/compile_resources.sh script/dbdefs_to_js.pl script/start_renderer.pl script/xgettext.js script/'')
copy_mb(``webpack/ webpack/'')

ENV NODE_ENV production
RUN sudo_mb(``./docker/scripts/compile_resources_for_image.sh'')
RUN chown_mb(``/tmp/ttc'')')

m4_define(
    `mbs_build_deps',
    `m4_dnl
build-essential
libdb-dev
libexpat1-dev
libicu-dev
libperl-dev
libpq-dev
libssl-dev
libxml2-dev
zlib1g-dev
pkg-config
')

# postgresql-server-dev-12 provides pg_config, which is needed by InitDb.pl
# at run-time.
m4_define(
    `mbs_run_deps',
    `m4_dnl
bzip2
ca-certificates
libdb5.3
libexpat1
libicu70
libpq5
libssl3
libxml2
moreutils
perl
postgresql-client-12
postgresql-server-dev-12
zlib1g
')

m4_define(
    `test_db_run_deps',
    `m4_dnl
carton
postgresql-12-pgtap
')

m4_define(
    `test_db_build_deps',
    `m4_dnl
gcc
libc6-dev
make
postgresql-server-dev-12
')

m4_define(
    `set_cpanm_and_carton_env',
    `m4_dnl
ENV PERL_CARTON_PATH="/home/musicbrainz/carton-local" \
    PERL_CPANM_OPT="--notest --no-interactive"')

m4_define(
    `set_cpanm_install_args',
    `m4_dnl
ARG CPANMINUS_VERSION=1.7047
ARG CPANMINUS_SRC_SUM=963e63c6e1a8725ff2f624e9086396ae150db51dd0a337c3781d09a994af05a5')

m4_define(
    `install_cpanm_and_carton',
    `m4_dnl
# Install cpanm (helpful with installing other Perl modules)
    cd /usr/src && \
    curl -sSLO https://www.cpan.org/authors/id/M/MI/MIYAGAWA/App-cpanminus-$CPANMINUS_VERSION.tar.gz && \
    echo "$CPANMINUS_SRC_SUM *App-cpanminus-$CPANMINUS_VERSION.tar.gz" | sha256sum --strict --check - && \
    tar -xzf App-cpanminus-$CPANMINUS_VERSION.tar.gz && \
    cd - && cd /usr/src/App-cpanminus-$CPANMINUS_VERSION && \
    perl bin/cpanm . && \
    cd - && \
    rm -fr /usr/src/App-cpanminus-$CPANMINUS_VERSION* && \
    cpanm \
        # Install carton (helpful with installing locked versions)
        Carton \
        # Workaround for a bug in carton with installing JSON::XS
        JSON::XS')

m4_define(
    `install_perl_modules',
    `m4_dnl

set_cpanm_and_carton_env

set_cpanm_install_args

run_with_apt_cache \
    --mount=type=bind,source=docker/pgdg_pubkey.txt,target=/etc/apt/keyrings/pgdg.asc \
    echo "deb [signed-by=/etc/apt/keyrings/pgdg.asc] http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list && \
    apt_install(`mbs_build_deps mbs_run_deps') && \
    rm -f /etc/apt/sources.list.d/pgdg.list && \
    install_cpanm_and_carton && \
    # Install Perl module dependencies for MusicBrainz Server
    chown_mb(``$PERL_CARTON_PATH'') && \
    sudo_mb(``carton install$1'') && \
    # Clean build dependencies up
    apt_purge(`mbs_build_deps')')

m4_define(
    `chown_mb',
    `m4_dnl
mkdir -p $1 && \
    chown -R musicbrainz:musicbrainz $1')

m4_define(
    `copy_mb',
    `m4_dnl
COPY --chown=musicbrainz:musicbrainz $1')

m4_define(`MBS_ROOT', `/home/musicbrainz/musicbrainz-server')

m4_define(
    `setup_mbs_root',
    `m4_dnl
RUN useradd --create-home --shell /bin/bash musicbrainz

WORKDIR MBS_ROOT
RUN chown_mb(`MBS_ROOT')')

m4_define(
    `mbs_translations_deps',
    `m4_dnl
gettext
language-pack-de
language-pack-el
language-pack-es
language-pack-et
language-pack-fi
language-pack-fr
language-pack-he
language-pack-it
language-pack-ja
language-pack-nl
language-pack-sq
make
')

m4_define(
    `install_translations',
    `m4_dnl
copy_mb(``po/ po/'')
run_with_apt_cache \
    apt_install(`mbs_translations_deps') && \
    sudo_mb(``make -C po all_quiet'') && \
    sudo_mb(``make -C po deploy'')')

m4_define(
    `copy_common_mbs_files',
    `m4_dnl
copy_mb(``admin/ admin/'')
copy_mb(``app.psgi entities.json entities.mjs ./'')
copy_mb(``bin/ bin/'')
copy_mb(``lib/ lib/'')
copy_mb(``script/functions.sh script/git_info script/'')')

m4_define(
    `git_info',
    `m4_dnl
ENV `GIT_BRANCH' GIT_BRANCH
ENV `GIT_MSG' m4_changequote(`.quote_never_ever_use_in_a_commit_message.', `.end_quote_never_ever_use_in_a_commit_message.')GIT_MSG
m4_changequote`'m4_dnl
ENV `GIT_SHA' GIT_SHA')

m4_define(
    `xz_build_deps',
    `m4_dnl
autoconf
automake
build-essential
gettext
libtool
')

m4_define(
    `install_new_xz_utils',
    `m4_dnl
ARG XZ_VERSION=5.2.3
run_with_apt_cache \
    --mount=type=bind,source=docker/lasse_collin_pubkey.txt,target=/tmp/lasse_collin_pubkey.txt \
    apt_install(`xz_build_deps') && \
    cd /tmp && \
    sudo_mb(``gpg --import lasse_collin_pubkey.txt'') && \
    curl -sSLO https://tukaani.org/xz/xz-$XZ_VERSION.tar.gz && \
    curl -sSLO https://tukaani.org/xz/xz-$XZ_VERSION.tar.gz.sig && \
    sudo_mb(``gpg --verify xz-$XZ_VERSION.tar.gz.sig'') && \
    rm -fr /home/musicbrainz/.gnupg && \
    tar xvzf xz-$XZ_VERSION.tar.gz && \
    cd xz-$XZ_VERSION && \
    ./configure --disable-shared --prefix=/usr/local/ && \
    make && \
    make install && \
    cd ../ && \
    rm -fr xz-$XZ_VERSION* && \
    apt_purge(`xz_build_deps') && \
    cd /home/musicbrainz')

m4_divert`'m4_dnl
