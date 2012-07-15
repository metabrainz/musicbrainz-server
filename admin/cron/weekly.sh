#!/bin/sh

mb_server=`dirname $0`/../..
cd $mb_server

eval `carton exec -- ./admin/ShowDBDefs`
carton exec -- ./admin/config.sh

# eof
