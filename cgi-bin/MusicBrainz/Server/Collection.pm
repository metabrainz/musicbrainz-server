#
#
#	TODO:
#
#

#!/usr/bin/perl -w


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
		removeAlbum_invalidMBIDCount	=> 0
	}, $this);
}



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


# Remove albums listed in @albums
sub RemoveAlbums
{
	my ($this, @albums) = @_;
	
	$this->{removeAlbum}=1;
	
	foreach my $item (@albums)
	{
		$this->RemoveRelease($item);
	}
}


# add release with MBID $mbid
sub AddRelease #"album" in current schema
{
	my ($this, $mbid) = @_;
	
	my $rosql=Sql->new($this->{RODBH});
	my $rawsql=Sql->new($this->{RAWDBH});
	
	
	# make sure this is valid format for a mbid
	# TODO: use MusicBrainz::Server::Validation::IsGUID instead
	if($mbid =~ m/[a-z0-9]{8}[:-][a-z0-9]{4}[:-][a-z0-9]{4}[:-][a-z0-9]{4}[:-][a-z0-9]{12}/)
	{
		my $releaseId;
		
		eval
		{
			$rosql->Begin();
			
			
			#use Data::Dumper;
			#print Dumper($mbid);
			# get album id
			$releaseId = $rosql->SelectSingleValue("SELECT id FROM album WHERE gid = ?", $mbid);
			
			#print Dumper($releaseId);
			
			if($releaseId=="undef") # the mbid does not exist
			{
				push(@{$this->{addAlbum_notExistingArray}}, $mbid);
			}
		};
		
		if($@)
		{
			my $error=$@; # get the error message
			
			if($error =~ /duplicate/) # it is a duplicate... add it to the array of duplicates
			{
				push(@{$this->{addAlbum_duplicateArray}}, $mbid);
			}
			else
			{
				print $error;
			}
			
			$rosql->Commit();	
		}
		else
		{
			$rosql->Commit();
		}
				
		
		eval
		{
			$rawsql->Begin();
			
				
			# add MBID to the collection
			my $attributes={id => 456, collection_info => $collectionId, album => $releaseId};
			#$rawsql->InsertRow("collection_has_release_join", $attributes);
			$rawsql->Do('INSERT INTO collection_has_release_join (collection_info, album) VALUES (?, ?)', $collectionId, $releaseId);
			
			# increase add count
			$this->{addAlbum_insertCount}++;
		};
		
		if($@)
		{
			my $error = $@; # get the error message
			
			if($error =~ /duplicate/) # it is a duplicate... add it to the array of duplicates
			{
				push(@{$this->{addAlbum_duplicateArray}}, $mbid);
			}
			else
			{
				print $error;
			}
			
			$rawsql->Commit();	
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



# Remove release with MBID $mbid
sub RemoveRelease
{
	my ($this, $mbid) = @_;
	
	# make sure this is valid format for a mbid
	if($mbid =~ m/[a-z0-9]{8}[:-][a-z0-9]{4}[:-][a-z0-9]{4}[:-][a-z0-9]{4}[:-][a-z0-9]{12}/)
	{
		my $rawsql = Sql->new($this->{RAWDBH});
		my $rosql = Sql->new($this->{RODBH});
		
		
		
		# get id for realease with specified mbid
		my $albumId;
		
		eval
		{
			$rosql->Begin();
			
			$albumId = $rosql->SelectSingleValue("SELECT id FROM album WHERE gid = ?", $mbid);
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
		
		eval
		{
			$rawsql->Begin();
			# get the album id
			#my $selectResult=$sql->SelectSingleRowHash("SELECT id FROM album WHERE gid='$mbid'");
			#my $albumId=$selectResult->{id};
			
			# make sure there is a release with the mbid in the database
			my $deleteResult = $rawsql->Do("DELETE FROM collection_has_release_join WHERE album='?' AND collection_info='?'", $albumId, $this->{collectionId});
			
			#print "Result:$deleteResult\n";
			
			if($deleteResult == 1) # successfully deleted
			{
				# increase remove count
				$this->{removeAlbum_removeCount}++;
			}
		};
		
		if($@)
		{
			my $error = $@; # get the error message
			print $error;
			$rawsql->Commit();
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
}

1;