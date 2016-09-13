#!/bin/bash

TASKS="$@"

source /etc/consul_template_helpers.sh
source /etc/mbs_constants.sh

_compile_static_resources() {
    local TASKS="$@"
    local BUILD_DIR=$MBS_ROOT/root/static/build
    mkdir -p $BUILD_DIR
    chown musicbrainz:musicbrainz $BUILD_DIR

    (
        cd $MBS_ROOT;
        export HOME=$MBS_HOME;
        chpst -u musicbrainz:musicbrainz \
            carton exec -- ./script/compile_resources.sh $TASKS
    )
}

_push_static_resources() {
    local TMP=/tmp/staticbrainz-data
    mkdir $TMP $TMP/MB

    cp -R $MBS_ROOT/root/{favicon.ico,robots.txt.*,static/build/*} $TMP/MB/

    # compress, then remove the originals
    find $TMP/MB/ -type f -exec zopfli '{}' \;
    find $TMP/MB/ -type f -not -name '*.gz' -exec rm '{}' \;

    # copy resources into the staticbrainz data volume
    rsync \
        --ignore-existing \
        --password-file=/etc/staticbrainz_rsync_password \
        --recursive \
        $TMP/ \
        rsync://www-data@$STATICBRAINZ_HOST:${STATICBRAINZ_PORT:-873}/data/

    # cleanup
    rm -r $TMP
}

compile_static_resources() {
    (flock -e 220; _compile_static_resources $@) 220>/tmp/.static_resources.lock
}

push_static_resources() {
    if [ -z "$STATICBRAINZ_HOST" ]; then
        return
    fi
    (flock -e 220; _push_static_resources) 220>/tmp/.static_resources.lock
}

compile_static_resources $TASKS
push_static_resources
