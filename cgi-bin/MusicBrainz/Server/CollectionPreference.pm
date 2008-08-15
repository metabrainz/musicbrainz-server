#
# TODO:
# check values
# make another new sub which does not get values from db, as the values are known from POST data(when sent)
#



#!/usr/bin/perl -w


use strict;

package MusicBrainz::Server::CollectionPreference;

use Carp qw( carp );




=head1 NAME

MusicBrainz::Server::CollectionPreference - Access and set collection preferences
	
=head1 DESCRIPTION

Has subs for setting and getting collection preference values.

=head1 METHODS




=head2 new $rodbh, $rawdbh, $userId
Create a CollectionPreference object. Load preferences for user with id C<$userId>.
=cut
sub new
{
	my ($this, $rodbh, $rawdbh, $userId) = @_;
	
	
	# get collection id
	my $rawsql = Sql->new($rawdbh);
	my $collectionId = $rawsql->SelectSingleValue('SELECT id FROM collection_info WHERE moderator=?', $userId);
	
	
	my $object=bless(
	{
		RAWDBH			=> $rawdbh,
		RODBH			=> $rodbh,
		prefs			=> {},
		collectionId	=> $collectionId,
		userId			=> $userId,
		hasArtists		=> undef,#$hasArtists # should this even be here!? since selection stuff has been removed from collectionpreferences.html 
		artistsMissing	=> undef#$artistsMissingHash   # same as above
	}, $this);
	
	$object->addpref('emailnotifications', 0, \&check_bool);
	$object->addpref('notificationinterval', 7, sub { check_int(1,31,@_) });
	
	my $releaseTypes = MusicBrainz::Server::CollectionPreference::GetReleaseTypes();
	
	
	my $selectprefs;
	
	eval
	{
		$rawsql->Begin();
		
		# load the preference keys and values into the prefs hash
		$selectprefs = $rawsql->SelectSingleRowHash('SELECT emailnotifications, notificationinterval, lastcheck FROM collection_info WHERE id = ?', $collectionId);
	};
	
	if($@)
	{
		die('Could not load preferences');
	}
	else
	{
		$rawsql->Commit();
	}
	
	
	# add valid keys
	my $prefs = {
		'emailnotifications' => {'KEY' => 'emailnotifications', VALUE => $selectprefs->{emailnotifications}, 'CHECK' => sub { check_int(1,31,@_) }},
		'notificationinterval' => {'KEY' => 'notificationinterval', VALUE => $selectprefs->{notificationinterval}, 'CHECK' => \&check_bool}
	};
	
	
	# iterate over the release types and add those as valid keys with a dummy value
	for my $key (keys %{$releaseTypes})
	{
		#$prefs->{$releaseTypes->{$key}[0]} = {'KEY' => $releaseTypes->{$key}[0], 'VALUE' => undef, 'CHECK' => undef};
	}
	
	
	
	$object->{prefs} = $prefs;
	
	
	
	return $object;
}



# remove or rewrite
sub addpref
{
	my ($this, $key, $value, $check) = @_;
	
	
	my $prefs = $this->{prefs};
	
	
	$this->{prefs}{$key} = {KEY => $key, VALUE => $value, CHECK => $check};
	
	#print STDERR 'asd'.Dumper($this->{prefs});
	
	
	
#	my ($key, $defaultvalue, $checksub) = @_;
#
#	defined($checksub->($defaultvalue))
#		or warn "Default value '$defaultvalue' for preference '$key' is not valid";
#
#	$prefs{$key} = {
#		KEY		=> $key,
#		DEFAULT	=> $defaultvalue,
#		CHECK	=> $checksub,
#	};
}


sub valid_keys {
	my ($this) = @_;
	use Data::Dumper;
	print STDERR Dumper($this->{prefs});
	my $prefs=$this->{prefs};
	#return keys %prefs;
	#my $prefs=$this->{prefs};
	#print '<br/>HASH:'.Dumper($prefs).'<br/>';
	#print '<br/>KEYS:'.Dumper(keys $prefs).'<br/>';
	#return keys $prefs;
	return keys %$prefs;
}



################################################################################
# get, set, load, save
################################################################################

=head2 get $key
Get the value of key C<$key>.
=cut
sub get
{
	my ($this, $key) = @_;
	
	
	my $info = $this->{prefs}->{$key}
		or carp("CollectionPreference::get called with invalid key '$key'"), return undef;
	
	
	return $info->{VALUE};
}



