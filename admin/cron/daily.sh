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
./GeneratePlot.pl $imagedir/stats_30_days.png
chmod a+r $imagedir/stats_30_days.png
cd ..

# Backup CVS
tar -cIvf /tmp/cvs-backup.tar.bz2 $cvspath
chown $backupuser:$backupgroup /tmp/cvs-backup.tar.bz2
mv /tmp/cvs-backup.tar.bz2 $backupdir

# Vacuum and analyze the database for peak performance
echo "VACUUM ANALYZE;" | psql musicbrainz

# Dump the data
nice ./MBDump.pl /tmp/mbdump.tar.bz2
mv /tmp/mbdump.tar.bz2 $ftpdir
nice ./MBDump.pl -p /tmp/mbdump-private.tar.bz2
chown $backupuser:$backupgroup /tmp/mbdump-private.tar.bz2
mv /tmp/mbdump-private.tar.bz2 $backupdir

# Dump the RDF data
nice ./RDFDump.pl /tmp/mbdump.rdf.bz2
mv /tmp/mbdump.rdf.bz2 $ftpdir

# Create the reports
nice ./Caps.pl > $reportdir/caps.html
nice ./BadEntries.pl > $reportdir/bad_entries.html
nice ./Unknown.pl > $reportdir/unknown.html

cd -
