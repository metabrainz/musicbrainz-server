#
# TODO:
# remove notificationinterval etc from query in CreateCollection and set them as default values in CreateTables.sql instead
# do some of the SQL querys in evals
# look up when to use/require should be used
# get some stuff from the CollectionPreference object instead of doing new queries in here
#

#!/usr/bin/perl -w

use strict;

package MusicBrainz::Server::CollectionInfo;




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


sub newMissingCollectionInfo
{
}



# assure that the user has a corresponding collection_info tuple. if it does not have one yet - create it.
# this sub should be called on every page that requires a collection
sub AssureCollection
{
	my ($userId, $rawdbh) = @_;
	
	if(HasCollection($userId, $rawdbh))
	{
		#print 'HAS COLLECTION';
	}
	else
	{
		#print 'DO NOT HAVE COLLECTION';
		CreateCollection($userId, $rawdbh);
	}
}



# check if a user has a collection_info tuple. returns true or false.
sub HasCollection
{
	my ($userId, $rawdbh) = @_;
	
	my $sql = Sql->new($rawdbh);
		
	return $sql->SelectSingleValue("SELECT COUNT(*) FROM collection_info WHERE moderator=?", $userId);
}



# add a collection_info tuple for the specified user
sub CreateCollection
{
	my ($userId, $rawdbh) = @_;
	
	my $rawsql = Sql->new($rawdbh);
	
	
	
	eval
	{
		$rawsql->Begin();
		$rawsql->Do("INSERT INTO collection_info (moderator, publiccollection, emailnotifications, notificationinterval) VALUES (?, TRUE, TRUE, 7)", $userId);
	};
	
	if($@)
	{
		$rawsql->Commit();
		print $@;
	}
	else
	{
		$rawsql->Commit();
	}	
}



sub GetCollectionIdForUser
{
	my ($userId, $rawdbh) = @_;
	
	my $sqlraw = Sql->new($rawdbh);
	
	my $collectionId=$sqlraw->SelectSingleValue("SELECT id FROM collection_info WHERE moderator=?", $userId);
	
	return $collectionId;
}


sub GetUserId
{
	my ($this) = @_;
	
	return 0;
}


sub GetHasReleaseIds
{
	my ($this, $artistId) = @_;
	
	my $rawsql = Sql->new($this->{RAWDBH});
	
	my $hasReleaseIds = $rawsql->SelectSingleColumnArray('SELECT album FROM collection_has_release_join WHERE collection_info = ?', $this->{collectionId});
	
	return $hasReleaseIds;
}


# TODO:
# rename to GetHasMBIDsForArtist
sub GetHasMBIDs
{
	my ($this, $artistId) = @_;
	
	
	
	# create Sql objects
	require Sql;
	my $rosql = Sql->new($this->{RODBH});
	my $rawsql = Sql->new($this->{RAWDBH});
	
	# get id's of all releases in collection
	my $result = $rawsql->SelectSingleColumnArray('SELECT album FROM collection_has_release_join WHERE collection_info=?', $this->{collectionId});
	
	
	if(@{$result} == 0) # 0 results
	{
		return [];
	}
	else
	{	
		# get MBID's for all releases in collection
		my $mbids; # for storing the result
		
		eval
		{
			$rosql->Begin();
			
			my $releaseQuery='SELECT gid FROM album WHERE id IN(' . join(',', @{$result}) . ')';
		
			$mbids = $rosql->SelectListOfLists($releaseQuery);
		};
		
		if($@)
		{
			print $@;
			$rosql->Commit();
		}
		else
		{
			$rosql->Commit();
		}
		
		
		return $mbids;
	}
}



# scrap this?
# no, but instead the above sub should be moved into this one?
sub GetHasMBIDsForArtist
{
}



# Get hash of artist name and id of artists in collection
# TODO:
# also create a sub similar to this but for missing artists?
sub GetHasArtists
{
	my ($this) = @_;
	
	my $rosql = Sql->new($this->{RODBH});
	my $rawsql = Sql->new($this->{RAWDBH});
	
	
	my $albumIds = $rawsql->SelectSingleColumnArray("SELECT album FROM collection_has_release_join WHERE collection_info=?", $this->{collectionId});
	my $count = @$albumIds;
	
	if($count > 0)
	{
		my $query="SELECT id,name FROM artist WHERE id IN (SELECT artist FROM album WHERE id IN (" . join(',', @{$albumIds}) . "))";
		my $result = $rosql->SelectListOfHashes($query);
		return $result;
	}
	else
	{
		return [];
	}
}



