#!/bin/sh

DIR=`dirname $0`
REL_VERSION=$1
CMDNAME=`basename $0`
if [ $# -ne 1 ]; then
  echo "usage: $CMDNAME rel_version" 1>&2
  exit 1
fi

IFS_BACKUP=$IFS
IFS='.'
set -- $REL_VERSION
MAJOR=$1
MINOR=$2
PATCH=`expr $3 + 1`
IFS=$IFS_BACKUP

PACKAGE_JSON=$DIR/package.json
QUNIT_TAP_JS=$DIR/lib/qunit-tap.js
PRE_VERSION="${MAJOR}.${MINOR}.${PATCH}pre"

cp ${PACKAGE_JSON} ${PACKAGE_JSON}.orig
cat ${PACKAGE_JSON}.orig | sed -e "s/$REL_VERSION/$PRE_VERSION/g" > ${PACKAGE_JSON}
rm ${PACKAGE_JSON}.orig

cp ${QUNIT_TAP_JS} ${QUNIT_TAP_JS}.orig
cat ${QUNIT_TAP_JS}.orig | sed -e "s/$REL_VERSION/$PRE_VERSION/g" > ${QUNIT_TAP_JS}
rm ${QUNIT_TAP_JS}.orig
