#!/bin/sh

# TODO: If you are installing a main server, you need to update the paths below
ftpdir=/var/ftp/pub/musicbrainz/data
reportdir=/var/website/musicbrainz/prod/htdocs/reports
imagedir=/var/website/musicbrainz/prod/htdocs/images
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
./GeneratePlot.pl $imagedir/basic_stats.png $imagedir/mod_stats.png
chmod a+r $imagedir/basic_stats.png
chmod a+r $imagedir/mod_stats.png
cd ..

# Backup CVS
tar -cjvf /tmp/cvs-backup.tar.bz2 $cvspath
chown $backupuser:$backupgroup /tmp/cvs-backup.tar.bz2
mv /tmp/cvs-backup.tar.bz2 $backupdir

# Vacuum and analyze the database for peak performance
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

# Dump the RDF data
nice ./RDFDump.pl /tmp/mbdump.rdf.bz2
mv /tmp/mbdump.rdf.bz2 $ftpdir

# Create the reports
nice ./Caps.pl > $reportdir/caps.html
nice ./BadEntries.pl > $reportdir/bad_entries.html
nice ./Unknown.pl > $reportdir/unknown.html

cd -
