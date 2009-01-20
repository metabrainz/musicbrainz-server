#!/bin/sh

DIR=`dirname $0`
$DIR/psql READWRITE <$DIR/sql/CalculateRelatedTags.sql
