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

use TableBase;
{ our @ISA = qw( TableBase ) }

use strict;
use Data::Dumper;

package MusicBrainz::Server::Collection;




require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(addtracks removetracks);


my $sql; #database handle

my $collectionId; #the logged on user
#my @duplicateIds; #List of redundant MBID's
my @notExistingIds;
my $addAlbum_insertCount=0;




=head1 NAME

MusicBrainz::Server::Collection - Manipulate collection
	
=head1 DESCRIPTION

Has functions for adding and removing releases In collection.

=head1 METHODS


=head2 new $rodbh, $rawdbh, $collectionId
Create a Collection object for the collection with id C<$collectionId>.
=cut
sub new
{
	my($this, $rodbh, $rawdbh, $collectionId) = @_;
	
	my @duplicateIds = ();
	
	bless(
	{
		RODBH							=> $rodbh,
		RAWDBH							=> $rawdbh,
		collectionId					=> $collectionId,
		addAlbum						=> 0, # 0=havent touched add album stuff. 1=has done so
		addAlbum_duplicateArray			=> [()],
		addAlbum_notExistingArray		=> [()],
		addAlbum_insertCount			=> 0,
		addAlbum_invalidMBIDCount		=> 0,
		removeAlbum						=> 0, # 0=havent touched remove album stuff. 1=has done so
		removeAlbum_notExistingArray	=> [()],
		removeAlbum_removeCount			=> 0,
		removeAlbum_invalidMBIDCount	=> 0,
		invalidMBIdCount				=> 0,
		MBIdArray						=> ()
	}, $this);
}



=head2 addAlbums @albums
Add the albums in C<@albums> to this collection.
=cut
# Add albums. MBID's listed in @albums
sub AddAlbums {
	my ($this, @albums) = @_;
	
	
	$this->{addAlbum} = 1;
	
	$collectionId = $this->{collectionId};
	
	
	
	#iterate over the album MBID's to be added
	foreach my $item (@albums)
	{
		$this->AddRelease($item);
	}
	
	
	1;
}


=head2 removeAlbums @albums
Remove the albums in C<@albums> from this collection.
=cut
sub RemoveAlbums
{
	my ($this, @albums) = @_;
	
	$this->{removeAlbum}=1;
	
	foreach my $item (@albums)
	{
		$this->RemoveRelease($item);
	}
}



=head2 addRelease $mbid
Add the release with MBId C<$mbid> to collection.
=cut
sub AddRelease
{
	my ($this, $mbid) = @_;
	
	my $rosql=Sql->new($this->{RODBH});
	my $rawsql=Sql->new($this->{RAWDBH});
	print STDERR "adding $mbid \n";
	
	# make sure this is valid format for a mbid
	if(MusicBrainz::Server::Validation::IsGUID($mbid))
	{
		my $releaseId;
		
		
		# get album id
		$releaseId = $rosql->SelectSingleValue("SELECT id FROM album WHERE gid = ?", $mbid);
				
		
		eval
		{
			$rawsql->Begin();
			
			
			# add MBID to the collection
			$rawsql->Quiet(1);
			$rawsql->Do('INSERT INTO collection_has_release_join (collection_info, album) VALUES (?, ?)', $this->{collectionId}, $releaseId);
			
			# increase add count
			$this->{addAlbum_insertCount}++;
			
			# add to list of MBIds
			push(@{$this->{MBIdArray}}, $mbid);
		};
		
		if($@)
		{			
			if($@ =~ /duplicate/) # it is a duplicate... add it to the array of duplicates
			{
				#my $err = "$@";
				#use Carp qw( cluck );
				#cluck $err;
				#die($err);
				print STDERR 'CATCHED CATCHED                 CATCHED';
				push(@{$this->{addAlbum_duplicateArray}}, $mbid);
			}
			else
			{
				print STDERR '                         NOT CATCHED                      NOT CATCHED                   NOT CATCHED          ';
				$this->{invalidMBIdCount}++;
				#die($@);
			}
			
			$rawsql->Rollback();	
		}
		else
		{
			$rawsql->Commit();
		}
	}
	else
	{
		$this->{addAlbum_invalidMBIDCount}++; # increase invalid mbid count
	}
}



