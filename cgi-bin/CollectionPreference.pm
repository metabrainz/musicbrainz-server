#
# TODO:
# check values
#



#!/usr/bin/perl -w


use strict;

package CollectionPreference;

#use Carp qw( carp );




sub new
{
	my ($this, $rawdbh, $userId) = @_;
	
	
	# get collection id
	my $sql=Sql->new($rawdbh);
	my $query="SELECT id FROM collection_info WHERE moderator='$userId'";
	my $collectionId=$sql->SelectSingleValue($query);
	
	# select artist id's of artists to display missing releases of
	my $artistsQuery="SELECT artist FROM collection_discography_artist_join WHERE collection_info='". $collectionId ."'";
	my $artistsMissing=$sql->SelectSingleColumnArray($artistsQuery);
	
	print 'missing:'.Dumper($artistsMissing);
	
	
	print Dumper($userId);
	
	print 'collectionId: '.$collectionId.'<br/><br/>';
	
	my $object=bless(
	{
		RAWDBH			=> $rawdbh,
		prefs			=> {},
		collectionId	=> $collectionId,
		artistsMissing	=>	$artistsMissing
	}, $this);
	
	$object->addpref('emailnotifications', 0, \&check_bool);
	$object->addpref('notificationinterval', 7, sub { check_int(1,31,@_) });
	
	return $object;
}


sub addpref
{
	my ($this, $key, $value, $check) = @_;
	
	
	my $prefs = $this->{prefs};
	
	$this->{prefs}{$key} = {KEY => $key, VALUE => $value, CHECK => $check};
	
	use Data::Dumper;
	print 'after addpref: '.Dumper($this->{prefs});
	
	
	
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
	my $prefs=$this->{prefs};
	print 'asdsdsa: '.Dumper(keys %$prefs);
	#return keys %prefs;
	#my $prefs=$this->{prefs};
	#print '<br/>HASH:'.Dumper($prefs).'<br/>';
	#print '<br/>KEYS:'.Dumper(keys $prefs).'<br/>';
	#return keys $prefs;
	return keys %$prefs;
}

################################################################################
# Value checkers.
# Each checker returns either 'undef' if the given value is not valid, or
# the value (or some normalised version of it) if it is vald.
################################################################################

sub check_bool { $_[0] ? 1 : 0 }

sub check_int
{
	my ($min, $max, $value) = @_;
	$value =~ /\A(\d+)\z/ or return undef;
	$value = 0+$1;
	return undef if defined $min and $value < $min;
	return undef if defined $max and $value > $max;
	$value;
}



################################################################################
# get, set, load, save
################################################################################

sub get
{
	my ($this, $key) = @_;
	
	
	if($key =~ /artistwatchmissing_/)
	{
		my $index=/artistwatchmissing_([0-9]*)/;
		return 1;
	}
	
	
	my $info = $this->{prefs}->{$key}
		or carp("CollectionPreference::get called with invalid key '$key'"), return undef;
		
	return $info->{VALUE};
	
	
	
#	my ($key) = @_;
#	my $info = $prefs{$key}
#		or carp("UserPreference::get called with invalid key '$key'"), return undef;
#
#	require UserStuff;
#	my $s = UserStuff->GetSession;
#	my $value = $s->{"PREF_$key"};
#	defined($value) or return $info->{DEFAULT};
#	$value;
}

sub set
{
	my ($this, $key, $value) = @_;
	
	my $sql=Sql->new($this->{RAWDBH});
	
	my $prefs=$this->{prefs};
	
	my $info=$prefs->{$key}
		or carp("CollectionPreference::get called with invalid key '$key'"), return undef;
	
	
	
	my $key = $info->{KEY};
	my $value = $info->{VALUE};
	
	print '<br/><br/>key: '.$key.'<br/>value: '.$value.'<br/>collectionId: '.$this->{collectionId}.'<br/>';
	
	#$sql->InsertRow("UPDATE collection_info SET $key='TRUE' WHERE id='".$this->{collectionId}."'");
	#$sql->InsertRow("UPDATE collection_info SET emailnotifications=FALSE WHERE id='0';");
	
	#FIXA EVAL?






	eval
	{
		$sql->Begin();
		
		# update setting in collection_info table
		$sql->Do("UPDATE collection_info SET $key='TRUE' WHERE id='".$this->{collectionId}."'");
		#$sql->Do("UPDATE collection_info SET emailnotifications=FALSE WHERE id='0';");
	};
	
	if($@)
	{
		my $error=$@; # get the error message
		
		print $error;
		
		$sql->Commit();	
	}
	else
	{
		# update setting in object hash
		$info->{$value}=0;
		
		print Dumper($this->{prefs});
		
		$sql->Commit();
	}







	print 'stored '.$key.', '.$value.'<br/>'
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

# set which artists to display missing discography of
sub setMissingOfArtists
{
	my ($this, @artists) = @_;
	print 'artists:'.Dumper(@artists);
	print 'RAWDBH:'.Dumper($this->{RAWDBH});
	my $rawsql = Sql->new($this->{RAWDBH});
	
	
	
	eval
	{
		$rawsql->Begin();
		
		# clear user's all entries in collection_discography_artist_join
		my $clearQuery="DELETE FROM collection_discography_artist_join WHERE collection_info=". $this->{collectionId};
		$rawsql->Do($clearQuery);
		
		# add selected artists
		for my $artistId (@artists)
		{
			my $addQuery="INSERT INTO collection_discography_artist_join (collection_info, artist) VALUES (". $this->{collectionId} .", ". $artistId .")";
			$rawsql->Do($addQuery);
		}
	};
	
	if($@)
	{
		print $@;
		$rawsql->Commit();
	}
	else
	{
		$rawsql->Commit();
	}
}

sub LoadForUser
{
	my ($userId, $dbh) = @_;

	my $sql = Sql->new($dbh);
	my $rows = $sql->SelectListOfLists("SELECT * FROM collection_info WHERE moderator = '$userId'");

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

sub SaveForUser
{
#	my ($user) = @_;
#
#	my $uid = $user->GetId
#		or return;
#
#	require UserStuff;
#	my $s = UserStuff->GetSession;
#	tied %$s
#		or carp("UserPreference::SaveForUser called, but %session is not tied"), return;
#
#	my $sql = Sql->new($user->{DBH});
#	my $wrap_transaction = $sql->{DBH}{AutoCommit};
#	
#	eval {
#		$sql->Begin if $wrap_transaction;
#		$sql->Do("DELETE FROM moderator_preference WHERE moderator = ?", $uid);
#
#		while (my ($key, $value) = each %$s)
#		{
#			$key =~ s/^PREF_// or next;
#			$sql->Do(
#				"INSERT INTO moderator_preference (moderator, name, value) VALUES (?, ?, ?)",
#				$uid, $key, $value,
#			);
#		}
#
#		$sql->Commit if $wrap_transaction;
#		1;
#	} or do {
#		my $e = $@;
#		$sql->Rollback if $wrap_transaction;
#		die $e;
#	};
}

sub ArtistInMissingList
{
	my ($this, $artistId) = @_;
	#print '<br/>list:'.Dumper($this->{prefs});
	#return exists $this->{artistsMissing}->{$artistId};
	return 1;
}

1;

