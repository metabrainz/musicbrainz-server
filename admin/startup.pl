#!/home/httpd/musicbrainz/mb_server/cgi-bin/perl -w
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

# Some of the MB modules defer loading ("require" instead of "use") for some
# modules.  If we know we're likely to want some module eventually, load it
# now.
use IO::Socket::INET; # FreeDB
use UUID; # TableBase
use Net::SMTP; # MusicBrainz::Server::Mail

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
use MusicBrainz;
use MusicBrainz::Server::Cache;
use MusicBrainz::Server::Country;
use MusicBrainz::Server::DeferredUpdate;
use MusicBrainz::Server::Handlers;
use MusicBrainz::Server::Mail;
use MusicBrainz::Server::ModerationNote;
use MusicBrainz::Server::PagedReport;
use MusicBrainz::Server::Release;
use MusicBrainz::Server::Vote;
# Don't load MusicBrainz::Server::Moderation::* - Moderation.pm does that
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
use UserPreference;
use UserStuff;
use UserSubscription;

require &DBDefs::MB_SERVER_ROOT . "/admin/depend.pl";

# Loading the Mason handler preloads the pages, so the other MusicBrainz
# modules must be ready by this point.
use MusicBrainz::Server::Mason;

1;
# eof startup.pl