# static
sub AddReleaseWithId
{
	my($releaseId, $collectionId, $rawdbh) = @_;
	
	my $rawsql=Sql->new($rawdbh);
	
	eval
	{
		$rawsql->Begin();
		$rawsql->Quiet(1);
		
		# add MBID to the collection
		$rawsql->Do('INSERT INTO collection_has_release_join (collection_info, album) VALUES (?, ?)', $collectionId, $releaseId);
	};
	
	if($@)
	{			
		if($@ =~ /duplicate/) # it is a duplicate...
		{

		}
		else
		{
			my $err = $@;
			use Carp qw( cluck );
			cluck $err;
			die($err);
		}
		
		$rawsql->Rollback();
	}
	else
	{
		$rawsql->Commit();
	}

}



=head2 removeRelease $mbid
Remove realease with MBId C<$mbid> from collection
=cut
# TO DO: call RemoveReleaseWithId after getting id.
# do this for AddRelease as well
sub RemoveRelease
{
	my ($this, $mbid) = @_;
	
	# make sure this is valid format for a mbid
	if(MusicBrainz::Server::Validation::IsGUID($mbid))
	{
		my $rawsql = Sql->new($this->{RAWDBH});
		my $rosql = Sql->new($this->{RODBH});
		
		
		
		# get id for realease with specified mbid
		my $albumId = $rosql->SelectSingleValue("SELECT id FROM album WHERE gid = ?", $mbid);
		
		
		eval
		{
			$rawsql->Begin();
			
			# make sure there is a release with the mbid in the database
			my $deleteResult = $rawsql->Do("DELETE FROM collection_has_release_join WHERE album = ? AND collection_info = ?", $albumId, $this->{collectionId});
			
			
			if($deleteResult == 1) # successfully deleted
			{
				# increase remove count
				$this->{removeAlbum_removeCount}++;
				
				# add MBId to array
				push(@{$this->{MBIdArray}}, $mbid);
			}
		};
		
		if($@)
		{
			$rawsql->Rollback();
			die($@);
		}
		else
		{
			$rawsql->Commit();
		}
	}
	else
	{
		$this->{removeAlbum_invalidMBIDCount}++; # increase invalid mbid count
	}
	
	
	# $this->{removeAlbum_removeCount}++;
}




#----------------------------
# static subs
#----------------------------

#sub AddReleaseWithId
#{
#	my ($rawdbh, $releaseId, $collectionId) = @_;
#	
#	my $rawsql = Sql->new($rawdbh);
#	
#	print STDERR "INSERTING: $releaseId into $rawdbh collection $collectionId";
#	eval
#	{
#		$rawsql->Begin();
#		
#		$rawsql->Do('INSERT INTO collection_has_release_join (collection_info, album) VALUES(?, ?)', $collectionId, $releaseId);
#	};
#	
#	if($@)
#	{
#		# ignore duplicate errors
#		if($@ =~ /duplicate/)
#		{
#			$rawsql->Rollback();
#		}
#		else
#		{
#			$rawsql->Rollback();
#			die($@);
#		}
#	}
#	else
#	{
#		$rawsql->Commit();
#	}
#}



sub RemoveReleaseWithId
{
	my ($rawdbh, $releaseId, $collectionId) = @_;
	
	my $rawsql = Sql->new($rawdbh);
	
	eval
	{
		$rawsql->Begin();
		
		# make sure there is a release with the mbid in the database
		my $deleteResult = $rawsql->Do("DELETE FROM collection_has_release_join WHERE album = ? AND collection_info = ?", $releaseId, $collectionId);
		print STDERR "DELETING RELEASE $releaseId FROM $collectionId";
	};
	
	if($@)
	{
		$rawsql->Rollback();
		die($@);
	}
	else
	{
		$rawsql->Commit();
		return 1;
	}
}


1;