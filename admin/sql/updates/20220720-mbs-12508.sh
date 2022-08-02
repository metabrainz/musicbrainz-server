#!/usr/bin/env bash

set -e

MB_SERVER_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../" && pwd)
cd "$MB_SERVER_ROOT"

: ${REPLICATION_TYPE:=$(perl -Ilib -e 'use DBDefs; print DBDefs->REPLICATION_TYPE;')}

if [ "$REPLICATION_TYPE" != '2' ]
then
    echo `date`: This is not a mirror server. Exiting.
    exit 1
fi

: ${DATABASE:=MAINTENANCE}

. admin/functions.sh

if [[ ! -v TEMP_DIR ]]
then
    make_temp_dir
fi

DUMP_FILE="$TEMP_DIR"/mbdump-derived.tar.bz2

if [[ ! -f "$DUMP_FILE" ]]
then
    FTP_DATA_URL='http://ftp.musicbrainz.org/pub/musicbrainz/data'

    echo `date`: Retrieving LATEST from FTP
    LATEST=$(curl "$FTP_DATA_URL"/fullexport/LATEST)

    echo `date`: Retrieving mbdump-derived.tar.bz2 from FTP
    curl \
        -o "$DUMP_FILE" \
        "$FTP_DATA_URL"/fullexport/"$LATEST"/mbdump-derived.tar.bz2
fi

echo `date`: Saving existing tag data to tmp tables
OUTPUT=$(
    cat <<'SQL' | ./admin/psql "$DATABASE" 2>&1
\set ON_ERROR_STOP 1
CREATE TABLE IF NOT EXISTS tmp_area_tag_mbs_12508 AS TABLE area_tag;
CREATE TABLE IF NOT EXISTS tmp_artist_tag_mbs_12508 AS TABLE artist_tag;
CREATE TABLE IF NOT EXISTS tmp_event_tag_mbs_12508 AS TABLE event_tag;
CREATE TABLE IF NOT EXISTS tmp_instrument_tag_mbs_12508 AS TABLE instrument_tag;
CREATE TABLE IF NOT EXISTS tmp_label_tag_mbs_12508 AS TABLE label_tag;
CREATE TABLE IF NOT EXISTS tmp_place_tag_mbs_12508 AS TABLE place_tag;
CREATE TABLE IF NOT EXISTS tmp_recording_tag_mbs_12508 AS TABLE recording_tag;
CREATE TABLE IF NOT EXISTS tmp_release_tag_mbs_12508 AS TABLE release_tag;
CREATE TABLE IF NOT EXISTS tmp_release_group_tag_mbs_12508 AS TABLE release_group_tag;
CREATE TABLE IF NOT EXISTS tmp_series_tag_mbs_12508 AS TABLE series_tag;
CREATE TABLE IF NOT EXISTS tmp_work_tag_mbs_12508 AS TABLE work_tag;
CREATE TABLE IF NOT EXISTS tmp_tag_mbs_12508 AS TABLE tag;
SQL
) || ( echo "$OUTPUT" && exit 1 )

echo `date`: Clearing existing tag tables
OUTPUT=$(
    cat <<'SQL' | ./admin/psql "$DATABASE" 2>&1
\set ON_ERROR_STOP 1
TRUNCATE area_tag;
TRUNCATE artist_tag;
TRUNCATE event_tag;
TRUNCATE instrument_tag;
TRUNCATE label_tag;
TRUNCATE place_tag;
TRUNCATE recording_tag;
TRUNCATE release_tag;
TRUNCATE release_group_tag;
TRUNCATE series_tag;
TRUNCATE work_tag;
TRUNCATE tag CASCADE;
-- Shouldn't exist on mirrors, but just in case
DROP TRIGGER IF EXISTS delete_unused_tag ON tag;
SQL
) || ( echo "$OUTPUT" && exit 1 )

