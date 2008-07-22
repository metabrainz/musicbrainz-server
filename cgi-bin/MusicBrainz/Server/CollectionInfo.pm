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
	
	my %collectionHash;
	my %artistHash;
	
	
	my $sql = Sql->new($rawdbh);
	
	my $result=$sql->SelectSingleRowHash("SELECT * FROM collection_info WHERE moderator=?", $userId);
	
	
	
	bless(
	{
		userId			=> $userId,
		RODBH			=> $rodbh, # read only database
		RAWDBH			=> $rawdbh, # raw database
		preferences		=> $preferences,
		result			=> $result,
		collectionId	=> $result->{id},
		hasReleases		=> undef, # lets see if this and missingReleases will be used
		missingReleases	=> undef
		#artistHash		=> {}
	}, $this);
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
		
		my $query = "SELECT gid FROM album WHERE artist IN (". join(',', @$displayMissingOfArtists).") AND album.id NOT IN (". join(',', @{$hasReleaseIds}) .") AND album.name != '[non-album tracks]'";
		
		my $result = $rosql->SelectSingleColumnArray($query);
		
		return $result;
	}
}



sub GetMissingMBIDsForArtist
{
	my ($this, $artistId) = @_;
	
	my $sql=$this->{RODBH};
	
	#my $query="SELECT * FROM album WHERE artist IN (SELECT artist FROM collection_discography_artist_join WHERE collection_info='123')";
		
	my $result = $sql->SelectListOfHashes("SELECT gid FROM album WHERE artist=", $artistId);
	
	use Data::Dumper;
	print Dumper($result);
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