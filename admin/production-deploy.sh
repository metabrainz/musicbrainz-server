#!/bin/bash
mb_server=`dirname $0`/..
cd $mb_server

echo `date` : Updating from Git
git pull --ff-only

# Clear the Perl environment from anything now, and use the Carton environment
eval $(perl -Mlocal::lib)
export PERL_CARTON_PATH=$mb_server/local

echo `date` : "Checking dependencies (if this fails on libintl-perl, don't worry)"
[ -f .carton.lock.md5 ] && (grep $(md5sum carton.lock) .carton.lock.md5 >/dev/null || carton install --deployment)
md5sum carton.lock > .carton.lock.md5

echo `date` : "Rebuilding resources"
carton exec -- script/compile_resources.pl

echo `date` : Update complete