echo `date`: Importing tag data from latest dump
./admin/MBImport.pl \
    --tmp-dir "$TEMP_DIR" \
    --database "$DATABASE" \
    --table tag \
    --table area_tag \
    --table artist_tag \
    --table event_tag \
    --table instrument_tag \
    --table label_tag \
    --table place_tag \
    --table recording_tag \
    --table release_tag \
    --table release_group_tag \
    --table series_tag \
    --table work_tag \
    "$DUMP_FILE"

echo `date`: Restoring saved tag data from tmp tables
OUTPUT=$(
cat <<'SQL' | ./admin/psql "$DATABASE" 2>&1
\set ON_ERROR_STOP 1

INSERT INTO area_tag (SELECT * FROM tmp_area_tag_mbs_12508)
    ON CONFLICT (area, tag) DO UPDATE SET count = excluded.count, last_updated = excluded.last_updated;
DROP TABLE tmp_area_tag_mbs_12508;

INSERT INTO artist_tag (SELECT * FROM tmp_artist_tag_mbs_12508)
    ON CONFLICT (artist, tag) DO UPDATE SET count = excluded.count, last_updated = excluded.last_updated;
DROP TABLE tmp_artist_tag_mbs_12508;

INSERT INTO event_tag (SELECT * FROM tmp_event_tag_mbs_12508)
    ON CONFLICT (event, tag) DO UPDATE SET count = excluded.count, last_updated = excluded.last_updated;
DROP TABLE tmp_event_tag_mbs_12508;

INSERT INTO instrument_tag (SELECT * FROM tmp_instrument_tag_mbs_12508)
    ON CONFLICT (instrument, tag) DO UPDATE SET count = excluded.count, last_updated = excluded.last_updated;
DROP TABLE tmp_instrument_tag_mbs_12508;

INSERT INTO label_tag (SELECT * FROM tmp_label_tag_mbs_12508)
    ON CONFLICT (label, tag) DO UPDATE SET count = excluded.count, last_updated = excluded.last_updated;
DROP TABLE tmp_label_tag_mbs_12508;

INSERT INTO place_tag (SELECT * FROM tmp_place_tag_mbs_12508)
    ON CONFLICT (place, tag) DO UPDATE SET count = excluded.count, last_updated = excluded.last_updated;
DROP TABLE tmp_place_tag_mbs_12508;

INSERT INTO recording_tag (SELECT * FROM tmp_recording_tag_mbs_12508)
    ON CONFLICT (recording, tag) DO UPDATE SET count = excluded.count, last_updated = excluded.last_updated;
DROP TABLE tmp_recording_tag_mbs_12508;

INSERT INTO release_tag (SELECT * FROM tmp_release_tag_mbs_12508)
    ON CONFLICT (release, tag) DO UPDATE SET count = excluded.count, last_updated = excluded.last_updated;
DROP TABLE tmp_release_tag_mbs_12508;

INSERT INTO release_group_tag (SELECT * FROM tmp_release_group_tag_mbs_12508)
    ON CONFLICT (release_group, tag) DO UPDATE SET count = excluded.count, last_updated = excluded.last_updated;
DROP TABLE tmp_release_group_tag_mbs_12508;

INSERT INTO series_tag (SELECT * FROM tmp_series_tag_mbs_12508)
    ON CONFLICT (series, tag) DO UPDATE SET count = excluded.count, last_updated = excluded.last_updated;
DROP TABLE tmp_series_tag_mbs_12508;

INSERT INTO work_tag (SELECT * FROM tmp_work_tag_mbs_12508)
    ON CONFLICT (work, tag) DO UPDATE SET count = excluded.count, last_updated = excluded.last_updated;
DROP TABLE tmp_work_tag_mbs_12508;

INSERT INTO tag (SELECT * FROM tmp_tag_mbs_12508)
    ON CONFLICT (id) DO UPDATE SET ref_count = excluded.ref_count;
DROP TABLE tmp_tag_mbs_12508;
SQL
) || ( echo "$OUTPUT" && exit 1 )

rm "$DUMP_FILE"
