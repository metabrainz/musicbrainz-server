#
#
#	TODO:
#
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
	my($this, $sql, $collectionId)=@_;
	
	my @duplicateIds=();
	
	bless(
	{
		DBH								=> $sql,
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
	
	$this->{addAlbum}=1;
	
	$collectionId=$this->{collectionId};
	$sql=$this->{DBH};
	
	
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
	
	my $sql=$this->{DBH};
	
	
	# make sure this is valid format for a mbid
	if($mbid =~ m/[a-z0-9]{8}[:-][a-z0-9]{4}[:-][a-z0-9]{4}[:-][a-z0-9]{4}[:-][a-z0-9]{12}/)
	{
		print "VALID MBID!\n";
		
		
		eval
		{
			$sql->Begin();
			
			# make sure there is a release with the mbid in the database
			my $result=$sql->SelectSingleRowHash("SELECT * FROM album WHERE gid='$mbid'");
			
			
			if($result=="undef") # the mbid does not exist
			{
				push(@{$this->{addAlbum_notExistingArray}}, $mbid);
			}
			else # it is a valid mbid. add it to the collection
			{
				# get id of album
				my $albumId=$result->{id};
				
				# add MBID to the collection
				my $attributes={id => 456, collection_info => $collectionId, album => $albumId};
				$sql->InsertRow("collection_has_release_join", $attributes);
				
				# increase add count
				$this->{addAlbum_insertCount}++;
			}
		};
		
		if($@)
		{
			my $error=$@; # get the error message
			
			if($error =~ /duplicate/) # it is a duplicate... add it to the array of duplicates
			{
				push(@{$this->{addAlbum_duplicateArray}}, $mbid);
			}
			
			$sql->Commit();
		}
		else
		{
			$sql->Commit();
		}
		
		#use Data::Dumper;
		#print Dumper(@result);
		
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
		my $sql=$this->{DBH};
		
		print "\nremoving $mbid\n";
		
		eval
		{
			$sql->Begin();
			# get the album id
			#my $selectResult=$sql->SelectSingleRowHash("SELECT id FROM album WHERE gid='$mbid'");
			#my $albumId=$selectResult->{id};
			
			# make sure there is a release with the mbid in the database
			my $deleteResult=$sql->Do("DELETE FROM collection_has_release_join WHERE album=(SELECT id FROM album WHERE gid='$mbid')");
			
			print "REsuLT:$deleteResult\n";
			
			if($deleteResult==1) # successfully deleted
			{
				# increase remove count
				$this->{removeAlbum_removeCount}++;
			}
		};
		
		if($@)
		{
			my $error=$@; # get the error message
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