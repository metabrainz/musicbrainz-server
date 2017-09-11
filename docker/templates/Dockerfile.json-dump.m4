m4_include(`server_base.m4')m4_dnl

COPY docker/musicbrainz-json-dump/lasse_collin_pubkey.txt /tmp/

RUN apt_install(`autoconf automake gettext libtool rsync') && \
    cd /tmp && \
    sudo_mb(`gpg --import lasse_collin_pubkey.txt') && \
    rm lasse_collin_pubkey.txt && \
    wget https://tukaani.org/xz/xz-5.2.3.tar.gz && \
    wget https://tukaani.org/xz/xz-5.2.3.tar.gz.sig && \
    sudo_mb(`gpg --verify xz-5.2.3.tar.gz.sig') && \
    rm xz-5.2.3.tar.gz.sig && \
    tar xvzf xz-5.2.3.tar.gz && \
    cd xz-5.2.3 && \
    ./configure --disable-shared --prefix=/usr/local/ && \
    make && \
    make install && \
    cd ../ && \
    rm -r xz-5.2.3* && \
    apt_purge(`autoconf automake libtool') && \
    cd /home/musicbrainz

RUN chown_mb(`/home/musicbrainz/log') && \
    chown_mb(`/home/musicbrainz/json-dumps/full') && \
    chown_mb(`/home/musicbrainz/json-dumps/incremental')

copy_common_mbs_files

COPY \
    docker/musicbrainz-json-dump/consul-template-json-dump.conf \
    /etc/

COPY \
    docker/musicbrainz-json-dump/consul-template.service \
    /etc/service/consul-template/run
RUN chmod 755 /etc/service/consul-template/run

COPY docker/musicbrainz-json-dump/crontab /var/spool/cron/crontabs/musicbrainz

RUN chown musicbrainz:musicbrainz /var/spool/cron/crontabs/musicbrainz && \
    chmod 600 /var/spool/cron/crontabs/musicbrainz

COPY docker/scripts/start_musicbrainz_server.sh /usr/local/bin/

COPY docker/templates/DBDefs.pm.ctmpl lib/

git_info
