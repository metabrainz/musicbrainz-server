#!/usr/bin/perl -w

use strict;

package MusicBrainz::Server::Handlers::WS::1::Collection;

use MusicBrainz::Server::Collection;
use MusicBrainz::Server::Handlers::WS::1::Common;
use Apache::Constants qw( OK BAD_REQUEST AUTH_REQUIRED DECLINED SERVER_ERROR NOT_FOUND FORBIDDEN);

sub handler
{
    my $r = shift;

	# URLs are of the form:
	# POST http://server/ws/1/collection/?addalbums=<mbid1>,<mbid2>&removealbums=<mbid3>,<mbid4>

	# make sure we are getting POST data
	#if($r->method != "POST") print "Only accepting POST data";
	# perhaps the above check should not be done? why not allow GET...
        # RAK: You should allow GET so that people can fetch their collection information.
	
	# store 
	my %args=$r->args;
	
	# get the albums from the POST data
	my @addAlbums=split(",", $args{addalbums});
	my @removeAlbums=split(",", $args{removealbums});
	#my @removetracks=split(",", $args{removetracks});
	
	require MusicBrainz;
	require Sql;
	
	my $mbro = MusicBrainz->new();
	$mbro->Login();
	
	my $mbraw = MusicBrainz->new();
	$mbraw->Login(db => 'RAWDATA');
	
	my $sqlraw = Sql->new($mbraw->{DBH});
	my $sqlro = Sql->new($mbro->{DBH});
	
	
	# get user id for logged on user
	my $userId = $sqlro->SelectSingleValue("SELECT id FROM moderator WHERE name='". $r->user ."'");
	
	# get collection_info id

	# RAK: Should this be done by CollectionInfo? I'd like to remove most of the collection 
        # specific SQL from this module and have it all reside in your Collection(Info) objects.
	my $collectionIdQuery = "SELECT id FROM collection_info WHERE moderator='". $userId ."'";
	my $collectionId=$sqlraw->SelectSingleValue($collectionIdQuery);
	
	# instantiate Collection object
	my $collection = MusicBrainz::Server::Collection->new($mbro->{DBH}, $mbraw->{DBH}, $collectionId);
	
	# add albums, if the array is not empty...
	if(@addAlbums){ $collection->AddAlbums(@addAlbums); }
	
	# remove albums, if the array is not empty
	if(@removeAlbums){ $collection->RemoveAlbums(@removeAlbums); }
	
	# print XML response
	# RAK:
        # please use STDERR to print the debug output and then tail -f <error_log> to see the output
        # this way the output does not interfere with the operations.
	print STDERR 'asfgfgfgd\n';

	# RAK: Please use a similar construct as to this:
 	# http://bugs.musicbrainz.org/browser/mb_server/branches/Discographies-BRANCH/cgi-bin/MusicBrainz/Server/Handlers/WS/1/Artist.pm#L112
	# This uses the send_response() function, which does all the proper header setting: http://bugs.musicbrainz.org/browser/mb_server/branches/Discographies-BRANCH/cgi-bin/MusicBrainz/Server/Handlers/WS/1/Common.pm#L281
        # Also, the actual XML output code should also live in this module, much like the other WS modules
	$collection->PrintResultXML();
}

1;
