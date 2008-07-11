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
	
	# get collection_info id
	my $collectionIdQuery="SELECT id FROM collection_info WHERE moderator='". $r->user ."'";
	my $collectionId=$sqlraw->SelectSingleValue($collectionIdQuery);
	
	
	
	# instantiate Collection object
	my $collection=MusicBrainz::Server::Collection->new($mbro->{DBH}, $mbraw->{DBH}, $collectionId);
	
	# add albums, if the array is not empty...
	if(@addAlbums){ $collection->AddAlbums(@addAlbums); }
	
	# remove albums, if the array is not empty
	if(@removeAlbums){ $collection->RemoveAlbums(@removeAlbums); }
	
	# print XML response
	print 'asfgfgfgd';
	$collection->PrintResultXML();
}

1;