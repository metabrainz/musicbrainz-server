#
#
#	TODO:
#
#

#!/usr/bin/perl -w


use TableBase;
{ our @ISA = qw( TableBase ) }

use strict;

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
	
	
	print "adding albumsa:\n";
	
	
	
	
	#iterate over the album MBID's to be added
	foreach my $item (@albums)
	{
		$this->AddRelease($item);
		print "$item\n";
	}
	
	
	1;
}


# Remove albums listed in @albums
sub RemoveAlbums
{
	my ($this, @albums) = @_;
	
	$this->{removeAlbum}=1;
	print "REMOVE ALBUM";
	
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
	if($mbid =~ m/[a-z0-9]{8}[:-][a-z0-9]{4}[:-][a-z0-9]{4}[:-][a-z0-9]{4}[:-][a-z0-9]{12}/)
	{
		print "VALID MBID!\n";
	
		my $releaseId;
		
		eval
		{
			$rosql->Begin();
			
			
			# get album id
			$releaseId = $rosql->SelectSingleValue("SELECT id FROM album WHERE gid='$mbid'");
			
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
			
			$rosql->Commit();	
		}
		else
		{
			$rosql->Commit();
		}
		
		use Data::Dumper;
			print Dumper($releaseId);
		
		
		eval
		{
			$rawsql->Begin();
			
						use Data::Dumper;
			print Dumper($releaseId);
				
			# add MBID to the collection
			my $attributes={id => 456, collection_info => $collectionId, album => $releaseId};
			$rawsql->InsertRow("collection_has_release_join", $attributes);
			
			# increase add count
			$this->{addAlbum_insertCount}++;
		};
		
		if($@)
		{
			my $error=$@; # get the error message
			
			if($error =~ /duplicate/) # it is a duplicate... add it to the array of duplicates
			{
				push(@{$this->{addAlbum_duplicateArray}}, $mbid);
			}
			
			$rawsql->Commit();	
		}
		else
		{
			$rawsql->Commit();
		}
		
		print "adding mbid " . $mbid . " for user " . $collectionId . "\n";
	}
	else
	{
		print "NOT VALID MBID:'$mbid'\n";
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
		my $rawsql = $this->{RAWDBH};
		my $rosql = $this->{RODBH};
		
		
		print "\nremoving $mbid\n";
		
		
		# get id for realease with specified mbid
		my $albumId;
		
		eval
		{
			$rosql->Begin();
			
			my $idQuery = "SELECT id FROM album WHERE gid='$mbid'";
			$albumId = $rosql->SelectSingleValue($idQuery);
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
			my $deleteResult = $rawsql->Do("DELETE FROM collection_has_release_join WHERE album='$albumId' AND collection_info='". $this->{collectionId} ."'");
			
			print "Result:$deleteResult\n";
			
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
			$sql->Commit();
		}
		else
		{
			$sql->Commit();
		}
	}
	else
	{
		$this->{removeAlbum_invalidMBIDCount}++; # increase invalid mbid count
	}
}



# Print XML response
sub PrintResultXML
{
	my ($this)=@_;
	
	print "\n\nduplicates:\n";
	for my $duplicate (@{$this->{addAlbum_duplicateArray}})
	{
		print "$duplicate\n";
	}

	print "\n\not existing MBIDs:\n";
	for my $notExisting (@{$this->{addAlbum_notExistingArray}})
	{
		print "$notExisting\n";
	}
	
	print "\n\ninsert count: " .$this->{addAlbum_insertCount}. "\n";
	
	
	
	
	print '<?xml version="1.0" encoding="UTF-8"?>';
	print '<response>';
	
	if($this->{addAlbum}==1 || $this->{removeAlbum}==1) # print details for uuidtype album
	{
		print '<details uuidtype="album">';
		print '<addcount>'.$this->{addAlbum_insertCount}.'</addcount>';
		print '<removecount>'.$this->{removeAlbum_removeCount}.'</removecount>';
		print '<addinvalidmbidcount>'.$this->{addAlbum_invalidMBIDCount}.'</addinvalidmbidcount>';
		print '<removeinvalidmbidcount>'.$this->{removeAlbum_invalidMBIDCount}.'</removeinvalidmbidcount>';
		print '<error></error>'; # <--
		print '</details>';	
	}
	print '</response>';
}

1;