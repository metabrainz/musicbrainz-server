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
echo `date`" : Collecting statistics"
./CollectStats.pl
cd statistics
echo `date`" : Plotting statistics"
./GeneratePlot.pl $imagedir
chmod a+r $imagedir/plot*.png
cd ..

# Backup CVS
echo `date`" : Backing up CVS"
tar -cjf /tmp/cvs-backup.tar.bz2 $cvspath
chown $backupuser:$backupgroup /tmp/cvs-backup.tar.bz2
mv /tmp/cvs-backup.tar.bz2 $backupdir

# Backup the Wiki
echo `date`" : Backing up the Wiki"
tar -cjf /tmp/wiki-backup.tar.bz2 $wikipath
chown $backupuser:$backupgroup /tmp/wiki-backup.tar.bz2
mv /tmp/wiki-backup.tar.bz2 $backupdir

# Backup the Apache config files
echo `date`" : Backing up the Apache config files"
tar -cjf /tmp/apacheconf-backup.tar.bz2 $apacheconfigdirs
chown $backupuser:$backupgroup /tmp/apacheconf-backup.tar.bz2
mv /tmp/apacheconf-backup.tar.bz2 $backupdir

# Identify and remove unused artists
echo `date`" : Removing unused artists"
./cleanup/EmptyArtists.pl --remove --summary --noverbose

# Vacuum and analyze the database for peak performance
echo `date`" : Optimizing the database"
echo "VACUUM ANALYZE;" | psql $DB_PGOPTS -U $DB_USER $DB_NAME

# Dump all the data
echo `date`" : Making database snapshot"
./ExportAllTables --output-dir /tmp

# The unsanitised moderator data goes only to the backup dir.
# The other files go to both the backup and the FTP dirs.
mv /tmp/mbdump-moderator.tar.bz2 $backupdir
cp /tmp/mbdump*.tar.bz2 $ftpdir
mv /tmp/mbdump*.tar.bz2 $backupdir
chown $backupuser:$backupgroup $backupdir/mbdump*.tar.bz2

# Dump the RDF data
echo `date`" : Making RDF export"
nice ./RDFDump.pl /tmp/mbdump.rdf.bz2
mv /tmp/mbdump.rdf.bz2 $ftpdir

# Create the reports
echo `date`" : Running report 'caps'"
nice ./Caps.pl > $reportdir/caps.html
echo `date`" : Running report 'caps2'"
nice ./Caps2.pl > $reportdir/caps2.html
echo `date`" : Running report 'bad_entries'"
nice ./BadEntries.pl > $reportdir/bad_entries.html
echo `date`" : Running report 'unknown'"
nice ./Unknown.pl > $reportdir/unknown.html
echo `date`" : Running report 'wrong_charset'"
nice ./WrongCharset.pl > $reportdir/wrong_charset.html
echo `date`" : Running report 'DuplicateArtists'"
nice ./reports/DuplicateArtists.pl > $reportdir/DuplicateArtists.html
echo `date`" : Running report 'AlbumsToConvert'"
nice ./reports/AlbumsToConvert.pl > $reportdir/AlbumsToConvert.html
echo `date`" : Running report 'TRMsWithManyTracks'"
nice ./reports/TRMsWithManyTracks.pl > $reportdir/TRMsWithManyTracks.html
echo `date`" : Running report 'TracksWithManyTRMs'"
nice ./reports/TracksWithManyTRMs.pl > $reportdir/TracksWithManyTRMs.html
echo `date`" : Running report 'TracksNamedWithSequence'"
nice ./reports/TracksNamedWithSequence.pl > $reportdir/TracksNamedWithSequence.html

# Process subscriptions
echo `date`" : Processing subscriptions"
./ProcessSubscriptions

echo `date`" : Nightly jobs complete!"
cd -
