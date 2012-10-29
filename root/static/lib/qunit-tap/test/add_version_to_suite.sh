#!/bin/sh

TARGET_VERSION=$1
CMDNAME=`basename $0`
if [ $# -ne 1 ]; then
  echo "usage: $CMDNAME version" 1>&2
  exit 1
fi

DIR=`dirname $0`
TEMP_ARCHIVE_PATH=$DIR/qunit_downloaded.tar.gz

wget https://github.com/jquery/qunit/tarball/v${TARGET_VERSION} -O ${TEMP_ARCHIVE_PATH}
QUNIT_JS_PATH=`tar ztf $TEMP_ARCHIVE_PATH | grep 'qunit.js'`
QUNIT_CSS_PATH=`tar ztf $TEMP_ARCHIVE_PATH | grep 'qunit.css'`
tar zxf $TEMP_ARCHIVE_PATH $QUNIT_JS_PATH
tar zxf $TEMP_ARCHIVE_PATH $QUNIT_CSS_PATH

mkdir -p $DIR/compatibility/$TARGET_VERSION
cp $QUNIT_JS_PATH $DIR/compatibility/$TARGET_VERSION/qunit.js
mv $QUNIT_JS_PATH $DIR/compatibility/stable/qunit.js
mv $QUNIT_CSS_PATH $DIR/compatibility/stable/qunit.css

rm -rf `echo $QUNIT_JS_PATH | awk -F/ '{print $1}'`
rm $TEMP_ARCHIVE_PATH

echo "added $DIR/compatibility/$TARGET_VERSION/qunit.js"
