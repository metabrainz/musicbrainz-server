#!/bin/sh

mb_server=`dirname $0`/../..
eval `$mb_server/admin/ShowDBDefs`
. $mb_server/admin/config.sh
cd $mb_server

. ./admin/functions.sh
make_temp_dir

# Collect stats
echo `date`" : Collecting statistics"
./admin/CollectStats.pl
echo `date`" : Plotting statistics"
./admin/statistics/GeneratePlot.pl "$TEMP_DIR"
chmod a+r "$TEMP_DIR"/plot*.png
mv "$TEMP_DIR"/plot*.png "$mb_server"/htdocs/generated/

# Backup CVS
if [ "$CVS_DIR" != "" ]
then
	echo `date`" : Backing up CVS"
	tar -C / -cjf "$TEMP_DIR"/cvs-backup.tar.bz2 "$CVS_DIR"
	chown "$BACKUP_USER:$BACKUP_GROUP" "$TEMP_DIR"/cvs-backup.tar.bz2
	chmod "$BACKUP_FILE_MODE" "$TEMP_DIR"/cvs-backup.tar.bz2
	mv "$TEMP_DIR"/cvs-backup.tar.bz2 "$BACKUP_DIR"/
fi

# Backup the Wiki
if [ "$WIKI_DIR" != "" ]
then
	echo `date`" : Backing up the Wiki"
	tar -C / -cjf "$TEMP_DIR"/wiki-backup.tar.bz2 "$WIKI_DIR"
	chown "$BACKUP_USER:$BACKUP_GROUP" "$TEMP_DIR"/wiki-backup.tar.bz2
	chmod "$BACKUP_FILE_MODE" "$TEMP_DIR"/wiki-backup.tar.bz2
	mv "$TEMP_DIR"/wiki-backup.tar.bz2 "$BACKUP_DIR"/
fi

# Backup the Apache config files
if [ "$APACHE_CONFIG_DIRS" != "" ]
then
	echo `date`" : Backing up the Apache config files"
	tar -C / -cjf "$TEMP_DIR"/apacheconf-backup.tar.bz2 $APACHE_CONFIG_DIRS
	chown "$BACKUP_USER:$BACKUP_GROUP" "$TEMP_DIR"/apacheconf-backup.tar.bz2
	chmod "$BACKUP_FILE_MODE" "$TEMP_DIR"/apacheconf-backup.tar.bz2
	mv "$TEMP_DIR"/apacheconf-backup.tar.bz2 "$BACKUP_DIR"/
fi

# Identify and remove unused artists
echo `date`" : Removing unused artists"
./admin/cleanup/EmptyArtists.pl --remove --summary --noverbose

# Vacuum and analyze the database for peak performance
echo `date`" : Optimizing the database"
echo "VACUUM ANALYZE;" | psql $DB_PGOPTS -U "$DB_USER" "$DB_NAME"

# Dump all the data
# Only do this every other day
if perl -e'exit(int(time()/86400) % 2)'
then
	FULL=1
fi
./admin/RunExport $FULL

# Create the reports
echo `date`" : Running reports"
nice ./admin/reports/RunReports

# Process subscriptions
echo `date`" : Processing subscriptions"
./admin/ProcessSubscriptions

# Lookup Amazon pairings
echo `date`" : Processing Amazon matches"
./admin/aws/Match.pl --daily --noverbose --summary

echo `date`" : Nightly jobs complete!"

# eof
