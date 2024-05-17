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
    `with_cpanm_cache',
    `--mount=type=cache,target=/home/musicbrainz/.cpanm,sharing=locked')

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
libpq-dev
libssl-dev
libxml2-dev
zlib1g-dev
pkg-config
')

# postgresql-server-dev-16 provides pg_config, which is needed by InitDb.pl
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
postgresql-client-16
postgresql-server-dev-16
zlib1g
')

m4_define(
    `test_db_run_deps',
    `m4_dnl
postgresql-16-pgtap
')

m4_define(
    `test_db_build_deps',
    `m4_dnl
build-essential
postgresql-server-dev-16
')

m4_define(
    `set_perl_install_args',
    `m4_dnl
ARG PERL_VERSION=5.38.2
ARG PERL_SRC_SUM=a0a31534451eb7b83c7d6594a497543a54d488bc90ca00f5e34762577f40655e')

m4_define(
    `install_perl',
    `m4_dnl
# Install Perl from source
    cd /usr/src && \
    curl -sSLO https://cpan.metacpan.org/authors/id/P/PE/PEVANS/perl-$PERL_VERSION.tar.gz && \
    echo "$PERL_SRC_SUM *perl-$PERL_VERSION.tar.gz" | sha256sum --strict --check - && \
    tar -xzf perl-$PERL_VERSION.tar.gz && \
    cd - && cd /usr/src/perl-$PERL_VERSION && \
    gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)" && \
    archBits="$(dpkg-architecture --query DEB_BUILD_ARCH_BITS)" && \
    archFlag="$([ "$archBits" = "64" ] && echo "-Duse64bitall" || echo "-Duse64bitint")" && \
    ./Configure \
        -Darchname="$gnuArch" "$archFlag" \
        -Duselargefiles -Duseshrplib -Dusethreads \
        -Dvendorprefix=/usr/local -Dman1dir=none -Dman3dir=none \
        -des && \
    make -j$(nproc) && \
    make install && \
    cd - && \
    rm -fr /usr/src/perl-$PERL_VERSION*')

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
        JSON::XS \
        && \
    rm -fr /root/.cpanm')

m4_define(
    `install_perl_and_mbs_run_deps',
    `m4_dnl

set_perl_install_args

set_cpanm_and_carton_env

set_cpanm_install_args

run_with_apt_cache \
    --mount=type=bind,source=docker/pgdg_pubkey.txt,target=/etc/apt/keyrings/pgdg.asc \
    echo "deb [signed-by=/etc/apt/keyrings/pgdg.asc] http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list && \
    apt_install(`mbs_build_deps mbs_run_deps') && \
    rm -f /etc/apt/sources.list.d/pgdg.list && \
    install_ts && \
    install_perl && \
    install_cpanm_and_carton && \
    # Clean build dependencies up
    apt_purge(`mbs_build_deps')')

m4_define(
    `install_perl_modules',
    `m4_dnl

run_with_apt_cache \
    with_cpanm_cache \
    --mount=type=bind,source=docker/pgdg_pubkey.txt,target=/etc/apt/keyrings/pgdg.asc \
    echo "deb [signed-by=/etc/apt/keyrings/pgdg.asc] http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list && \
    apt_install(`mbs_build_deps') && \
    rm -f /etc/apt/sources.list.d/pgdg.list && \
    # Install Perl module dependencies for MusicBrainz Server
    chown_mb(``/home/musicbrainz/.cpanm'') && \
    chown_mb(``$PERL_CARTON_PATH'') && \
    sudo_mb(``carton install$1'') && \
    # Clean build dependencies up
    apt_purge(`mbs_build_deps')')

m4_define(
    `install_ts',
    `m4_dnl
# Install ts (needed to run admin background task scripts locally)
    curl -sSL https://git.joeyh.name/index.cgi/moreutils.git/plain/ts?h=0.69 -o /usr/local/bin/ts && \
    echo "01b67f3d81e6205f01cc0ada87039293ebc56596955225300dd69ec1257124f5 */usr/local/bin/ts" | sha256sum --strict --check - && \
    chmod +x /usr/local/bin/ts')

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

m4_define(`with_beta_translations', m4_ifelse(GIT_BRANCH, `beta', 1, GIT_BRANCH, `test', 1, 0))
m4_define(`with_test_translations', m4_ifelse(GIT_BRANCH, `test', 1, 0))
m4_define(
    `mbs_translations_deps',
    `m4_dnl NOTE-LANGUAGES-1: These language packs must match the definition(s) of MB_LANGUAGES in deployment.
gettext
git
language-pack-de
language-pack-fr
language-pack-it
language-pack-nl
m4_ifelse(with_beta_translations, 1, `m4_dnl
language-pack-el
language-pack-es
language-pack-et
language-pack-fi
language-pack-he
language-pack-ja
language-pack-sq')
m4_ifelse(with_test_translations, 1, `m4_dnl
language-pack-da
language-pack-eo
language-pack-hr
language-pack-nb
language-pack-oc
language-pack-pl
language-pack-ru
language-pack-sv
language-pack-tr
language-pack-zh-hans
language-pack-zh-hant')
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
copy_mb(``script/create_test_db.sh script/database_exists script/dump_foreign_keys.pl script/functions.sh script/git_info script/'')
RUN mkdir -p t/sql
copy_mb(``t/sql/initial.sql t/sql/'')')

m4_define(
    `git_info',
    `m4_dnl
ENV `GIT_BRANCH' GIT_BRANCH
ENV `GIT_MSG' m4_changequote(`.quote_never_ever_use_in_a_commit_message.', `.end_quote_never_ever_use_in_a_commit_message.')GIT_MSG
m4_changequote`'m4_dnl
ENV `GIT_SHA' GIT_SHA')

m4_define(
    `chrome_for_testing_deps',
    `m4_dnl
libgbm1
libxkbcommon0
')

m4_define(
    `search_deps',
    `m4_dnl
lsof
maven
openjdk-8-jdk
openjdk-8-jre
python2
python2-dev
rabbitmq-server
virtualenv
')

m4_define(
    `selenium_caa_deps',
    `m4_dnl
python3
python3-dev
python3-distutils
python3-venv
software-properties-common
')

m4_divert`'m4_dnl
