#!/bin/bash

source /etc/mbs_constants.sh

BUILD_DIR=$MBS_ROOT/root/static/build
TMP_BUILD_DIR=$MBS_ROOT/root/static/tmp-build

_compile_static_resources() {
    mkdir -p $TMP_BUILD_DIR
    chown musicbrainz:musicbrainz $TMP_BUILD_DIR

    (
        cd $MBS_ROOT;
        export HOME=$MBS_HOME;
        export MBS_STATIC_BUILD_DIR=$TMP_BUILD_DIR;
        chpst -u musicbrainz:musicbrainz \
            carton exec -- ./script/compile_resources.sh
    )
}

_deploy_static_resources() {
    mkdir -p $BUILD_DIR
    chown musicbrainz:musicbrainz $BUILD_DIR

    # Delete files older than 30 days. If they're still unchanged, they'll just
    # have to be compressed again below.
    find $BUILD_DIR -type f -mtime +30 -not -name 'rev-manifest.json' -delete

    # -n will not clobber existing files, preserving their mtimes and allowing
    # us to avoid recompressing files that haven't changed (zopfli is slow).
    cp -Rn \
        $MBS_ROOT/root/{favicon.ico,robots.txt.*} \
        $TMP_BUILD_DIR/* \
        $BUILD_DIR/
    find $BUILD_DIR -type f -newermt '-10 seconds' | xargs zopfli -v

    # copy resources into the staticbrainz data volume
    for server in $STATICBRAINZ_SERVERS; do
        local host=$(echo $server | cut -d ':' -f 1)
        local port=$(echo $server | cut -d ':' -f 2)
        rsync \
            --ignore-existing \
            --recursive \
            --rsh "ssh -i $MBS_HOME/.ssh/musicbrainz_website.key -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p $port" \
            --verbose \
            $TMP/ \
            brainz@$host:/data/staticbrainz/
    done

    rm -rf "$TMP_BUILD_DIR"
}

compile_static_resources() {
    (flock -e 220; _compile_static_resources $@) 220>/tmp/.static_resources.lock
}

deploy_static_resources() {
    if [ -z "$STATICBRAINZ_SERVERS" ]; then
        return
    fi
    (flock -e 220; _deploy_static_resources) 220>/tmp/.static_resources.lock
}

compile_static_resources
deploy_static_resources
