#!/bin/bash

set -o errexit
cd `dirname $0`

eval `./admin/ShowDBDefs`

echo `date` : Rewriting short link phrases for relationships
./admin/psql READWRITE < ./admin/sql/updates/20110524-short-link-phrases.sql

echo `date` : Upgrading relationship edit types to include short link phrases
./admin/sql/updates/20110524-short-link-phrase-edits.pl

echo `date` : Done

# eof
