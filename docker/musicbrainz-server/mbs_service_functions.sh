#!/bin/bash

source /etc/consul_template_helpers.sh

MBS_HOME=/home/musicbrainz
MBS_ROOT=$MBS_HOME/musicbrainz-server

_compile_static_resources() {
    local TASK=$1
    local BUILD_DIR=$MBS_ROOT/root/static/build
    mkdir -p $BUILD_DIR
    chown musicbrainz:musicbrainz $BUILD_DIR

    (
        cd $MBS_ROOT;
        export HOME=$MBS_HOME;
        chpst -u musicbrainz:musicbrainz \
            carton exec -- ./script/compile_resources.sh $TASK
    )
}

_push_static_resources() {
    local TMP=/tmp/staticbrainz-data
    mkdir $TMP $TMP/MB

    cp -R $MBS_ROOT/root/{favicon.ico,robots.txt.*,static/build/*} $TMP/MB/
    zopfli $TMP/MB/*
    # remove the originals
    find $TMP/MB/ -type f -not -name '*.gz' -exec rm '{}' \;

    # copy resources into the staticbrainz data volume
    rsync \
        --ignore-existing \
        --password-file=/etc/rsync_password_file \
        --recursive \
        $TMP/ \
        rsync://www-data@$STATICBRAINZ_HOST:${STATICBRAINZ_PORT:-873}/data/

    # cleanup
    rm -r $TMP
}

compile_static_resources() {
    (flock -e 220; _compile_static_resources $1) 220>/tmp/.static_resources.lock
}

push_static_resources() {
    if [ -z "$STATICBRAINZ_HOST" ]; then
        return
    fi
    (flock -e 220; _push_static_resources) 220>/tmp/.static_resources.lock
}

mbs_dependencies() {
    sv start consul-template || exit 1

    wait_for_file "$MBS_ROOT/lib/DBDefs.pm"

    compile_static_resources
    push_static_resources
}
