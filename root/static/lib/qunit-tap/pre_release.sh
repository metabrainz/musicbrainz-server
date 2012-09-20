#!/bin/sh

DIR=`dirname $0`
PRE_VERSION=$1
CMDNAME=`basename $0`
if [ $# -ne 1 ]; then
  echo "usage: $CMDNAME pre_version" 1>&2
  exit 1
fi

PACKAGE_JSON=$DIR/package.json
QUNIT_TAP_JS=$DIR/lib/qunit-tap.js
REL_VERSION=`echo $PRE_VERSION | sed -e 's/pre//g'`

cp ${PACKAGE_JSON} ${PACKAGE_JSON}.orig
cat ${PACKAGE_JSON}.orig | sed -e "s/$PRE_VERSION/$REL_VERSION/g" > ${PACKAGE_JSON}
rm ${PACKAGE_JSON}.orig

cp ${QUNIT_TAP_JS} ${QUNIT_TAP_JS}.orig
cat ${QUNIT_TAP_JS}.orig | sed -e "s/$PRE_VERSION/$REL_VERSION/g" > ${QUNIT_TAP_JS}
rm ${QUNIT_TAP_JS}.orig
