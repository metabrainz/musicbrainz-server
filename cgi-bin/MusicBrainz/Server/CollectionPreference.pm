#
# TODO:
# check values
# make another new sub which does not get values from db, as the values are known from POST data(when sent)
#



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
	my $statusTypes = MusicBrainz::Server::CollectionPreference::GetStatusTypes();
	
	
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
		$prefs->{$releaseTypes->{$key}[0]} = {'KEY' => $releaseTypes->{$key}[0], 'VALUE' => undef, 'CHECK' => undef};
	}
	
	# ... and also iterate the status types and add those as well
	for my $key (keys %{$statusTypes})
	{
		$prefs->{$statusTypes->{$key}[0]} = {'KEY' => $statusTypes->{$key}[0], 'VALUE' => undef, 'CHECK' => undef};
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
	my $prefs=$this->{prefs};
	
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





=head2 SetShowTypes $showTypes
Sets which release and status types the user want to see missing releases of and be notified about new releases of. C<$showTypes> is an array reference for an array containing type identifiers to display.
=cut
sub SetShowTypes
{
	my ($this, $showTypes) = @_;
	
	my $rawsql=Sql->new($this->{RAWDBH});
	
	
	eval
	{
		$rawsql->Begin();
		$rawsql->Do("UPDATE collection_info SET ignoreattributes = '{" . join(',', @{$showTypes}) . "}' WHERE id = ?", $this->{collectionId});
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



sub GetShowTypes
{
	my ($this) = @_;
	
	my $rawsql = Sql->new($this->{RAWDBH});
	

	my $showTypes = $rawsql->SelectSingleValue('SELECT ignoreattributes FROM collection_info WHERE id = ?', $this->{collectionId});
	
	# convert to {1,2,3} formatted string to array
	my $showTypesPrefString = $showTypes;
	$showTypesPrefString =~ s/^\{(.*)\}$/$1/;
	my @showTypesPref = split(',', $showTypesPrefString); # ref to array containing identifiers of types to show currently in the prefs
	
	return @showTypesPref;
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
		#$rawsql->Quiet(1);
		$rawsql->Do('INSERT INTO collection_watch_artist_join (collection_info, artist) VALUES (?, ?)', $collectionId, $artistId);
	};
	
	if($@)
	{
		# do not care about duplicate error. it is caused by a user reloading page when a GET variable is set to add this artist
		if($@ =~ /duplicate/)
		{
			$rawsql->Rollback();
		}
		else
		{
			$rawsql->Rollback();
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
	
	eval
	{
		$rawsql->Begin();
		$rawsql->Do('DELETE FROM collection_watch_artist_join WHERE collection_info = ? AND artist = ?', $collectionId, $artistId);
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
		#$rawsql->Quiet(1);
		$rawsql->Do('INSERT INTO collection_discography_artist_join (collection_info, artist) VALUES (?, ?)', $collectionId, $artistId);
	};
	
	if($@)
	{
		# do not care about duplicate error. it is caused by a user reloading page when a GET variable is set to add this artist
		if($@ =~ /duplicate/)
		{
			$rawsql->Rollback();
		}
		else
		{
			$rawsql->Rollback();
			die('Could not add artist to list of artists being watched');
		}
	}
	else
	{
		$rawsql->Commit();
	}
}



=head2 ArtistDontShowMissing $artistId, $userId
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



=head2 GetReleaseTypes
Returns a reference to a hash with info about the different release types.
=cut
sub GetReleaseTypes
{
	my %releaseTypes = (
	    0 => [ "type_nonalbumtracks", "Non-Album Track", "Non-Album Tracks", "(Special case)"],
	    1 => [ "type_album", "Album", "Albums", "An album release primarily consists of previously unreleased material. This includes album re-issues, with or without bonus tracks."],
	    2 => [ "type_single", "Single", "Singles", "A single typically has one main song and possibly a handful of additional tracks or remixes of the main track. A single is usually named after its main song."],
	    3 => [ "type_ep", "EP", "EPs", "An EP is an Extended Play release and often contains the letters EP in the title."],
	    4 => [ "type_compilation", "Compilation", "Compilations", "A compilation is a collection of previously released tracks by one or more artists."],
	    5 => [ "type_soundtrack", "Soundtrack", "Soundtracks", "A soundtrack is the musical score to a movie, TV series, stage show, computer game etc."],
	    6 => [ "type_spokenword", "Spokenword", "Spokenword", "Non-music spoken word releases."],
	    7 => [ "type_interview", "Interview", "Interviews", "An interview release contains an interview with the Artist."],
	    8 => [ "type_audiobook", "Audiobook", "Audiobooks", "An audiobook is a book read by a narrator without music."],
	    9 => [ "type_live", "Live", "Live Releases", "A release that was recorded live."],
	    10 => [ "type_remix", "Remix", "Remixes", "A release that was (re)mixed from previously released material."],
	    11 => [ "type_other", "Other", "Other Releases", "Any release that does not fit any of the categories above."],
	);
	
	return \%releaseTypes;
}




sub GetStatusTypes
{
	my %statusTypes = (
		100 => [ "type_official", "Official", "Official", "Any release officially sanctioned by the artist and/or their record company. (Most releases will fit into this category.)"],
		101 => [ "type_promotion", "Promotion", "Promotions", "A giveaway release or a release intended to promote an upcoming official release. (e.g. prerelease albums or releases included with a magazine)"],
		102 => [ "type_bootleg", "Bootleg", "Bootlegs", "An unofficial/underground release that was not sanctioned by the artist and/or the record company."],
		103 => [ "type_pseudorelease", "Pseudo-Release", "PseudoReleases", "A pseudo-release is a duplicate release for translation/transliteration purposes."]
	);
	
	return \%statusTypes;
}



sub GetTypeIdentifiers
{
	my %types = (
		0 => 0,
		1 => 1,
		2 => 2,
		3 => 3,
		4 => 4,
		5 => 5,
		6 => 6,
		7 => 7,
		8 => 8,
		9 => 9,
		10 => 10,
		11 => 11,
		100 => 100,
		101 => 101,
		102 => 102,
		103 => 103
		);
	
	return \%types;
}



1;