=head2 set $key, $value
Set preference with key C<$key> to value C<$value> in this object and in the db.
=cut
sub set
{
	my ($this, $key, $value) = @_;
	
	# check if the given key exists
	if(!defined($this->{prefs}{$key}{KEY}))
	{
		carp("CollectionPreference::set called with invalid key '$key'");
		return;
	}
	
	my $rawsql=Sql->new($this->{RAWDBH});
	
	my $prefs=$this->{prefs};
	
	my $info=$prefs->{$key}
		or carp("CollectionPreference::get called with invalid key '$key'"), return undef;
	
	
	
	my $oldkey = $info->{KEY};
	my $oldvalue = $info->{VALUE};
	my $oldcheck = $info->{CHECK};
	
	print STDERR 'key:'.$key.' value:'.Dumper($value);
	
	
	
	eval
	{
		$rawsql->Begin();
		
		# update setting in collection_info table
		$rawsql->Do("UPDATE collection_info SET $key = ? WHERE id='".$this->{collectionId}."'", $value);
	};
	
	if($@)
	{
		die('Could not update preference');
			
		$rawsql->Commit();	
	}
	else
	{
		# update setting in object hash
		$this->{prefs}{$key} = {'KEY' => $key, 'VALUE' => $value, 'CHECK' => $oldcheck};
				
		$rawsql->Commit();
	}







#	my ($key, $value) = @_;
#	my $info = $prefs{$key}
#		or carp("CollectionPreference::set called with invalid key '$key'"), return;
#	my $newvalue = $info->{CHECK}->($value);
#	defined $newvalue
#		or carp("UserPreference::set called with invalid value '$value' for key '$key'"), return;
#		
#	
#	# Update preference in database
#	print 'UPDATE';
}


sub getReleaseType
{
	
}



sub setReleaseType
{
	
}


sub LoadForUser
{
	my ($userId, $dbh) = @_;

	my $sql = Sql->new($dbh);
	my $rows = $sql->SelectListOfLists("SELECT * FROM collection_info WHERE moderator = ?", $userId);

#	for (@$rows)
#	{
#		my ($key, $value) = @$_;

#		my $info = $prefs{$key}
#			or warn("Moderator #$uid has invalid saved preference '$key'"), next;
#		my $newvalue = $info->{CHECK}->($value);
#		defined $newvalue
#			or warn("Moderator #$uid has invalid saved value '$value' for preference '$key'"), next;
#
#		$s->{"PREF_$key"} = $newvalue;
#	}
}


sub ArtistInMissingList
{
	my ($this, $artistId) = @_;
	#print '<br/>list:'.Dumper($this->{prefs});
	#return exists $this->{artistsMissing}->{$artistId};
	return 1;
}







#--------------------------------------------------
# Static subs
#--------------------------------------------------


=head2 ArtistWatch $artistId, $userId
Specifies that user with id C<$userId> want to watch for new releases of artist with id C<$artistId>.
=cut
sub ArtistWatch
{
	my ($artistId, $userId) = @_;
	
	require MusicBrainz;
	my $mbraw = MusicBrainz->new();
	$mbraw->Login(db => 'RAWDATA');
	my $rawsql = Sql->new($mbraw->{DBH});
	
	my $collectionId = MusicBrainz::Server::CollectionInfo::GetCollectionIdForUser($userId, $mbraw->{DBH});
	
	eval
	{
		$rawsql->Begin();
		$rawsql->Do('INSERT INTO collection_watch_artist_join (collection_info, artist) VALUES (?, ?)', $collectionId, $artistId);
	};
	
	if($@)
	{
		# do not care about duplicate error. it is caused by a user reloading page when a GET variable is set to add this artist
		if($@ =~ /duplicate/)
		{
			
		}
		else
		{
			die('Could not add artist to list of artists being watched');
		}
	}
	else
	{
		$rawsql->Commit();
	}
}



=head2 ArtistDontWatch $artistId, $userId
Specifies that user with id C<$userId> do not want to watch for new releases of artist with id C<$artistId>.
=cut
sub ArtistDontWatch
{
	my ($artistId, $userId) = @_;
	
	require MusicBrainz;
	my $mbraw = MusicBrainz->new();
	$mbraw->Login(db => 'RAWDATA');
	my $rawsql = Sql->new($mbraw->{DBH});
	
	my $collectionId = MusicBrainz::Server::CollectionInfo::GetCollectionIdForUser($userId, $mbraw->{DBH});
	
	
	$rawsql->Do('DELETE FROM collection_watch_artist_join WHERE collection_info = ? AND artist = ?', $collectionId, $artistId);
}