sub GetShowMissingArtists
{
	my ($this) = @_;
	
	my $rawsql = Sql->new($this->{RAWDBH});
	
	my $displayMissingOfArtists = $rawsql->SelectSingleColumnArray('SELECT artist FROM collection_discography_artist_join WHERE collection_info = ?', $this->{collectionId});
	
	return $displayMissingOfArtists;
}



sub GetWatchArtists
{
	my ($this) = @_;
	
	my $rawsql = Sql->new($this->{RAWDBH});
	
	my $watchArtists = $rawsql->SelectSingleColumnArray('SELECT artist FROM collection_watch_artist_join WHERE collection_info = ?', $this->{collectionId});
	
	return $watchArtists;
}



# Should missing releases of specified artist be displayed to specified user?
sub ShowMissingOfArtistToUser
{
	my ($artistId, $userId, $rawdbh) = @_;
	
	my $collectionId = MusicBrainz::Server::CollectionInfo::GetCollectionIdForUser($userId, $rawdbh);
	
	
	# Check if the user has selected to see missing releases of the artist
	my $rawsql = Sql->new($rawdbh);
	my $result = $rawsql->SelectSingleValue('SELECT artist FROM collection_discography_artist_join WHERE collection_info = ? AND artist = ?', $collectionId, $artistId);
	
	
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
	my $result = $rawsql->SelectSingleValue('SELECT artist FROM collection_watch_artist_join WHERE collection_info = ? AND artist = ?', $collectionId, $artistId);
	
	
	if($result == undef)
	{
		return 0;
	}
	else
	{
		return 1;
	}
}



