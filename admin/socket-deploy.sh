#!/bin/bash

mb_server=`dirname $0`/..
cd $mb_server

echo `date` : Updating from Git
git pull --ff-only

CURRENT=$(pgrep -U `whoami` -f perl-fcgi-pm)

# Clear the Perl environment from anything now, and use the Carton environment
eval $(perl -Mlocal::lib)
export PERL_CARTON_PATH=$mb_server/local

echo `date` : "Checking dependencies (if this fails on libintl-perl, don't worry)"
[ -f .carton.lock.md5 ] && (grep $(md5sum carton.lock) .carton.lock.md5 >/dev/null || (carton install --deployment && git reset --hard -- carton.lock))
md5sum carton.lock > .carton.lock.md5

echo `date` : "Rebuilding resources"
carton exec -- script/compile_resources.pl

echo `date` : "Building and installing translations"
make -C po all_quiet && make -C po deploy

echo `date` : "Bringing a new set of processes up"
if carton exec -- plackup -D -Ilib -s FCGI -E deployment -S fcgi.socket --nproc=20 -keep-stderr=1
then
    echo `date` : "Terminating old processes"
    if [[ -z "$CURRENT" ]]
    then
        echo `date` : "Could not find a running server process"
    else
        kill $CURRENT
    fi
else
    echo `date` : New server could NOT be started
fi

echo `date` : Update complete
