#!/bin/sh

mb_server=`dirname $0`/../..
eval `$mb_server/admin/ShowDBDefs`
. "$MB_SERVER_ROOT"/admin/config.sh
cd "$MB_SERVER_ROOT"

# Only run one "daily.sh" at a time
if [ "$1" != "gotlock" ]
then
	true ${LOCKFILE:=/tmp/daily.sh.lock}
	$MB_SERVER_ROOT/bin/runexclusive -f "$LOCKFILE" --no-wait \
		$MB_SERVER_ROOT/admin/cron/daily.sh gotlock
	if [ $? = 100 ]
	then
		echo "Aborted - there is already another daily.sh running"
	fi
	exit
fi
# We have the lock - on with the show.

. ./admin/functions.sh
make_temp_dir

# Collect stats
echo `date`" : Collecting statistics"
./admin/CollectStats.pl
echo `date`" : Plotting statistics"
./admin/statistics/GeneratePlot.pl "$TEMP_DIR"
chmod a+r "$TEMP_DIR"/plot*.png
mv "$TEMP_DIR"/plot*.png "$MB_SERVER_ROOT"/htdocs/generated/

DATETIME=`date +'%Y%m%d-%H%M%S'`

# Backup CVS
if [ "$CVS_DIR" != "" ]
then
	echo `date`" : Backing up CVS"
	tar -C / -cjf "$TEMP_DIR"/cvs-$DATETIME.tar.bz2 "$CVS_DIR"
	chown "$BACKUP_USER:$BACKUP_GROUP" "$TEMP_DIR"/cvs-$DATETIME.tar.bz2
	chmod "$BACKUP_FILE_MODE" "$TEMP_DIR"/cvs-$DATETIME.tar.bz2
	mv "$TEMP_DIR"/cvs-$DATETIME.tar.bz2 "$BACKUP_DIR"/
fi

# Backup the Wiki
if [ "$WIKI_DIRS" != "" ]
then
	echo `date`" : Backing up the Wiki"
	tar -C / -cjf "$TEMP_DIR"/wiki-$DATETIME.tar.bz2 $WIKI_DIRS
	chown "$BACKUP_USER:$BACKUP_GROUP" "$TEMP_DIR"/wiki-$DATETIME.tar.bz2
	chmod "$BACKUP_FILE_MODE" "$TEMP_DIR"/wiki-$DATETIME.tar.bz2
	mv "$TEMP_DIR"/wiki-$DATETIME.tar.bz2 "$BACKUP_DIR"/
fi

# Backup the Apache config files
if [ "$APACHE_CONFIG_DIRS" != "" ]
then
	echo `date`" : Backing up the Apache config files"
	tar -C / -cjf "$TEMP_DIR"/apacheconf-$DATETIME.tar.bz2 $APACHE_CONFIG_DIRS
	chown "$BACKUP_USER:$BACKUP_GROUP" "$TEMP_DIR"/apacheconf-$DATETIME.tar.bz2
	chmod "$BACKUP_FILE_MODE" "$TEMP_DIR"/apacheconf-$DATETIME.tar.bz2
	mv "$TEMP_DIR"/apacheconf-$DATETIME.tar.bz2 "$BACKUP_DIR"/
fi

# Backup Mailman
if [ "$MAILMAN_DIR" != "" ]
then
	echo `date`" : Backing up Mailman"
	tar -C / -cjf "$TEMP_DIR"/mailman-$DATETIME.tar.bz2 $MAILMAN_DIR
	chown "$BACKUP_USER:$BACKUP_GROUP" "$TEMP_DIR"/mailman-$DATETIME.tar.bz2
	chmod "$BACKUP_FILE_MODE" "$TEMP_DIR"/mailman-$DATETIME.tar.bz2
	mv "$TEMP_DIR"/mailman-$DATETIME.tar.bz2 "$BACKUP_DIR"/
fi

# Identify and remove unused artists
echo `date`" : Removing unused artists"
./admin/cleanup/EmptyArtists.pl --remove --summary --noverbose

# Dump all the data
# Only do this on the nominated days (0=Sun 6=Sat)
if date +%w | grep -q [36]
then
	FULL=1
fi
./admin/RunExport $FULL

# Create the reports
echo `date`" : Running reports"
OUTPUT=`
	nice ./admin/reports/RunReports 2>&1
` || echo "$OUTPUT"

# Process subscriptions
echo `date`" : Processing subscriptions"
./admin/ProcessSubscriptions

# `date`" : Updating language frequencies"
./admin/SetLanguageFrequencies

# Add missing track lengths
./admin/cleanup/FixTrackLength.pl

echo `date`" : Nightly jobs complete!"

# eof
