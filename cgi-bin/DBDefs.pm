#____________________________________________________________________________
#
#   MusicBrainz -- the open internet music database
#
#   Copyright (C) 1998 Robert Kaye
#
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program; if not, write to the Free Software
#   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#
#   $Id$
#____________________________________________________________________________

package DBDefs;

################################################################################
# Directories
################################################################################

# The Server Root, i.e. the parent directory of admin, cgi-bin and htdocs
sub MB_SERVER_ROOT	{ "/home/httpd/musicbrainz/mb_server" }
# The htdocs directory
sub HTDOCS_ROOT		{ MB_SERVER_ROOT() . "/htdocs" }
# The data import directory (used by some reports)
sub DATA_IMPORT_DIR	{ "/home/httpd/musicbrainz/data-import" }

# These two settings specify where to create the Apache::Session files
# that are needed for HTTP session persistence
sub LOCK_DIR		{ "/home/httpd/musicbrainz/locks" }
sub SESSION_DIR		{ "/home/httpd/musicbrainz/sessions" }

# Mason's data_dir
sub MASON_DIR		{ "/home/httpd/musicbrainz/mason" }

# Our cache directory - see MusicBrainz::Server::Cache
sub CACHE_DIR		{ "/home/httpd/musicbrainz/cache" }



################################################################################
# The Database
################################################################################

# The DBI connection string for your database
sub DSN		{ 'dbi:Pg:dbname=musicbrainz_db' }

# The name of the database
sub DB_NAME	{ 'musicbrainz_db' }
# The database user that has access to the database listed above
sub DB_USER	{ 'musicbrainz_user' }
# The password for the above user
sub DB_PASSWD	{ '' }
# Other command-line options to pass to Postgres programs, e.g. "-h otherhost"
sub DB_PGOPTS	{ '' }



################################################################################
# HTTP Server Names
################################################################################

# The host names of the HTML / RDF parts of the server
# To use a port number other than 80, add it like so: "myhost:8000"
sub WEB_SERVER	{ "www.musicbrainz.example.com" }
sub RDF_SERVER	{ "rdf.musicbrainz.example.com" }



################################################################################
# Mail Settings
################################################################################

sub SMTP_SERVER { "localhost" }
# This value should be set to some secret value for your server.  Any old
# string of stuff should do; something suitably long and random, like for
# passwords.  However you MUST change it from the default
# value (the empty string).  This is so an attacker can't just look in CVS and
# see the default secret value, and then use it to attack your server.
sub SMTP_SECRET_CHECKSUM { "" }
sub EMAIL_VERIFICATION_TIMEOUT { 604800 } # one week


################################################################################
# Other Settings
################################################################################

# Set this value to something true (e.g. 1) to set the server to read-only.
# To date, this option is widely ignored in the code; don't be surprised if you
# set it to true and find that writes are still possible.
sub DB_READ_ONLY { 0 }

# Set this value to a message that you'd like to display to users when
# they attempt to write to your read-only database (not used if DB_READ_ONLY
# is false)
sub DB_READ_ONLY_MESSAGE { <<EOF }
This server is temporarily in read-only mode
for database maintainance.
EOF

# If this is the live MusicBrainz server, change this to 'undef'.
# If it's not, set it to some word describing the type of server; e.g.
# "development", "test", etc.
# Mainly this option just affects the banner across the top of each page;
# also there are a couple of "debug" type features which are only active
# when not on the live server.
sub DB_STAGING_SERVER { "development" }

# This defines the version of the server.  Only used by things which display
# the server version, e.g. at the foot of each web page.  Basically it can be
# whatever you want.
sub VERSION { "TRUNK" }

# Defines the expiry period of new moderations; i.e. age of the moderation
# after which a simple majority will carry the vote.  This has to be in a
# format understood by Postgres as an "interval".
sub MOD_PERIOD { '1 week' }

# Defines the number of unanimous votes required to pass a moderation early
sub NUM_UNANIMOUS_VOTES { 5 }

# If this file exists (and is writeable by the web server), debugging
# information is logged here.
sub DEBUG_LOG	{ "/tmp/musicbrainz-debug.log" }

# This log file is used to record updates to perform later.
sub DEFERRED_UPDATE_LOG { "/tmp/musicbrainz-deferred-update.log" }

# How long (in seconds) a web/rdf session can go "idle" before being timed out
sub WEB_SESSION_SECONDS_TO_LIVE { 3600 * 3 }
sub RDF_SESSION_SECONDS_TO_LIVE { 3600 * 1 }

# The domain into which the session cookie is written
sub SESSION_DOMAIN { undef }

# The user/group which Apache runs as after starting up
sub APACHE_USER  { "nobody" }
sub APACHE_GROUP { "nobody" }

1;
