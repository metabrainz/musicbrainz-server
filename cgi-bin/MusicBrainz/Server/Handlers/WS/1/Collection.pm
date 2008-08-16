#!/usr/bin/perl -w
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
#	$Id: Sql.pm 9606 2007-11-24 16:14:09Z luks $
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
	my $userId = $sqlro->SelectSingleValue("SELECT id FROM moderator WHERE name='". $r->user ."'");
	
	
	# make sure the user has a collection_info tuple
	MusicBrainz::Server::CollectionInfo::AssureCollection($userId, $mbraw->{DBH});
	
	# get collection_info id
	my $collectionId = MusicBrainz::Server::CollectionInfo::GetCollectionIdForUser($userId, $mbraw->{DBH});
	
	# instantiate Collection object
	my $collection = MusicBrainz::Server::Collection->new($mbro->{DBH}, $mbraw->{DBH}, $collectionId);
	
	# add albums, if the array is not empty...
	if(@addAlbums){ $collection->AddAlbums(@addAlbums); }
	
	# remove albums, if the array is not empty
	if(@removeAlbums){ $collection->RemoveAlbums(@removeAlbums); }
	
	# print XML response
	my $printer = sub {
		print_xml($collection);
	};
	
	send_response($r, $printer);
	return Apache::Constants::OK();	
}


sub print_xml
{
	my ($collection) = @_;
	
	#print Dumper(@addAlbums);
	
#	print "\n\nduplicates:\n";
#	for my $duplicate (@{$collection->{addAlbum_duplicateArray}})
#	{
#		print STDERR "$duplicate\n";
#	}
#
#	print "\n\not existing MBIDs:\n";
#	for my $notExisting (@{$collection->{addAlbum_notExistingArray}})
#	{
#		print STDERR "$notExisting\n";
#	}
	
	
	
	print '<?xml version="1.0" encoding="UTF-8"?>';
	print '<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#">';
	print '<response>';
	
	if($collection->{addAlbum}==1 || $collection->{removeAlbum}==1) # print details for uuidtype album
	{
		print '<details uuidtype="album">';
		print '<addcount>'.$collection->{addAlbum_insertCount}.'</addcount>';
		print '<removecount>'.$collection->{removeAlbum_removeCount}.'</removecount>';
		print '<addinvalidmbidcount>'.$collection->{addAlbum_invalidMBIDCount}.'</addinvalidmbidcount>';
		print '<removeinvalidmbidcount>'.$collection->{removeAlbum_invalidMBIDCount}.'</removeinvalidmbidcount>';
		print '<error></error>'; # <--
		print '</details>';	
	}
	print '</response>';
	print '</metadata>';
}

1;
