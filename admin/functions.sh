#!/bin/sh

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

# eof