=head2 ArtistsDontShowMissing $artistId, $userId
Specifies that user with id C<$userId> want to see missing releases of artist with id C<$artistId>.
=cut
sub ArtistMissing
{
	my ($artistId, $userId) = @_;
	
	require MusicBrainz;
	my $mbraw = MusicBrainz->new();
	$mbraw->Login(db => 'RAWDATA');
	my $rawsql = Sql->new($mbraw->{DBH});
	
	use Data::Dumper;
	
	my $collectionId = MusicBrainz::Server::CollectionInfo::GetCollectionIdForUser($userId, $mbraw->{DBH});
	
	eval
	{
		$rawsql->Begin();
		$rawsql->Do('INSERT INTO collection_discography_artist_join (collection_info, artist) VALUES (?, ?)', $collectionId, $artistId);
	};
	
	if($@)
	{
		# do not care about duplicate error. it is caused by a user reloading page when a GET variable is set to add this artist
		if($@ =~ /duplicate/)
		{
			
		}
		else
		{
			die('Could not add artist to list of artists being watched');
		}
	}
	else
	{
		$rawsql->Commit();
	}
}



=head2 ArtistsDontShowMissing $artistId, $userId
Specifies that user with id C<$userId> do not want to see missing releases of artist with id C<$artistId>.
=cut
sub ArtistDontShowMissing
{
	my ($artistId, $userId) = @_;
	
	require MusicBrainz;
	my $mbraw = MusicBrainz->new();
	$mbraw->Login(db => 'RAWDATA');
	my $rawsql = Sql->new($mbraw->{DBH});
	
	use Data::Dumper;
	
	my $collectionId = MusicBrainz::Server::CollectionInfo::GetCollectionIdForUser($userId, $mbraw->{DBH});
	
	eval
	{
		$rawsql->Begin();
		$rawsql->Do('DELETE FROM collection_discography_artist_join WHERE collection_info = ? AND artist = ?', $collectionId, $artistId);
	};
	
	if($@)
	{
		$rawsql->Rollback;
		die($@);
	}
	else
	{
		$rawsql->Commit();
	}
}



sub GetReleaseTypes
{
	my %releaseTypes = (
	    0 => [ "releasetype_nonalbumtracks", "Non-Album Track", "Non-Album Tracks", "(Special case)"],
	    1 => [ "releasetype_album", "Album", "Albums", "An album release primarily consists of previously unreleased material. This includes album re-issues, with or without bonus tracks."],
	    2 => [ "releasetype_single", "Single", "Singles", "A single typically has one main song and possibly a handful of additional tracks or remixes of the main track. A single is usually named after its main song."],
	    3 => [ "releasetype_ep", "EP", "EPs", "An EP is an Extended Play release and often contains the letters EP in the title."],
	    4 => [ "releasetype_compilation", "Compilation", "Compilations", "A compilation is a collection of previously released tracks by one or more artists."],
	    5 => [ "releasetype_soundtrack", "Soundtrack", "Soundtracks", "A soundtrack is the musical score to a movie, TV series, stage show, computer game etc."],
	    6 => [ "releasetype_spokenword", "Spokenword", "Spokenword", "Non-music spoken word releases."],
	    7 => [ "releasetype_interview", "Interview", "Interviews", "An interview release contains an interview with the Artist."],
	    8 => [ "releasetype_audiobook", "Audiobook", "Audiobooks", "An audiobook is a book read by a narrator without music."],
	    9 => [ "releasetype_live", "Live", "Live Releases", "A release that was recorded live."],
	    10 => [ "releasetype_remix", "Remix", "Remixes", "A release that was (re)mixed from previously released material."],
	    11 => [ "releasetype_other", "Other", "Other Releases", "Any release that does not fit any of the categories above."],
	
	    100 => [ "releasetype_official", "Official", "Official", "Any release officially sanctioned by the artist and/or their record company. (Most releases will fit into this category.)"],
	    101 => [ "releasetype_promotion", "Promotion", "Promotions", "A giveaway release or a release intended to promote an upcoming official release. (e.g. prerelease albums or releases included with a magazine)"],
	    102 => [ "releasetype_bootleg", "Bootleg", "Bootlegs", "An unofficial/underground release that was not sanctioned by the artist and/or the record company."],
	    103 => [ "releasetype_pseudorelease", "Pseudo-Release", "PseudoReleases", "A pseudo-release is a duplicate release for translation/transliteration purposes."]
	);
	
	return \%releaseTypes;
}



1;

