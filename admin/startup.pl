#!/usr/bin/perl -w
# vi: set ts=4 sw=4 :

use strict;
use warnings;

# TODO: Check to make sure this path points to where the cgi-bin stuff is
use lib "/home/httpd/musicbrainz/mb_server/cgi-bin";

# Make sure we are in a sane environment.
$ENV{GATEWAY_INTERFACE} =~ /^CGI-Perl/
	or die "GATEWAY_INTERFACE not Perl!";

use Apache::Registry;
use Apache::Session;
use DBI;
use DBD::Pg;

sub UNIVERSAL::AUTOLOAD
{
	my $class = shift;

	warn "$class can't $UNIVERSAL::AUTOLOAD\n"
		unless $UNIVERSAL::AUTOLOAD =~ /DESTROY$/;
}

BEGIN
{
	require HTML::Mason::Config;

	my $c = \%HTML::Mason::Config;

	die "Too late to configure Mason!"
	    if $INC{'HTML/Mason/Utils.pm'}
	    and (
			$c->{mldbm_serializer} ne "Storable"
			or $c->{mldbm_use_db} ne "DB_File"
	    );

	$HTML::Mason::Config{default_cache_tie_class} = "MLDBM";
	$HTML::Mason::Config{mldbm_serializer} = "Storable";
	$HTML::Mason::Config{mldbm_use_db} = "DB_File";
}

# Alphabetical order, for ease of maintenance
# (apart from DBDefs and ModDefs, which we'll load first, just to make sure)
use DBDefs;
use ModDefs;

use Album;
use Alias;
use Artist;
use DebugLog;
use Discid;
use FreeDB;
use Insert;
use LocaleSaver;
# use MM;
# use MM_2_0;
# use MM_2_1;
use Moderation;
use ModerationKeyValue;
use ModerationSimple;
use MusicBrainz;
use MusicBrainz::Server::DeferredUpdate;
use MusicBrainz::Server::Handlers;
use MusicBrainz::Server::Mason;
use Parser;
use QuerySupport;
# use RDF2;
use SearchEngine;
use Sql;
use Statistic;
use Style;
use TableBase;
use TaggerSupport;
use Track;
use TRM;
use UserStuff;

1;
# eof startup.pl
