#!/bin/sh

# TODO: If you are installing a main server, you need to update the paths below
ftpdir=/var/ftp/pub/musicbrainz/data
reportdir=/var/website/musicbrainz/prod/mb_server/htdocs/reports
imagedir=/var/website/musicbrainz/prod/mb_server/htdocs/generated
backupdir=/home/backup
backupuser=backup
backupgroup=users
cvspath=/var/cvs

export PATH=/bin:/usr/bin:/usr/local/pgsql/bin

# Go to the admin dir
cd ..

# Collect stats
./CollectStats.pl
cd statistics
./GeneratePlot.pl $imagedir
chmod a+r $imagedir/plot*.png
cd ..

# Backup CVS
tar -cjvf /tmp/cvs-backup.tar.bz2 $cvspath
chown $backupuser:$backupgroup /tmp/cvs-backup.tar.bz2
mv /tmp/cvs-backup.tar.bz2 $backupdir

# Vacuum and analyze the database for peak performance
# FIXME use DB_USER, DB_NAME
echo "VACUUM ANALYZE;" | psql musicbrainz

# Dump the main data
nice ./MBDump.pl --core -o /tmp/mbdump.tar.bz2
cp /tmp/mbdump.tar.bz2 $backupdir
chown $backupuser:$backupgroup $backupdir/mbdump.tar.bz2
mv /tmp/mbdump.tar.bz2 $ftpdir

# Dump the derived data
nice ./MBDump.pl --derived -o /tmp/mbdump-derived.tar.bz2
cp /tmp/mbdump-derived.tar.bz2 $ftpdir
mv /tmp/mbdump-derived.tar.bz2 $backupdir
chown $backupuser:$backupgroup $backupdir/mbdump-derived.tar.bz2

# Dump the sanitized moderation data
nice ./MBDump.pl --moderation --sanitised -o /tmp/mbdump-moderation.tar.bz2
mv /tmp/mbdump-moderation.tar.bz2 $ftpdir

# Dump the unsanitized moderation data for backup
nice ./MBDump.pl --moderation --nosanitised -o /tmp/mbdump-moderation.tar.bz2
mv /tmp/mbdump-moderation.tar.bz2 $backupdir
chown $backupuser:$backupgroup $backupdir/mbdump.tar.bz2

# Dump the agent arts provided data
nice ./MBDump.pl --relation -o /tmp/mbdump-artistrelation.tar.bz2
cp /tmp/mbdump-artistrelation.tar.bz2 $ftpdir
mv /tmp/mbdump-artistrelation.tar.bz2 $backupdir

chown $backupuser:$backupgroup $backupdir/mbdump-derived.tar.bz2
# Dump the RDF data
nice ./RDFDump.pl /tmp/mbdump.rdf.bz2
mv /tmp/mbdump.rdf.bz2 $ftpdir

# Create the reports
nice ./Caps.pl > $reportdir/caps.html
nice ./Caps2.pl > $reportdir/caps2.html
nice ./BadEntries.pl > $reportdir/bad_entries.html
nice ./Unknown.pl > $reportdir/unknown.html
nice ./WrongCharset.pl > $reportdir/wrong_charset.html

cd -
