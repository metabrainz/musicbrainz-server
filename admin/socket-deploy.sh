#!/bin/bash

MUSICBRAINZ_USE_PROXY=1
export MUSICBRAINZ_USE_PROXY

mb_server=`dirname $0`/..
cd $mb_server

echo `date` : Updating from Git
git pull --ff-only

CURRENT=$(pgrep -U `whoami` -f perl-fcgi-pm)

eval $(perl -Mlocal::lib)

echo `date` : "Checking dependencies (if this fails on libintl-perl, don't worry)"
cpanm --notest --installdeps .

echo `date` : "Rebuilding resources"
script/compile_resources.pl

echo `date` : "Building and installing translations"
make -C po all_quiet && make -C po deploy

echo `date` : "Bringing a new set of processes up"
if plackup -D -Ilib -s FCGI -E deployment -S fcgi.socket --nproc=20 -keep-stderr=1
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
