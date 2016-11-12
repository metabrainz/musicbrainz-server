m4_define(`apt_install', `m4_dnl
apt-get update && \
    apt-get install --no-install-suggests --no-install-recommends -y \
        $1 && \
    rm -rf /var/lib/apt/lists/*')m4_dnl
m4_define(`apt_purge', `apt-get purge --auto-remove -y $1')m4_dnl
m4_define(`sudo_mb', `sudo -E -H -u musicbrainz $1')m4_dnl
m4_define(`install_javascript', `m4_dnl
COPY package.json npm-shrinkwrap.json ./
RUN apt_install(``git nodejs nodejs-legacy npm'') && \
    sudo_mb(``npm install --only=production'') && \
    apt_purge(``git npm'')
COPY .babelrc ./')m4_dnl
m4_define(`install_javascript_and_templates', `m4_dnl
install_javascript()

COPY gulpfile.js ./
COPY root/ root/
COPY script/compile_resources.sh script/dbdefs_to_js.pl script/

RUN chown_mb(``$MBS_ROOT /tmp/ttc'')')m4_dnl
m4_define(`chown_mb', `m4_dnl
mkdir -p $1 && \
    chown -R musicbrainz:musicbrainz $1')m4_dnl
m4_define(`setup_mbs_root', `m4_dnl
RUN useradd --create-home --shell /bin/bash musicbrainz

ARG MBS_ROOT=/home/musicbrainz/musicbrainz-server
WORKDIR $MBS_ROOT
RUN chown_mb(``$MBS_ROOT'')')m4_dnl
m4_define(`install_translations', `m4_dnl
COPY po/ po/
RUN chown_mb(``$MBS_ROOT'') && \
    apt_install(``gettext make'') && \
    sudo_mb(``make -C po all_quiet'') && \
    sudo_mb(``make -C po deploy'') && \
    apt_purge(``gettext make'')')m4_dnl
m4_define(`git_info', `m4_dnl
ENV `GIT_INFO' GIT_INFO')m4_dnl
