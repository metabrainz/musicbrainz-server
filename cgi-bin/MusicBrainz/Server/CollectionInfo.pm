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
#	$id: $
#____________________________________________________________________________

use strict;

package MusicBrainz::Server::CollectionInfo;

# TODO:
# look up when use/require should be used
# get some stuff from the CollectionPreference object instead of doing new queries in here

=head2 new $userId, $rodbh, $rawdbh, $preferences
Create a CollectionInfo object for user with id C<$userId>.
=cut
sub new
{
	my ($this, $userId, $rodbh, $rawdbh, $preferences)=@_;
	
	my $sql = Sql->new($rawdbh);
	
	my $result=$sql->SelectSingleRowHash("SELECT * FROM collection_info WHERE moderator=?", $userId);
	bless(
	{
		userId			=> $userId,
		RODBH			=> $rodbh, # read only database
		RAWDBH			=> $rawdbh, # raw database
		preferences		=> $preferences,
		collectionId	=> $result->{id},
		hasReleases		=> undef, # lets see if this and missingReleases will be used
		missingReleases	=> undef
		#artistHash		=> {}
	}, $this);
}

=head2 newFromCollectionId $collectionId, $rodbh, $rawdbh, $preferences
Create a CollectionInfo object for the collection C<$collectionId>.
=cut
sub newFromCollectionId
{
	my ($this, $collectionId, $rodbh, $rawdbh, $preferences)=@_;
	
	my $sql = Sql->new($rawdbh);
	my $userId=$sql->SelectSingleValue("SELECT moderator FROM collection_info WHERE id=?", $collectionId);
	bless(
	{
		userId			=> $userId,
		RODBH			=> $rodbh, # read only database
		RAWDBH			=> $rawdbh, # raw database
		preferences		=> $preferences,
		collectionId	=> $collectionId,
		hasReleases		=> undef, # lets see if this and missingReleases will be used
		missingReleases	=> undef
		#artistHash		=> {}
	}, $this);
}

=head2 GetUserId
Returns userId.
=cut
sub GetUserId
{
	my ($this) = @_;
	
	return 0;
}

