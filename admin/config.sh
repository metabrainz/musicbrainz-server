#/bin/sh

# Miscellaneous configuration items go here.  You probably want to customise
# these to suit your installation.

# These could be moved into DBDefs.pm, so that ./admin/ShowDBDefs would do the
# whole lot in one go; the only reason they're here is that these things
# are, so far, only used by /bin/sh scripts, not Perl.

# Certain cron processes mail their output off separately if they fail.  This
# is where they get mailed to.
ADMIN_EMAILS="root"

# Were to put database exports, and replication data, for public consumption;
# who should own them, and what mode they should have.
FTP_DATA_DIR=/var/ftp/pub/musicbrainz/data
FTP_USER=root
FTP_GROUP=root
FTP_DIR_MODE=755
FTP_FILE_MODE=644

# Where to back things up to, who should own the backup files, and what mode
# those files should have.
# The backups include a full database export, and all replication data.
BACKUP_DIR=/home/mbbackup/data
BACKUP_USER=mbbackup
BACKUP_GROUP=mbbackup
BACKUP_DIR_MODE=700
BACKUP_FILE_MODE=600

# All executables are assumed to be on your PATH, so add any unusual
# requirements in here.
PATH=/usr/local/pgsql/bin:/usr/local/bin:$PATH
export PATH

# eof
