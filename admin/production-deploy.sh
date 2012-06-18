#!/bin/bash
cd `dirname $0`

echo `date` : Updating from Git
git pull --ff-only

# Clear the Perl environment from anything now, and use the Carton environment
eval $(perl -Mlocal::lib)
export PERL_CARTON_PATH=`dirname $0`/local

echo `date` : "Checking dependencies (if this fails on libintl-perl, don't worry)"
[ -f .carton.lock.md5 ] && (grep $(md5sum carton.lock) .carton.lock.md5 >/dev/null || carton install --deployment)
md5sum carton.lock > .carton.lock.md5

echo `date` : "Rebuilding resources"
carton exec -- script/compile_resources.pl

echo `date` : Update complete
