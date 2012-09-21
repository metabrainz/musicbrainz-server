#!/bin/sh
URL=file://$PWD/index.html
phantomjs run_qunit.js $URL