=head2 GetHasReleaseIds $artistId
Returns a reference to an array containing id's of all releases in collection.
=cut
sub GetHasReleaseIds
{
	my ($this) = @_;
	my $rawsql = Sql->new($this->{RAWDBH});
	my $hasReleaseIds = $rawsql->SelectSingleColumnArray('SELECT album
															FROM collection_has_release_join 
														   WHERE collection_info = ?', $this->{collectionId});
	return $hasReleaseIds;
}

=head2 GetHasMBIDs $artistId
Returns MBIds of all releases in collection.
=cut
sub GetHasMBIDs
{
	my ($this) = @_;
	
	# create Sql objects
	require Sql;
	my $rosql = Sql->new($this->{RODBH});
	my $rawsql = Sql->new($this->{RAWDBH});
	
	# get id's of all releases in collection
	my $result = $rawsql->SelectSingleColumnArray('SELECT album 
													 FROM collection_has_release_join 
												    WHERE collection_info = ?', $this->{collectionId});
	if(@{$result} == 0) # 0 results
	{
		return [];
	}
	else
	{	
		# get MBID's for all releases in collection
		my $mbids; # for storing the result
		
		my $releaseQuery='SELECT album.gid 
							FROM album INNER JOIN artist ON (album.artist = artist.id) 
						   WHERE album.id IN(' . join(',', @{$result}) . ') ORDER BY artist.name, album.name';
		
		$mbids = $rosql->SelectSingleColumnArray($releaseQuery);
		
		return $mbids;
	}
}

=head2 GetShowMissingArtists
Returns 
=cut
sub GetShowMissingArtists
{
	my ($this) = @_;
	my $rawsql = Sql->new($this->{RAWDBH});
	my $displayMissingOfArtists = $rawsql->SelectSingleColumnArray('SELECT artist 
																	  FROM collection_discography_artist_join 
																	 WHERE collection_info = ?', $this->{collectionId});
	
	return $displayMissingOfArtists;
}

=head2 GetWatchArtists
Returns a reference to an array containing id's of
=cut
sub GetWatchArtists
{
	my ($this) = @_;
	my $rawsql = Sql->new($this->{RAWDBH});
	my $watchArtists = $rawsql->SelectSingleColumnArray('SELECT artist 
														   FROM collection_watch_artist_join 
														  WHERE collection_info = ?', $this->{collectionId});
	
	return $watchArtists;
}

# Should missing releases of specified artist be displayed to specified user?
sub ShowMissingOfArtistToUser
{
	my ($artistId, $userId, $rawdbh) = @_;
	my $collectionId = MusicBrainz::Server::CollectionInfo::GetCollectionIdForUser($userId, $rawdbh);
	
	# Check if the user has selected to see missing releases of the artist
	my $rawsql = Sql->new($rawdbh);
	my $result = $rawsql->SelectSingleValue('SELECT artist 
										       FROM collection_discography_artist_join 
											  WHERE collection_info = ? 
											    AND artist = ?', $collectionId, $artistId);
	
	if($result == undef)
	{
		return 0;
	}
	else
	{
		return 1;
	}
}

# Should the user be notified about new releases from this artist?
sub NotifyUserAboutNewFromArtist
{
	my ($artistId, $userId, $rawdbh) = @_;
	
	my $collectionId = MusicBrainz::Server::CollectionInfo::GetCollectionIdForUser($userId, $rawdbh);
	# Check if the user has selected to be notified about new releases from this artist
	my $rawsql = Sql->new($rawdbh);
	my $result = $rawsql->SelectSingleValue('SELECT artist 
											   FROM collection_watch_artist_join 
											  WHERE collection_info = ? 
											    AND artist = ?', $collectionId, $artistId);
	
	if($result == undef)
	{
		return 0;
	}
	else
	{
		return 1;
	}
}

sub GetMissingMBIDs
{
	my ($this) = @_;
	
	my $rosql = Sql->new($this->{RODBH});
	my $rawsql = Sql->new($this->{RAWDBH});
	my $displayMissingOfArtists = $this->GetShowMissingArtists();
	my $count = @$displayMissingOfArtists;
	
	if($count == 0)
	{
		return [];
	}
	else
	{
		my $hasReleaseIds = $this->GetHasReleaseIds();
		
		my $result;
		my $hasIdsQueryString;
		
		
		my $showTypes = [ $this->{preferences}->GetShowTypes() ];
		my $showAttributesCondition = '';
		
		for my $attribute (@$showTypes)
		{
			$showAttributesCondition .= ' AND ' . $attribute . ' <> ALL (album.attributes[2:5])';
		}
		
		if(@{$hasReleaseIds})
		{		
			$hasIdsQueryString = ' AND album.id NOT IN (' . join(',', @{$hasReleaseIds}) . ') AND album.id NOT IN (SELECT id FROM album WHERE name IN (SELECT name FROM album WHERE id IN (' . join(',', @{$hasReleaseIds}) . ')) AND artist IN (SELECT artist FROM album WHERE id IN(' . join(',', @{$hasReleaseIds}) . ')))' . $showAttributesCondition;
		}
		
		if(@{$displayMissingOfArtists} && @$showTypes)
		{
			my $query = "SELECT DISTINCT ON (artist.name, album.name) album.gid 
						   FROM album INNER JOIN albummeta ON (album.id = albummeta.id) 
									  INNER JOIN artist ON (album.artist = artist.id) 
						  WHERE album.artist IN (". join(',', @{$displayMissingOfArtists}).")" . $hasIdsQueryString . " 
						    AND album.name != '[non-album tracks]' 
					   ORDER BY artist.name, album.name, albummeta.firstreleasedate DESC";
		
			return $rosql->SelectSingleColumnArray($query);
		}
		else
		{
			return [];
		}
	}
}



sub GetMissingMBIDsForArtist
{
	my ($this, $artistId) = @_;
	my $rosql = Sql->new($this->{RODBH});
	return $rosql->SelectListOfHashes("SELECT gid FROM album WHERE artist=", $artistId);
}

sub GetNewReleases
{
	my ($this) = @_;
	my $rosql = Sql->new($this->{RODBH});
	my $lastCheck = $this->GetLastCheck();
	my $watchArtists = $this->GetWatchArtists();
	my $newReleases;
	
	if(@{$watchArtists})
	{
		# Select new releases
		# New release == added after last check and release date within a week
		# ...so users are notified about new releases a week in advance
		$newReleases = $rosql->SelectSingleColumnArray("
			SELECT id 
			FROM album INNER JOIN albummeta ON (album.id = albummeta.id)
			WHERE artist IN (" . join(',', @{$watchArtists}) . ") 
				AND to_timestamp(firstreleasedate, 'YYYY-MM-DD') > (CURRENT_TIMESTAMP - '7 days'::INTERVAL)
				AND dateadded > ?
		", $this->GetLastCheck());
	}
	
	else
	{
		$newReleases = [];
	}
	
	return $newReleases;
}

sub GetLastCheck
{
	my ($this) = @_;
	my $rawsql = Sql->new($this->{RAWDBH});
	my $lastCheck = $rawsql->SelectSingleValue('SELECT lastcheck FROM collection_info WHERE id = ?', $this->{collectionId});
	
	return $lastCheck;
}

sub UpdateLastCheck
{
	my ($this) = @_;
	my $rawsql = Sql->new($this->{RAWDBH});
	
	eval
	{
		$rawsql->Begin();
		$rawsql->Do('UPDATE collection_info SET lastcheck = CURRENT_TIMESTAMP WHERE id = ?', $this->{collectionId});
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

#----------------------------
# static subs
#----------------------------

=head2 AssureCollection $userId, $rawdbh
Assure that the user with id C<$userId> has a collection tuple. If it does not have one yet - create it.
This sub should be called from every page/module that require the user to have a collection.
=cut
sub AssureCollection
{
	my ($userId, $rawdbh) = @_;
	
	if(!HasCollection($userId, $rawdbh))
	{
		CreateCollection($userId, $rawdbh);
	}
}

=head2 HasCollection $userId, $rawdbh
Check if user with id C<$userId> has a collection_info tuple.
Returns true or false.
=cut
sub HasCollection
{
	my ($userId, $rawdbh) = @_;
	
	my $sql = Sql->new($rawdbh);
		
	return $sql->SelectSingleValue("SELECT COUNT(*) FROM collection_info WHERE moderator=?", $userId);
}

=head2 CreateCollection $userId, $rawdbh
Create a collection_info tuple for the specified user.
=cut
sub CreateCollection
{
	my ($userId, $rawdbh) = @_;
	
	my $rawsql = Sql->new($rawdbh);
	eval
	{
		$rawsql->Begin();
		$rawsql->Do("INSERT INTO collection_info (moderator, publiccollection, emailnotifications) VALUES (?, TRUE, TRUE)", $userId);
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

=head2 GetCollectionIdForUser $userId, $rawdbh
Get the id of the collection_info tuple corresponding to the specified user.
=cut
sub GetCollectionIdForUser
{
	my ($userId, $rawdbh) = @_;
	my $sqlraw = Sql->new($rawdbh);
	my $collectionId = $sqlraw->SelectSingleValue("SELECT id FROM collection_info WHERE moderator=?", $userId);
	
	return $collectionId;
}


sub GetUserIdForCollection
{
	my ($collectionId, $rawdbh) = @_;
	my $sqlraw = Sql->new($rawdbh);
	my $userId = $sqlraw->SelectSingleValue('SELECT moderator FROM collection_info WHERE id = ?', $collectionId);
	
	return $userId;
}

sub HasRelease
{
	my ($rawdbh, $collectionId, $releaseId) = @_;
	my $rawsql = Sql->new($rawdbh);
	my $count;
	
	$count = $rawsql->SelectSingleValue('SELECT COUNT(*) 
										   FROM collection_has_release_join 
										  WHERE collection_info = ? 
										    AND album = ?', $collectionId, $releaseId);
	if($count>0)
	{
		return 1;
	}
	else
	{
		return 0;
	}
}

1;
# vi: set ts=4 sw=4 :
