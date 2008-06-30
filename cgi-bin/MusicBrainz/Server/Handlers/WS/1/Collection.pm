#!/usr/bin/perl -w

use strict;

package MusicBrainz::Server::Handlers::WS::1::Collection;

use MusicBrainz::Server::Handlers::MC::1::Add;
use MusicBrainz::Server::Handlers::WS::1::Common;
use Apache::Constants qw( OK BAD_REQUEST DECLINED SERVER_ERROR NOT_FOUND FORBIDDEN);

sub handler
{
    my $r = shift;

	# URLs are of the form:
	# POST http://server/ws/1/collection/?addalbums=<mbid1>,<mbid2>&removealbums=<mbid3>,<mbid4>

	# make sure we are getting POST data
	#if($r->method != "POST") print "Only accepting POST data";

	my %args=$r->args;
	
	
	# which user is logged on?
	my $collectionId=123; #for now...
	
	# get the albums from the POST data
	my @addAlbums=split(",", $args{addalbums});
	my @removeAlbums=split(",", $args{removealbums});
	#my @removetracks=split(",", $args{removetracks});
	
	require MusicBrainz;
	require Sql;
	my $mb = MusicBrainz->new;
	$mb->Login;
	my $sql=Sql->new($mb->{DBH});
	
	
	# instantiate
	my $aaa=MusicBrainz::Server::Handlers::MC::1::Add->new($sql, $collectionId);
	
	# add albums, if the array is not empty...
	if(@addAlbums){ $aaa->AddAlbums(@addAlbums); }
	
	# remove albums, if the array is not empty
	if(@removeAlbums){ $aaa->RemoveAlbums(@removeAlbums); }
	
	# print XML response
	$aaa->PrintResultXML();
}

1;