# TODO:
# do the SQL stuff in an eval
# only select one version of each release(ignore e.g. UK version, USA version etc) 
#
# ignores all releases named [non-album tracks]
sub GetMissingMBIDs
{
	my ($this) = @_;
	
	my $rosql = Sql->new($this->{RODBH});
	my $rawsql = Sql->new($this->{RAWDBH});
	
	#dont select all this stuff, its done by Release
	#my $query = "SELECT album.name AS albumname, album.attributes, album.gid AS mbid, album.artist AS artistid,artist.name AS artistname FROM album,artist WHERE album.artist IN (SELECT artist FROM collection_discography_artist_join WHERE collection_info='123') AND artist.id IN (SELECT artist FROM collection_discography_artist_join WHERE collection_info='123') ORDER BY artist.name";
	
	#$artists = 
	
	my $displayMissingOfArtists = $this->GetShowMissingArtists();#$rawsql->SelectSingleColumnArray('SELECT artist FROM collection_discography_artist_join WHERE collection_info = ?', $this->{collectionId});
	#print STDERR Dumper(join(',', @$displayMissingOfArtists));
	
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
		
		
		if(@{$hasReleaseIds})
		{		
			$hasIdsQueryString = ' AND album.id NOT IN (' . join(',', @{$hasReleaseIds}) . ') AND album.id NOT IN (SELECT id FROM album WHERE name IN (SELECT name FROM album WHERE id IN (' . join(',', @{$hasReleaseIds}) . ')) AND artist IN (SELECT artist FROM album WHERE id IN(' . join(',', @{$hasReleaseIds}) . ')))';
		}
		
		if(@{$displayMissingOfArtists})
		{
			my $query = "SELECT DISTINCT ON (artist.name, album.name) album.gid FROM album INNER JOIN albummeta ON (album.id = albummeta.id) INNER JOIN artist ON (album.artist = artist.id) WHERE album.artist IN (". join(',', @{$displayMissingOfArtists}).")" . $hasIdsQueryString . " AND album.name != '[non-album tracks]' ORDER BY artist.name, album.name, albummeta.firstreleasedate";
			
			#my $query = "SELECT DISTINCT ON (album.artist, album.name) album.gid FROM album, albummeta WHERE album.id = albummeta.id AND album.artist IN (". join(',', @{$displayMissingOfArtists}).")" . $hasIdsQueryString . " AND album.name != '[non-album tracks]' ORDER BY album.artist, album.name, albummeta.firstreleasedate";

			# INNER JOIN artist ON (album.artist = artist.id)
			
			print STDERR $query;
		
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
	
	#my $query="SELECT * FROM album WHERE artist IN (SELECT artist FROM collection_discography_artist_join WHERE collection_info='123')";
		
	my $result = $rosql->SelectListOfHashes("SELECT gid FROM album WHERE artist=", $artistId);
	
	use Data::Dumper;
	print Dumper($result);
}



# NOTES:
# xlotlu: select foo, foo + '1 day'::interval as foo_tomorrow
# xlotlu: niklas: extract (epoch from datefield)
# xlotlu: niklas: you can use to_timestamp(date_string, date_format) ...
# to_timestamp('1234-12-12', 'YYYY-MM-DD')
# '1234-12-12'::TIMESTAMP
sub GetNewReleases
{
	my ($this) = @_;
	
	my $rosql = Sql->new($this->{RODBH});
	
	my $lastCheck = $this->GetLastCheck();
	
	#my $newReleases = ['685970', '696912']; # while testing
	#my $newReleases = $rosql->SelectSingleColumnArray("SELECT id FROM album WHERE id IN(SELECT album FROM release WHERE to_date(releasedate, 'YYYY-MM-DD') > (CURRENT_DATE - '14 days'::INTERVAL) AND to_date(releasedate, 'YYYY-MM-DD') < (CURRENT_DATE + '14 days'::INTERVAL)) LIMIT 10");
	#my $newReleases = $rosql->SelectSingleColumnArray("SELECT id FROM album WHERE id IN (SELECT id FROM albummeta WHERE dateadded > (CURRENT_TIMESTAMP - '14 days'::INTERVAL) AND dateadded < (CURRENT_TIMESTAMP + '14 days'::INTERVAL)) LIMIT 3");
	
	#my $newReleases = $rosql->SelectSingleColumnArray("SELECT id FROM album WHERE id IN (SELECT album FROM release WHERE to_date(releasedate, 'YYYY-MM-DD') > (CURRENT_DATE - '14 days'::INTERVAL) AND to_date(releasedate, 'YYYY-MM-DD') < (CURRENT_DATE + '14 days'::INTERVAL)) LIMIT 10");
	
	#my $newReleases = $rosql->SelectSingleColumnArray("SELECT id FROM album WHERE id IN(SELECT album FROM release WHERE to_date(releasedate, 'YYYY-MM-DD') > (CURRENT_DATE - '14 days'::INTERVAL) AND to_date(releasedate, 'YYYY-MM-DD') < (CURRENT_DATE + '14 days'::INTERVAL)) LIMIT 10");#, $this->GetLastCheck());
	
	#my $newReleases = $rosql->SelectSingleColumnArray("SELECT id FROM album WHERE id IN(SELECT id FROM album WHERE dateadded > (CURRENT_DATE - '1499 days'::INTERVAL) AND dateadded < (CURRENT_DATE + '14 days'::INTERVAL)) LIMIT 10");
	
	my $watchArtists = $this->GetWatchArtists();
	
	print Dumper($watchArtists);
	
	my $newReleases;
	
	if(@{$watchArtists})
	{
		# Select new releases
		# New release == added after last check and release date within a week
		# ...so users are notified about new releases a week in advance
		$newReleases = $rosql->SelectSingleColumnArray("SELECT id FROM album WHERE dateadded > ? AND artist IN (" . join(',', @{$watchArtists}) . ") AND id IN (SELECT id FROM albummeta WHERE to_timestamp(firstreleasedate, 'YYYY-MM-DD') > (CURRENT_TIMESTAMP - '7 days'::INTERVAL)) LIMIT 10", $this->GetLastCheck());
	}
	
	else
	{
		$newReleases = [];
	}
	
	print 'last check: '.$this->GetLastCheck();
	
	return $newReleases;
	
	#my $newReleases = $rosql->SelectSingleColumnArray('SELECT id FROM album WHERE id IN (SELECT album FROM release WHERE releasedate < CURRENT_DATE + '14 days'::INTERVAL and releasedate > something)');
	# SELECT id FROM album WHERE id IN(SELECT album FROM release WHERE to_date(releasedate, 'YYYY-MM-DD') > '2007-01-01'::DATE);
	# SELECT gid FROM album WHERE id IN(SELECT album FROM release WHERE to_date(releasedate, 'YYYY-MM-DD') > '2007-01-01'::DATE);
	# SELECT gid,id,name FROM album WHERE id IN(SELECT album FROM release WHERE to_date(releasedate, 'YYYY-MM-DD') > (CURRENT_DATE - '14 days'::INTERVAL) AND to_date(releasedate, 'YYYY-MM-DD') < (CURRENT_DATE + '14 days'::INTERVAL)) LIMIT 10;
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
	
	$rawsql->Do('UPDATE collection_info SET lastcheck = CURRENT_TIMESTAMP WHERE id = ?', $this->{collectionId});
}



# ?
sub LoadHas
{
	
}



# ?
sub LoadMissing
{
	my (@missingArtists) = @_;
}



1;