#!/usr/bin/env bash

make_temp_dir()
{
    # Make a temporary directory dedicated to this invocation
    TEMP_DIR=`
        perl -MFile::Temp=tempdir -e'
                $dir = tempdir(
                        "mbscript-XXXXXXXX",
                        DIR => shift(),
                        CLEANUP => 0,
                        TMPDIR => 1,
                ) or die $!;
                print $dir;
        '
    ` || exit $?
    echo `date`" : Using temporary directory $TEMP_DIR"
    # Note that this only removes the directory if it's empty.  This is a
    # trade-off; we opt to not lose any files accidentally, at the risk of perhaps
    # accumulating temporary directories over time.
    trap 'rmdir "$TEMP_DIR"' 0 1 2 3 15
}

retry() {
    local attempts_remaining=5
    local delay=15
    while true; do
        "$@"
        status=$?
        if [[ $status -eq 0 ]]; then
            break
        fi
        let 'attempts_remaining -= 1'
        if [[ $attempts_remaining -gt 0 ]]; then
            echo "Command failed with exit status $status; retrying in $delay seconds"
            sleep $delay
            let 'delay *= 2'
        else
            echo 'Failed to execute command after 5 attempts'
            break
        fi
    done
}
