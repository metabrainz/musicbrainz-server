#!/home/httpd/musicbrainz/mb_server/cgi-bin/perl -w
# vi: set ts=4 sw=4 :

use strict;
use warnings;
eval 'require Devel::SawAmpersand';

# TODO: Check to make sure this path points to where the cgi-bin stuff is
use lib "/home/httpd/musicbrainz/mb_server/cgi-bin";

# Make sure we are in a sane environment.
$ENV{GATEWAY_INTERFACE} =~ /^CGI-Perl/
	or die "GATEWAY_INTERFACE not Perl!";


# cgi-bin/*.pl is run via Apache::Registry
require Apache::Registry;

require Apache::Session;
require DBI;
require DBD::Pg;

# Some of the MB modules defer loading ("require" instead of "use") for some
# modules.  If we know we're likely to want some module eventually, load it
# now.
require POSIX;
require IO::Socket::INET; # FreeDB
require UUID; # TableBase
require Net::SMTP; # MusicBrainz::Server::Mail
require Time::ParseDate;

# Alphabetical order, for ease of maintenance
# (apart from DBDefs and ModDefs, which we'll load first, just to make sure)
require DBDefs;
require ModDefs;

require Album;
require Alias;
require Artist;
require DebugLog;
require FreeDB;
require Insert;
require LocaleSaver;
# require MM;
# require MM_2_0;
# require MM_2_1;
require Moderation;
require MusicBrainz;
require MusicBrainz::Server::Annotation;
require MusicBrainz::Server::Attribute;
require MusicBrainz::Server::AutomodElection;
require MusicBrainz::Server::AlbumCDTOC;
require MusicBrainz::Server::Cache;
require MusicBrainz::Server::CDTOC;
require MusicBrainz::Server::Country;
require MusicBrainz::Server::DateTime;
require MusicBrainz::Server::DeferredUpdate;
require MusicBrainz::Server::Handlers;
require MusicBrainz::Server::Link;
require MusicBrainz::Server::LinkAttr;
require MusicBrainz::Server::LinkEntity;
require MusicBrainz::Server::LinkType;
require MusicBrainz::Server::LogFile;
require MusicBrainz::Server::Mail;
require MusicBrainz::Server::Markup;
require MusicBrainz::Server::ModerationNote;
require MusicBrainz::Server::PagedReport;
require MusicBrainz::Server::Release;
require MusicBrainz::Server::TRMGateway;
require MusicBrainz::Server::TRMGatewayHandler;
require MusicBrainz::Server::URL;
require MusicBrainz::Server::Vote;
# Don't load MusicBrainz::Server::Moderation::* - Moderation.pm does that
require Parser;
require QuerySupport;
# require RDF2;
require SearchEngine;
require Sql;
require Statistic;
require Style;
require TableBase;
require TaggerSupport;
require Track;
require TRM;
require UserPreference;
require UserStuff;
require UserSubscription;

require &DBDefs::MB_SERVER_ROOT . "/admin/depend.pl";

# Loading the Mason handler preloads the pages, so the other MusicBrainz
# modules must be ready by this point.
require MusicBrainz::Server::Mason;

1;
# eof startup.pl
