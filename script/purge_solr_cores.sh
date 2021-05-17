#!/usr/bin/env bash

set -e

cd "$(dirname "${BASH_SOURCE[0]}")/../"

SEARCH_SERVER=$(perl -Ilib -e 'use DBDefs; print DBDefs->SEARCH_SERVER;')

declare -a SOLR_CORES
SOLR_CORES=(
    annotation
    artist
    area
    cdstub
    editor
    event
    instrument
    label
    place
    recording
    release
    release-group
    series
    tag
    url
    work
)

for CORE in "${SOLR_CORES[@]}"; do
    curl \
        "$SEARCH_SERVER/$CORE/update?softCommit=true" \
        --header 'Content-type: text/xml' \
        --data-binary '<delete><query>*:*</query></delete>'
done
