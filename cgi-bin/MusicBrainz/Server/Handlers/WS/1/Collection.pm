#!/usr/bin/perl -w

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
		@addAlbums=split(",", $args{addalbums});
		@removeAlbums=split(",", $args{removealbums});
		#my @removeTracks=split(",", $args{removetracks});
	}
	
	
	require MusicBrainz;
	require Sql;
	
	my $mbro = MusicBrainz->new();
	$mbro->Login();
	
	my $mbraw = MusicBrainz->new();
	$mbraw->Login(db => 'RAWDATA');
	
	my $sqlraw = Sql->new($mbraw->{DBH});
	my $sqlro = Sql->new($mbro->{DBH});
	
	#use Data::Dumper;
	#print Dumper(@addAlbums);
	
	print STDERR 'received post from '.$r->user;
	
	
	
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
	# RAK:
        # please use STDERR to print the debug output and then tail -f <error_log> to see the output
        # this way the output does not interfere with the operations.
	#print STDERR 'asfgfgfgd\n';
	
	#print 'asd';
	
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
}

1;
