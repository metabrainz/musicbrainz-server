#!/bin/bash
mb_server=`dirname $0`/..
cd $mb_server

# Clear the Perl environment from anything now, and use the Carton environment
eval $(perl -Mlocal::lib)
export PERL_CARTON_PATH=$mb_server/local

#echo `date` : "Checking dependencies (if this fails on libintl-perl, don't worry)"
#[ -f .carton.lock.md5 ] && (grep $(md5sum carton.lock) .carton.lock.md5 >/dev/null || (rm -r local/ && carton install --deployment && git reset --hard -- carton.lock))
#md5sum carton.lock > .carton.lock.md5

echo `date` : "Rebuilding resources"
npm install
carton exec -- script/compile_resources.pl

echo `date` : "Building and installing translations"
make -C po all_quiet && make -C po deploy

echo `date` : Update complete
