#!/bin/sh

mb_server=`dirname $0`/../..
eval `$mb_server/admin/ShowDBDefs`

# TODO: If you are installing a main server, you need to update the paths below
ftpdir=/var/ftp/pub/musicbrainz/data
reportdir=/var/website/musicbrainz/prod/mb_server/htdocs/reports
imagedir=/var/website/musicbrainz/prod/mb_server/htdocs/generated
backupdir=/home/backup
backupuser=backup
backupgroup=users
cvspath=/var/cvs
wikipath=/var/mbwiki
apacheconfigdirs="/usr/local/perl58/apache/conf /usr/local/perl58/apache2/conf"

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

# Backup the Wiki
tar -cjvf /tmp/wiki-backup.tar.bz2 $wikipath
chown $backupuser:$backupgroup /tmp/wiki-backup.tar.bz2
mv /tmp/wiki-backup.tar.bz2 $backupdir

# Backup the Apache config files
tar -cjvf /tmp/apacheconf-backup.tar.bz2 $apacheconfigdirs
chown $backupuser:$backupgroup /tmp/apacheconf-backup.tar.bz2
mv /tmp/apacheconf-backup.tar.bz2 $backupdir

# Vacuum and analyze the database for peak performance
echo "VACUUM ANALYZE;" | psql $DB_PGOPTS -U $DB_USER $DB_NAME

# Dump all the data
./ExportAllTables --output-dir /tmp

# The unsanitised moderator data goes only to the backup dir.
# The other files go to both the backup and the FTP dirs.
mv /tmp/mbdump-moderator.tar.bz2 $backupdir
cp /tmp/mbdump*.tar.bz2 $ftpdir
mv /tmp/mbdump*.tar.bz2 $backupdir
chown $backupuser:$backupgroup $backupdir/mbdump*.tar.bz2

# Dump the RDF data
nice ./RDFDump.pl /tmp/mbdump.rdf.bz2
mv /tmp/mbdump.rdf.bz2 $ftpdir

# Create the reports
nice ./Caps.pl > $reportdir/caps.html
nice ./Caps2.pl > $reportdir/caps2.html
nice ./BadEntries.pl > $reportdir/bad_entries.html
nice ./Unknown.pl > $reportdir/unknown.html
nice ./WrongCharset.pl > $reportdir/wrong_charset.html
nice ./reports/DuplicateArtists.pl > $reportdir/DuplicateArtists.html
nice ./reports/AlbumsToConvert.pl > $reportdir/AlbumsToConvert.html
nice ./reports/TRMsWithManyTracks.pl > $reportdir/TRMsWithManyTracks.html
nice ./reports/TracksWithManyTRMs.pl > $reportdir/TracksWithManyTRMs.html
nice ./reports/TracksNamedWithSequence.pl > $reportdir/TracksNamedWithSequence.html

cd -
