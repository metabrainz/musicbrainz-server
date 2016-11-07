#!/bin/bash

# Where to send admin emails (currently only ModBot output).
ADMIN_EMAILS=root

# Were to put database exports, and replication data, for public consumption;
# who should own them, and what mode they should have.
FTP_DATA_DIR=/var/ftp/pub/musicbrainz/data
FTP_USER=musicbrainz
FTP_GROUP=musicbrainz
FTP_DIR_MODE=755
FTP_FILE_MODE=644

# Where to back things up to, who should own the backup files, and what mode
# those files should have.
# The backups include a full database export, and all replication data.
BACKUP_DIR=/home/musicbrainz/backup
BACKUP_USER=musicbrainz
BACKUP_GROUP=musicbrainz
BACKUP_DIR_MODE=700
BACKUP_FILE_MODE=600

RSYNC_FULLEXPORT_SERVER='ftp-data@ftp-data.localdomain'
