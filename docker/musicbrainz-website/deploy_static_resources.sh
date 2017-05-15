#!/bin/bash

source /etc/mbs_constants.sh
source "$MBS_ROOT/script/functions.sh"

BUILD_DIR=$MBS_ROOT/root/static/build
TMP_BUILD_DIR=$MBS_ROOT/root/static/tmp-build
LOCK_FILE=/tmp/.static_resources.lock

_compile_static_resources() {
    mkdir -p $TMP_BUILD_DIR
    chown musicbrainz:musicbrainz $TMP_BUILD_DIR

    pushd "$MBS_ROOT" > /dev/null
    HOME="$MBS_HOME" MBS_STATIC_BUILD_DIR="$TMP_BUILD_DIR" \
        eval 'chpst -u musicbrainz:musicbrainz carton exec -- ./script/compile_resources.sh &'
    trap_jobs
    popd > /dev/null
}

_deploy_static_resources() {
    mkdir -p $BUILD_DIR
    chown musicbrainz:musicbrainz $BUILD_DIR

    # Delete files older than 30 days. If they're still unchanged, they'll just
    # have to be compressed again below.
    find $BUILD_DIR -type f -mtime +30 -not -name 'rev-manifest.json' -delete

    # -n will not clobber existing files, preserving their mtimes and allowing
    # us to avoid recompressing files that haven't changed (zopfli is slow).
    cp -Rn $TMP_BUILD_DIR/* $BUILD_DIR/

    # These files are not versioned with any hash, so must always be copied in
    # case they changed.
    cp $MBS_ROOT/root/{favicon.ico,robots.txt.*} $BUILD_DIR/

    find $BUILD_DIR -type f -newermt '-10 seconds' -not -name '*.gz' | xargs zopfli -v &
    trap_jobs

    # copy resources into the staticbrainz data volume
    pushd "$MBS_ROOT" > /dev/null
    ./bin/rsync-staticbrainz-files \
        rsync-staticbrainz-mb \
        "$BUILD_DIR/" \
        ./ \
        '--recursive' \
        &
    trap_jobs
    popd > /dev/null

    # We can copy the new rev-manifest.json only after the files it references
    # have been rsynced.
    cp $TMP_BUILD_DIR/rev-manifest.json $BUILD_DIR/

    rm -rf "$TMP_BUILD_DIR"
}

compile_static_resources() {
    (flock -e 220; _compile_static_resources $@) 220>$LOCK_FILE
}

deploy_static_resources() {
    if [ -z "$STATICBRAINZ_SERVERS" ]; then
        return
    fi
    (flock -e 220; _deploy_static_resources) 220>$LOCK_FILE
}

trap "rm -rf '$LOCK_FILE' '$TMP_BUILD_DIR'" EXIT

compile_static_resources
deploy_static_resources
