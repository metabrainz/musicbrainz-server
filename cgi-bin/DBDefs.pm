#!/usr/bin/perl -w
# vi: set ts=8 sw=4 :
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



################################################################################
# The Database
################################################################################

require MusicBrainz::Server::Database;
MusicBrainz::Server::Database->register_all(
    {
	# How to connect when we need read-write access to the database
	READWRITE => {
	    database	=> "musicbrainz_db",
	    username	=> "musicbrainz_user",
	    password	=> "",
	    host	=> "",
	    port	=> "",
	},
	# How to connect for read-only access.  See "DB_IS_REPLICATED" (below)
	READONLY => undef,
	# How to connect for administrative access
	SYSTEM	=> {
	    database	=> "template1",
	    username	=> "postgres",
	    password	=> "",
	    host	=> "",
	    port	=> "",
	},
    },
);

# The schema sequence number.  Must match the value in
# replication_control.current_schema_sequence.
sub DB_SCHEMA_SEQUENCE { 4 }

# Replication slaves should prevent users from making any changes to the
# database.  Note that this setting is closely tied to the "READONLY" key,
# above.  See the INSTALL file for more information.
sub DB_IS_REPLICATED { 0 }

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

# If this is not undef, it lists a file to where all mail should be spooled
# (instead of being sent via SMTP_SERVER)
sub DEBUG_MAIL_SPOOL { undef }

# This value should be set to some secret value for your server.  Any old
# string of stuff should do; something suitably long and random, like for
# passwords.  However you MUST change it from the default
# value (the empty string).  This is so an attacker can't just look in CVS and
# see the default secret value, and then use it to attack your server.
sub SMTP_SECRET_CHECKSUM { "" }
sub EMAIL_VERIFICATION_TIMEOUT { 604800 } # one week



################################################################################
# Cache Settings
################################################################################

# Show MISS, HIT, SET etc
sub CACHE_DEBUG { 1 }

# Default expiry time in seconds.  Use 0 for "never".
sub CACHE_DEFAULT_EXPIRES { 3600 }

# Default delete time in seconds.  Use 0 means allow re-insert straight away.
sub CACHE_DEFAULT_DELETE { 4 }

# Cache::Memcached options
our %CACHE_OPTIONS = (
	servers => [ '127.0.0.1:11211' ],
	debug => 0,
);
sub CACHE_OPTIONS { \%CACHE_OPTIONS }



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
# Mods with no votes, for artists which have subscribers, can stay open longer
# after expiry.  This defines how long.
sub MOD_PERIOD_GRACE { '1 week' }

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

# The cookie name to use
sub SESSION_COOKIE { "AF_SID" }
# The domain into which the session cookie is written
sub SESSION_DOMAIN { undef }

# How long an annotation is considered as being locked.
sub ANNOTATION_LOCK_TIME { 60*15 }

# Amazon associate and developer ids
my %amazon_store_associate_ids = (
    'amazon.ca'		=> 'musicbrainz01-20',
    'amazon.co.jp'	=> 'musicbrainz-22',
    'amazon.co.uk'	=> 'musicbrainz0c-21',
    'amazon.com'	=> 'musicbrainz0d-20',
    'amazon.de'		=> 'musicbrainz00-21',
    'amazon.fr'		=> 'musicbrainz0e-21',
);

sub AWS_ASSOCIATE_ID 
{
    return keys %amazon_store_associate_ids if not @_;
    return $amazon_store_associate_ids{$_[0]};
}

sub AWS_DEVELOPER_ID { "D1TBI5FHXK38IE" }

# Neutered until we have a non-profit company
sub AWS_USE_ASSOCIATE_IDS { 0 }

1;
# eof DBDefs.pm
