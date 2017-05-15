m4_divert(-1)

m4_define(
    `apt_install',
    `m4_dnl
apt-get update && \
    apt-get install --no-install-suggests --no-install-recommends -y $1 && \
    rm -rf /var/lib/apt/lists/*')

m4_define(`apt_purge', `apt-get purge --auto-remove -y $1')

m4_define(`sudo_mb', `sudo -E -H -u musicbrainz $1')

m4_define(`NODEJS_DEB', `nodejs_7.9.0-1nodesource1~xenial1_amd64.deb')

m4_define(
    `install_javascript',
    `m4_dnl
COPY package.json npm-shrinkwrap.json ./
RUN apt_install(``git'') && \
    cd /tmp && \
    curl -sLO https://deb.nodesource.com/node_7.x/pool/main/n/nodejs/NODEJS_DEB && \
    dpkg -i NODEJS_DEB && \
    cd - && \
    sudo_mb(``npm install$1'')
COPY .babelrc ./')

m4_define(
    `install_javascript_and_templates',
    `m4_dnl
install_javascript(`$1')

COPY gulpfile.js ./
COPY root/ root/
COPY \
    script/compile_resources.sh \
    script/dbdefs_to_js.pl \
    script/start_renderer.pl \
    script/

RUN chown_mb(`MBS_ROOT `/tmp/ttc'')')

m4_define(
    `mbs_build_deps',
    `m4_dnl
build-essential m4_dnl
libdb-dev m4_dnl
libexpat1-dev m4_dnl
libicu-dev m4_dnl
libperl-dev m4_dnl
libpq-dev m4_dnl
libssl-dev m4_dnl
libxml2-dev')

# postgresql-server-dev-9.5 provides pg_config, which is needed by InitDb.pl
# at run-time.
m4_define(
    `mbs_run_deps',
    `m4_dnl
ca-certificates m4_dnl
libdb5.3 m4_dnl
libexpat1 m4_dnl
libicu55 m4_dnl
libpq5 m4_dnl
libssl1.0.0 m4_dnl
perl m4_dnl
postgresql-client-9.5 m4_dnl
postgresql-server-dev-9.5')

m4_define(
    `test_db_run_deps',
    `m4_dnl
carton m4_dnl
postgresql-9.5-pgtap')

m4_define(
    `test_db_build_deps',
    `m4_dnl
gcc m4_dnl
libc6-dev m4_dnl
make m4_dnl
postgresql-server-dev-9.5')

m4_define(
    `install_perl_modules',
    `m4_dnl
ENV PERL_CARTON_PATH /home/musicbrainz/carton-local
ENV PERL_CPANM_OPT --notest --no-interactive

RUN apt_install(`mbs_build_deps mbs_run_deps') && \
    wget -q -O - https://cpanmin.us | perl - App::cpanminus && \
    cpanm Carton && \
    chown_mb(``$PERL_CARTON_PATH'') && \
    sudo_mb(``carton install$1'') && \
    apt_purge(`mbs_build_deps')')

m4_define(
    `chown_mb',
    `m4_dnl
mkdir -p $1 && \
    chown -R musicbrainz:musicbrainz $1')

m4_define(`MBS_ROOT', `/home/musicbrainz/musicbrainz-server')

m4_define(
    `setup_mbs_root',
    `m4_dnl
RUN useradd --create-home --shell /bin/bash musicbrainz

WORKDIR MBS_ROOT
RUN chown_mb(`MBS_ROOT')')

m4_define(
    `install_translations',
    `m4_dnl
COPY po/ po/
RUN chown_mb(`MBS_ROOT') && \
    apt_install(``gettext make'') && \
    sudo_mb(``make -C po all_quiet'') && \
    sudo_mb(``make -C po deploy'')')

m4_define(
    `copy_common_mbs_files',
    `m4_dnl
COPY admin/ admin/
COPY app.psgi entities.json ./
COPY bin/ bin/
COPY docker/scripts/mbs_constants.sh /etc/
COPY docker/scripts/consul-template-dedup-prefix /usr/local/bin/
COPY lib/ lib/
COPY script/functions.sh script/`git_info' script/

RUN chown_mb(`MBS_ROOT')')

m4_define(
    `git_info',
    `m4_dnl
ENV `GIT_BRANCH' GIT_BRANCH
ENV `GIT_MSG' GIT_MSG
ENV `GIT_SHA' GIT_SHA')

m4_divert`'m4_dnl
