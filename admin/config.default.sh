#!/usr/bin/env bash

# Were to put database exports, and replication data, for public consumption;
# who should own them, and what mode they should have.
FTP_DATA_DIR=/var/ftp/pub/musicbrainz/data
FTP_USER=musicbrainz
FTP_GROUP=musicbrainz
FTP_DIR_MODE=755
FTP_FILE_MODE=644

# Same, but for JSON dumps.
JSON_DUMP_DIR=/home/musicbrainz/json-dumps
JSON_DUMP_USER=musicbrainz
JSON_DUMP_GROUP=musicbrainz
JSON_DUMP_DIR_MODE=755
JSON_DUMP_FILE_MODE=644

# Same, but for search index dumps.
SEARCH_INDEXES_DUMP_DIR=/home/musicbrainz/search-index-dumps
SEARCH_INDEXES_DUMP_USER=musicbrainz
SEARCH_INDEXES_DUMP_GROUP=musicbrainz
SEARCH_INDEXES_DUMP_DIR_MODE=755
SEARCH_INDEXES_DUMP_FILE_MODE=644

# Where to back things up to, who should own the backup files, and what mode
# those files should have.
# The backups include a full database export, and all replication data.
BACKUP_DIR=/home/musicbrainz/backup
BACKUP_USER=musicbrainz
BACKUP_GROUP=musicbrainz
BACKUP_DIR_MODE=700
BACKUP_FILE_MODE=600

RSYNC_FULLEXPORT_HOST='mbfullexport.local'
RSYNC_FULLEXPORT_PORT='65415'
RSYNC_FULLEXPORT_DIR="$FTP_DATA_DIR/fullexport"
RSYNC_FULLEXPORT_KEY='~/.ssh/rsync-data-fullexport'
RSYNC_LATEST_KEY='~/.ssh/rsync-data-latest'
