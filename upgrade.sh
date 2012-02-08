#!/bin/bash

set -o errexit
cd `dirname $0`

eval `./admin/ShowDBDefs`

echo `date` : MBS-2799, update barcode column of "no barcode" releases
./admin/psql READWRITE < ./admin/sql/updates/20120123-no-barcode.sql

echo `date` : Done

# eof
