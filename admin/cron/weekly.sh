#!/bin/sh

mb_server=`dirname $0`/../..
cd $mb_server

eval `./admin/ShowDBDefs`
source ./admin/config.sh

# eof
