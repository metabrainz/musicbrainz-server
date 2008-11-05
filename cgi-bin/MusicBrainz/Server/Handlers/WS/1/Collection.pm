#!/usr/bin/perl -w
# vi: set ts=4 sw=4 :
#____________________________________________________________________________
#
#	MusicBrainz -- the open music metadata database
#
#	Copyright (C) 2001 Robert Kaye
#
#	This program is free software; you can redistribute it and/or modify
#	it under the terms of the GNU General Public License as published by
#	the Free Software Foundation; either version 2 of the License, or
#	(at your option) any later version.
#
#	This program is distributed in the hope that it will be useful,
#	but WITHOUT ANY WARRANTY; without even the implied warranty of
#	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#	GNU General Public License for more details.
#
#	You should have received a copy of the GNU General Public License
#	along with this program; if not, write to the Free Software
#	Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#
#	$id: $
#____________________________________________________________________________

use strict;

package MusicBrainz::Server::Handlers::WS::1::Collection;

use MusicBrainz::Server::Collection;
use MusicBrainz::Server::Handlers::WS::1::Common;
use Apache::Constants qw( OK BAD_REQUEST AUTH_REQUIRED DECLINED SERVER_ERROR NOT_FOUND FORBIDDEN);


sub handler
{
	# URLs are of the form:
	# POST http://server/ws/1/collection/?addalbums=<comma separated list of mbids>&removealbums=<comma separated list of mbids>
    my $r = shift;
    
    my $printer;
    
    
	use Data::Dumper;
	
	my %args = $r->args;
	
	
	my @addAlbums;
	my @removeAlbums;
	
	if($r->method eq "POST")
	{
		my $apr = Apache::Request->new($r);
		
		# split into arrays
		@addAlbums=split(/, |,/, $apr->param('addAlbums'));
		@removeAlbums=split(/, |,/, $apr->param('removeAlbums'));
	}
	else
	{	
		# get the albums from the POST/GET data
		@addAlbums=split(/, |,/, $args{addalbums});
		@removeAlbums=split(/, |,/, $args{removealbums});
	}
	
	
	require MusicBrainz;
	require Sql;
	
	my $mbro = MusicBrainz->new();
	$mbro->Login();
	
	my $mbraw = MusicBrainz->new();
	$mbraw->Login(db => 'RAWDATA');
	
	my $sqlraw = Sql->new($mbraw->{DBH});
	my $sqlro = Sql->new($mbro->{DBH});
	
	
	
	# get user id for logged on user
	my $userId = $sqlro->SelectSingleValue("SELECT id FROM moderator WHERE name = ?", $r->user);
	
	
	# make sure the user has a collection_info tuple
	MusicBrainz::Server::CollectionInfo::AssureCollection($userId, $mbraw->{DBH});
	
	# get collection_info id
	my $collectionId = MusicBrainz::Server::CollectionInfo::GetCollectionIdForUser($userId, $mbraw->{DBH});
	
	# instantiate Collection object
	my $collection = MusicBrainz::Server::Collection->new($mbro->{DBH}, $mbraw->{DBH}, $collectionId);
	
	
	# only allow one at a time. return a 400 error if both are used
	if(@addAlbums && @removeAlbums)
	{
		return bad_req($r, "Adding and removing releases must be done one at a time.");
	}
	elsif(!@addAlbums && !@removeAlbums)
	{
		$printer = sub {
			print_collection_xml($collectionId, $mbro->{DBH}, $mbraw->{DBH});
		};
	}
	elsif(@addAlbums){
		$collection->AddAlbums(@addAlbums);
		
		$printer = sub {
			print_manipulate_xml($collection);
		};
	}
	elsif(@removeAlbums){
		$collection->RemoveAlbums(@removeAlbums);
		$printer = sub {
			print_manipulate_xml($collection);
		};
	}
	
	
	send_response($r, $printer);
	return Apache::Constants::OK();	
}


sub print_manipulate_xml
{
	my ($collection) = @_;
	
	print '<?xml version="1.0" encoding="UTF-8"?>';
	print '<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#">';
	
	if($collection->{addAlbum}==1 || $collection->{removeAlbum}==1)
	{
		print '<response-list>';
		
		for my $mbid (@{$collection->{MBIdArray}})
		{
			print '<release id="' . $mbid . '"/>';
		}
		
		print '</response-list>';
	}
	
	print '</metadata>';
}



sub print_collection_xml
{
	my ($collectionId, $rodbh, $rawdbh) = @_;
	
	my $collectionInfo = MusicBrainz::Server::CollectionInfo->newFromCollectionId($collectionId, $rodbh, $rawdbh, undef);
	
	print '<?xml version="1.0" encoding="UTF-8"?>';
	print '<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#">';
	print '<release-list>';
		
	for my $mbid (@{$collectionInfo->GetHasMBIDs()})
	{
		print '<release id="' . $mbid . '"/>';
	}
	
	print '</release-list>';
	print '</metadata>';
}

1;
