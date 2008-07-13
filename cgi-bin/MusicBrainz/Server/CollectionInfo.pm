#
# TODO:
# remove notificationinterval etc from query in CreateCollection and set them as default values in CreateTables.sql instead
#

#!/usr/bin/perl -w

use strict;

package MusicBrainz::Server::CollectionInfo;


sub new
{
	my ($this, $userId, $rodbh, $rawdbh)=@_;
	
	my %collectionHash;
	my %artistHash;
	
	
	my $sql = Sql->new($rawdbh);
	
	my $query="SELECT * FROM collection_info WHERE moderator='$userId'";
	my $result=$sql->SelectSingleRowHash($query);
	
	
	
	bless(
	{
		RODBH			=> $rodbh, # read only database
		RAWDBH			=> $rawdbh, # raw database
		userId			=> $userId,
		result			=> $result,
		collectionId	=> $result->{id},
		hasReleases		=> undef,
		missingReleases	=> undef
		#artistHash		=> {}
	}, $this);
}



# check if a user has a collection_info tuple. returns true or false.
sub HasCollection
{
	my ($userId, $rawdbh) = @_;
	
	my $sql = Sql->new($rawdbh);
	
	my $query = "SELECT COUNT(*) FROM collection_info WHERE moderator='". $userId ."'";
	
	return $sql->SelectSingleValue($query);
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


# add a collection_info tuple for the specified user
sub CreateCollection
{
	my ($userId, $rawdbh) = @_;
	
	my $rawsql = Sql->new($rawdbh);
	
	my $query = "INSERT INTO collection_info (moderator, publiccollection, emailnotifications, notificationinterval) VALUES ($userId, TRUE, TRUE, 7)";
	
	
	eval
	{
		$rawsql->Begin();
		$rawsql->Do($query);
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
	
	my $collectionIdQuery = "SELECT id FROM collection_info WHERE moderator='". $userId ."'";
	my $collectionId=$sqlraw->SelectSingleValue($collectionIdQuery);
	
	return $collectionId;
}


sub GetHasReleases
{
	my ($this) = @_;
	
	
	my $sql = $this->{RODBH};
	
	#my $query="SELECT (album.name) FROM album INNER JOIN collection_info ON (collection_has_release_join.collection_info = album.id) INNER JOIN collection_info ON (collection_has_release_join.collection_info = collection_info.id)";
	
	#my $query="SELECT album.name FROM album INNER JOIN collection_has_release_join b ON b.album = album.id INNER JOIN collection_info ON c.id = b.collection_info";
	
	#my $query="SELECT artist,name,attributes,gid FROM album WHERE id IN (SELECT album FROM collection_has_release_join WHERE collection_info='123')";
	
	my $query = "SELECT album.artist AS artistid, album.name AS albumname, album.attributes, album.gid, artist.name AS artistname FROM album, artist WHERE album.id IN (SELECT album FROM collection_has_release_join WHERE collection_info='123') AND artist.id=album.artist";
	
	my $result = $sql->SelectListOfHashes($query);
	
	return $result;
}


sub GetHasMBIDs
{
	my ($this, $artistId) = @_;
	
	
	
	# create Sql objects
	require Sql;
	my $rosql = Sql->new($this->{RODBH});
	my $rawsql = Sql->new($this->{RAWDBH});
	
	# get id's of all releases in collection
	my $query = "SELECT album FROM collection_has_release_join WHERE collection_info='" . $this->{collectionId} . "'";
	my $result = $rawsql->SelectSingleColumnArray($query);
	
	
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


#scrap this?
sub GetHasMBIDsForArtist
{
}



# Get hash of artist name and id of artists in collection
sub GetHasArtists
{
	my ($this) = @_;
	
	my $rosql = Sql->new($this->{RODBH});
	my $rawsql = Sql->new($this->{RAWDBH});
	
	
	my $albumIdQuery = "SELECT album FROM collection_has_release_join WHERE collection_info='" . $this->{collectionId} . "'";
	
	my $albumIds = $rawsql->SelectSingleColumnArray($albumIdQuery);
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



sub GetMissingReleases
{
	my ($this) = @_;
	
	my $sql = $this->{RODBH};
	
	#my $query="SELECT * FROM album WHERE artist IN (SELECT artist FROM collection_discography_artist_join WHERE collection_info='123')";
	
	my $query = "SELECT album.name AS albumname, album.attributes, album.gid AS mbid, album.artist AS artistid,artist.name AS artistname FROM album,artist WHERE album.artist IN (SELECT artist FROM collection_discography_artist_join WHERE collection_info='123') AND artist.id IN (SELECT artist FROM collection_discography_artist_join WHERE collection_info='123')";
	
	my $result = $sql->SelectListOfHashes($query);
	
	use Data::Dumper;
	print Dumper($result);
}


sub GetMissingMBIDsForArtist
{
	my ($this, $artistId) = @_;
	
	my $sql=$this->{RODBH};
	
	#my $query="SELECT * FROM album WHERE artist IN (SELECT artist FROM collection_discography_artist_join WHERE collection_info='123')";
	
	my $query = "SELECT gid FROM album WHERE artist='$artistId'";
	
	my $result = $sql->SelectListOfHashes($query);
	
	use Data::Dumper;
	print Dumper($result);
}


sub LoadHas
{
	
}


sub LoadMissing
{
	
}



1;