#____________________________________________________________________________
#
#   MusicBrainz -- the open internet music database
#
#   Copyright (C) 2000 Robert Kaye
#
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program; if not, write to the Free Software
#   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#
#   $Id$
#____________________________________________________________________________

package Moderation;

use strict;
use warnings;

use base qw(Class::Factory TableBase);

use Carp;
use DBDefs;
use Encode qw( encode decode );
use File::Find::Rule;
use ModDefs;
use MusicBrainz::Server::Validation qw( unaccent );
use utf8;
use UNIVERSAL::require;

my @moderations = File::Find::Rule->file->name('MOD_*.pm')->in(@INC);

for my $mod_file (@moderations)
{
    my $mod = $mod_file;
    $mod =~ s/\//::/g;
    $mod =~ s/.*(MusicBrainz::Server::Moderation::.*).pm$/$1/g;

    my $mod_name = $mod;
    $mod_name =~ s/.*::(.*)$/$1/g;

    unless (defined __PACKAGE__->get_registered_class($mod_name))
    {
        $mod->require;
        my $id = $mod::moderation_id;

        __PACKAGE__->register_factory_type($mod_name => $mod);
        __PACKAGE__->register_factory_type($id => $mod) if defined $id;
    }
}

=head2 edit_type $type_name

Given the name of a moderation type, C<$type_name>, will return
the id of this edit_type.

=cut

sub edit_type
{
    my ($type_name) = @_;

    my $class = __PACKAGE__->get_registered_class($type_name);

    return unless defined $class;
    return $class->moderation_id;
}

sub init
{
    my ($self, $dbh) = @_;
    $self->{DBH} = $dbh;

    return $self;
}

# The following two edit level definitions give the number of edit level details for moving the quality up or down.
my @QualityChangeDefs =
(
    # 0 == DOWN
	{ 
      duration => 14, 
      votes => 5, 
      expireaction => ModDefs::EXPIRE_REJECT, 
      autoedit => 0,  
      name => "Lower artist/release quality"
    },  
    # 1 == UP
	{ 
      duration => 3, 
      votes => 1, 
      expireaction => ModDefs::EXPIRE_ACCEPT, 
      autoedit => 0,  
      name => "Raise artist/release quality"
    }
);

# We'll store database handles that have open transactions in this hash for easy access.
local %Moderation::DBConnections = ();

sub GetQualityChangeDefs
{
    return $QualityChangeDefs[$_[0]];
}

=head2 $quality

Given a quality level, C<$quality>, determine the edit conditions
to perform this edit.

=cut

sub determine_edit_conditions
{
    my ($self, $quality) = @_;
    return $self->edit_conditions->{$quality};
}

=head2 allow_for_any_editor

Always allow an edit to be accepted, regardless of the editors details

=cut

sub allow_for_any_editor { 0 }

use constant SEARCHRESULT_SUCCESS => 1;
use constant SEARCHRESULT_NOQUERY => 2;
use constant SEARCHRESULT_TIMEOUT => 3;

use constant DEFAULT_SEARCH_TIMEOUT => 90;

my %ChangeNames = (
    &ModDefs::STATUS_OPEN			=> "Open",
    &ModDefs::STATUS_APPLIED		=> "Change applied",
    &ModDefs::STATUS_FAILEDVOTE		=> "Failed vote",
    &ModDefs::STATUS_FAILEDDEP		=> "Failed dependency",
    &ModDefs::STATUS_ERROR			=> "Internal error",
    &ModDefs::STATUS_FAILEDPREREQ	=> "Failed prerequisite",
    &ModDefs::STATUS_NOVOTES    	=> "No votes received",
    &ModDefs::STATUS_TOBEDELETED	=> "To be cancelled",
    &ModDefs::STATUS_DELETED		=> "Cancelled"
);

sub Refresh
{
	my $self = shift;
	my $newself = $self->CreateFromId($self->id);
	%$self = %$newself;
}

sub moderator
{
    my ($self, $new_moderator) = @_;

    if (defined $new_moderator) { $self->{moderator} = $new_moderator; }
    return $self->{moderator};
}

sub GetExpired
{
   return $_[0]->{isexpired};
}

sub SetExpired
{
   $_[0]->{isexpired} = $_[1];
}

sub GetGracePeriodExpired
{
   return $_[0]->{isgraceexpired};
}

sub SetGracePeriodExpired
{
   $_[0]->{isgraceexpired} = $_[1];
}

sub GetOpenTime
{
   return $_[0]->{opentime};
}

sub SetOpenTime
{
   $_[0]->{opentime} = $_[1];
}

sub GetCloseTime
{
   return $_[0]->{closetime};
}

sub SetCloseTime
{
   $_[0]->{closetime} = $_[1];
}

sub GetExpireTime
{
   return $_[0]->{expiretime};
}

sub SetExpireTime
{
   $_[0]->{expiretime} = $_[1];
}

sub type
{
    my ($self, $new_type) = @_;

    if (defined $new_type) { $self->{type} = $new_type; }
    return $self->{type};
}

sub GetStatus
{
   return $_[0]->{status};
}

sub SetStatus
{
   $_[0]->{status} = $_[1];
}

sub language_id
{
    my ($self, $new_id) = @_;

    if (defined $new_id) { $self->{language} = $new_id; }
    return $self->{language};
}

sub language
{
	my $self = shift;
	my $id = $self->language_id or return undef;
	require MusicBrainz::Server::Language;
	return MusicBrainz::Server::Language->newFromId($self->{DBH}, $id);
}

sub quality
{
    my ($self, $new_quality) = @_;

    if (defined $new_quality) { $self->{quality} = $new_quality; }

    # If the quality hasn't been set, call the moderation to figure it out
    if (!exists $self->{quality}) { $self->{quality} = $self->DetermineQuality(); }

    return $self->{quality};
}

sub IsOpen
{
    my $self = @_;
    
    return $self->{status} == ModDefs::STATUS_OPEN ||
           $self->{status} == ModDefs::STATUS_TOBEDELETED;
}

sub IsAutoEditType
{
   my ($this, $type) = @_;

   if ($this->type == edit_type('MOD_CHANGE_RELEASE_QUALITY') ||
       $this->type == edit_type('MOD_CHANGE_ARTIST_QUALITY'))
   {
        return $QualityChangeDefs[$this->GetQualityChangeDirection]->{automod};
   }

   my $level = GetEditLevelDefs($this->quality, $type);

   return $level->{autoedit};
}

sub GetNumVotesNeeded
{
   my ($this) = @_;

   if ($this->type == edit_type('MOD_CHANGE_RELEASE_QUALITY') ||
       $this->type == edit_type('MOD_CHANGE_ARTIST_QUALITY'))
   {
        return $QualityChangeDefs[$this->GetQualityChangeDirection]->{votes};
   }
   my $level = GetEditLevelDefs($this->quality, $this->type);
   return $level->{votes};
}

sub GetExpireAction
{
   my ($this) = @_;
   if ($this->type == edit_type('MOD_CHANGE_RELEASE_QUALITY') ||
       $this->type == edit_type('ModDefs::MOD_CHANGE_ARTIST_QUALITY'))
   {
        return $QualityChangeDefs[$this->GetQualityChangeDirection]->{expireaction};
   }
   my $level = GetEditLevelDefs($this->quality, $this->type);
   return $level->{expireaction};
}

sub artist
{
    my ($self, $new_artist) = @_;

    if (defined $new_artist) { $self->{artist} = $new_artist; }
    return $self->{artist};
}

sub GetYesVotes
{
   return $_[0]->{yesvotes};
}

sub SetYesVotes
{
   $_[0]->{yesvotes} = $_[1];
}

sub GetNoVotes
{
   return $_[0]->{novotes};
}

sub SetNoVotes
{
   $_[0]->{novotes} = $_[1];
}

sub table
{
    my ($self, $new_table) = @_;

    if (defined $new_table) { $self->{table} = $new_table; }
    return $self->{table};
}

sub GetColumn
{
   return $_[0]->{column};
}

sub SetColumn
{
   $_[0]->{column} = $_[1];
}

sub row_id
{
    my ($self, $new_id) = @_;

    if (defined $new_id) { $self->{rowid} = $new_id; }
    return $self->{rowid};
}

sub GetDepMod
{
   return $_[0]->{depmod};
}

sub SetDepMod
{
   $_[0]->{depmod} = $_[1];
}

sub GetPrev
{
   return $_[0]->{prev};
}

sub SetPrev
{
   $_[0]->{prev} = $_[1];
}

sub GetNew
{
   return $_[0]->{new};
}

sub SetNew
{
   $_[0]->{new} = $_[1];
}

sub GetVote
{
   return $_[0]->{vote};
}

sub SetVote
{
   $_[0]->{vote} = $_[1];
}

sub artist_name
{
    my ($self, $new_name) = @_;

    if (defined $new_name) { $self->{artistname} = $new_name; }
    return $self->{artistname};
}

sub artist_sort_name
{
    my ($self, $new_sort) = @_;

    if (defined $new_sort) { $self->{artistsortname} = $new_sort; }
    return $self->{artistsortname};
}

sub artist_resolution
{
    my ($self, $new_resolution) = @_;

    if (defined $new_resolution) { $self->{artistresolution} = $new_resolution; }
    return $self->{artistresolution};
}

sub moderator_name
{
    my ($self, $new_name) = @_;

    if (defined $new_name) { $self->{moderatorname} = $new_name; }
    return $self->{moderatorname};
}

sub GetAutomod
{
   return $_[0]->{automod};
}

sub SetAutomod
{
   $_[0]->{automod} = $_[1];
}

sub GetError
{
   return $_[0]->{error};
}

sub SetError
{
   $_[0]->{error} = $_[1];
}

sub GetChangeName
{
   return $ChangeNames{$_[0]->{status}};
}

sub GetAutomoderatorList
{
   my ($this) = @_;
   my ($sql);

   $sql = Sql->new($this->{DBH});
   require MusicBrainz::Server::Editor;
   return $sql->SelectSingleColumnArray("select name from moderator where privs & " .
                                        &MusicBrainz::Server::Editor::AUTOMOD_FLAG . " > 0 order by name");
}

# This function will load a change from the database and return
# a new ModerationXXXXXX object. Pass the rowid to load as the first arg
sub CreateFromId
{
   my ($this, $id) = @_;
   my ($edit, $query, $sql, @row);

   $query = qq/select m.id, tab, col, m.rowid, 
                      m.artist, m.type, prevvalue, newvalue, 
                      ExpireTime, Moderator.name, 
                      yesvotes, novotes, Artist.name, Artist.sortname, Artist.resolution, 
                      status, 0, depmod, Moderator.id, m.automod, m.language,
                      opentime, closetime,
                      ExpireTime < now(), ExpireTime + INTERVAL ? < now()
               from   moderation_all m, Moderator, Artist 
               where  Moderator.id = moderator and m.artist = 
                      Artist.id and m.id = ?/;

   $sql = Sql->new($this->{DBH});
   if ($sql->Select($query, &DBDefs::MOD_PERIOD_GRACE, $id))
   {
        @row = $sql->NextRow();
        $edit = $this->CreateModerationObject($row[5]);
        if (defined $edit)
        {
			$edit->id($row[0]);
			$edit->table($row[1]);
			$edit->SetColumn($row[2]);
			$edit->row_id($row[3]);
			$edit->artist($row[4]);
			$edit->type($row[5]);
			$edit->SetPrev($row[6]);
			$edit->SetNew($row[7]);
			$edit->SetExpireTime($row[8]);
			$edit->moderator_name($row[9]);
			$edit->SetYesVotes($row[10]);
			$edit->SetNoVotes($row[11]);
			$edit->artist_name($row[12]);
			$edit->artist_sort_name($row[13]);
			$edit->artist_resolution($row[14]);
			$edit->SetStatus($row[15]);
			$edit->SetVote(&ModDefs::VOTE_UNKNOWN);
			$edit->SetDepMod($row[17]);
			$edit->moderator($row[18]);
			$edit->SetAutomod($row[19]);
			$edit->language_id($row[20]);
			$edit->SetOpenTime($row[21]);
			$edit->SetCloseTime($row[22]);
			$edit->SetExpired($row[23]);
			$edit->SetGracePeriodExpired($row[24]);
			$edit->PostLoad;
       }
   }

   $sql->Finish();
   return $edit;
}

sub iiMinMaxID
{
	my $self = shift;
	$self = $self->new(shift) if not ref $self;
	my %opts = @_;

	my $open = $opts{"open"};

	require MusicBrainz::Server::Cache;
	my $key = "Moderation" . ($open ? "-open" : defined($open) ? "-closed" : "") . "-id-range";
	if (my $t = MusicBrainz::Server::Cache->get($key)) { return @$t }

	my $sql = Sql->new($self->{DBH});
	my ($min, $max) = $sql->GetColumnRange(
		($open ? "moderation_open"
		: defined($open) ? "moderation_closed"
		: [qw( moderation_open moderation_closed )])
	);

	$min ||= 0;
	$max ||= 0;

	my @range = ($min, $max);
	MusicBrainz::Server::Cache->set($key, \@range);
	return @range;
}

# Find the ID of the first message at or after $iTime
sub iFindByTime
{
	my $self = shift;
	$self = $self->new(shift) if not ref $self;
	my $sTime = shift;
	my %opts = @_;

	my $open = $opts{"open"};

	if ($sTime =~ /\A\d+\z/)
	{
		require POSIX;
		$sTime = POSIX::strftime("%Y-%m-%d %H:%M:%S", gmtime $sTime);
	}

	my ($iMin, $iMax) = $self->iiMinMaxID('open' => $opts{'open'});
	my $sql = Sql->new($self->{DBH});

	my $gettime = sub {
		$sql->SelectSingleValue(
			"SELECT opentime FROM moderation_all WHERE id = ?",
			0 + shift(),
		);
	};

	my $sMinTime = &$gettime($iMin);
	my $sMaxTime = &$gettime($iMax);
	return $iMin if $sTime le $sMinTime;
	return undef if $sTime gt $sMaxTime;

	while ($iMax-$iMin > 100)
	{
		#my $pct = ($iTime-$iMinTime) / ($iMaxTime-$iMinTime);
		my $pct = 0.5;
		my $iMid = int( $iMin + ($iMax-$iMin)*$pct );
		$iMid += 10 if $iMid == $iMin;
		$iMid -= 10 if $iMid == $iMax;
		my $oldmid = $iMid;
		my $sMidTime;

		for (;;)
		{
			$sMidTime = &$gettime($iMid)
				and last;
			++$iMid;
			die "No edits found between $oldmid and $iMax"
				if $iMid == $iMax;
		}

		if ($sMidTime lt $sTime)
		{
			$iMin = $iMid;
			$sMinTime = $sMidTime;
		} else {
			$iMax = $iMid;
			$sMaxTime = $sMidTime;
		}
	}

	$sql->SelectSingleValue(
		"SELECT MIN(id) FROM moderation_all
		WHERE id BETWEEN ? AND ?
		AND opentime >= ?",
		$iMin,
		$iMax,
		$sTime,
	);
}

# Use this function to create a new moderation object of the specified type
sub CreateModerationObject
{
	my ($this, $type) = @_;
	my $class = $this->ClassFromType($type)
		or die "Unknown moderation type $type";
	$class->new($this->{DBH});
}

=head2 insert %opts

Insert a new moderation into the database. C<%opts> contains all the options
and necessary data to create this edit type. You should check the documentation
for specific edit types, but the bare minimum for all moderations are the options:

=over 4

=item DBH - the database handle to work with

=item uid - the id of the L<MusicBrainz::Server::Editor> who created this edit

=item privs - the privileges of the L<MusicBrainz::Server::Editor>

=back

=cut

sub insert
{
    my ($self, %opts) = @_;

    my $vertmb = new MusicBrainz;
    $vertmb->Login(db => 'RAWDATA');

	my $sql     = Sql->new($opts{DBH});
    my $vertsql = Sql->new($vertmb->{DBH});

    my $no_transaction = exists $opts{notrans};

    # in some cases there are nested transaction (e.g. some album merges) where
    # we specfically do not want to start a new transaction
    unless ($no_transaction)
    {
        $sql->Begin;
        $vertsql->Begin;

        $Moderation::DBConnections{READWRITE} = $sql;
        $Moderation::DBConnections{RAWDATA}   = $vertsql;
    }

	eval
	{
		# The PreInsert method must perform any work it needs to - e.g. inserting
		# records which maybe ->DeniedAction will delete later - and then override
		# these default column values as appropriate:
		$self->artist(&ModDefs::VARTIST_ID); #TODO no, artist takes refs now, not ids
		$self->table("");
		$self->SetColumn("");
		$self->row_id(0);
		$self->SetDepMod(0);
		$self->SetPrev("");
		$self->SetNew("");
		$self->PreInsert(%opts);

		goto SUPPRESS_INSERT
            if $self->{suppress_insert};

		$self->PostLoad;

		use DebugLog;
		if (my $d = DebugLog->open)
		{
			$d->stamp;
			$d->dumper([$self], ['self']);
			$d->dumpstring($self->{prev}, "self-prev");
			$d->dumpstring($self->{new}, "self-new");
			$d->close;
		}

		my $level = $self->determine_edit_conditions($self->quality);

		$sql->Do(
            "INSERT INTO moderation_open (
                tab, col, rowid,
                prevvalue, newvalue,
                moderator, artist, type,
                depmod,
                status, expiretime, yesvotes, novotes, automod, language
            ) VALUES (
                ?, ?, ?,
                ?, ?,
                ?, ?, ?,
                ?,
                ?, NOW() + INTERVAL ?, 0, 0, 0, ?
            )",
            $self->table, $self->GetColumn, $self->row_id,
            $self->GetPrev, $self->GetNew,
            $opts{user}->id, $self->artist, $self->moderation_id,
            $self->GetDepMod,
            ModDefs::STATUS_OPEN, sprintf("%d days", $level->{duration}),
            $self->language_id
		);

        # Lookup the newly inserted moderation
        # TODO race condition?
		my $insert_id = $sql->GetLastInsertId("moderation_open");
		MusicBrainz::Server::Cache->delete("Moderation-id-range");
		MusicBrainz::Server::Cache->delete("Moderation-open-id-range");
		$self->id($insert_id);

		# Check to see if this moderation should be approved immediately 
		my $user          = $opts{user};
		my $is_autoeditor = $user->IsAutoEditor($user->privs);

		my $autoedit = 0;

		# If the edit allows an autoedit and the current level allows autoedits,
        # then make it an autoedit
		$autoedit = 1 if (not $autoedit
		                  and $self->IsAutoEdit($is_autoeditor) 
		                  and $level->{autoedit});

		# If the edit type is an autoedit and the editor is an autoeditor,
        # then make it an autoedit
		$autoedit = 1 if (not $autoedit
		                  and $is_autoeditor
		                  and $level->{autoedit});

		# If the editor is untrusted, undo the auto edit
        $autoedit = 0
            if ($user->IsUntrusted($user->privs) && !$self->allow_for_any_editor); 

		# If it is autoedit, then approve the edit and credit the editor
		if ($autoedit)
		{
			my $edit   = $self->CreateFromId($self->id);
			my $status = $edit->ApprovedAction;

			$sql->Do("UPDATE moderation_open SET status = ?, automod = 1 WHERE id = ?",
				$status,
				$self->id,
			);

			require MusicBrainz::Server::Editor;
			my $user = MusicBrainz::Server::Editor->new($self->{DBH});
			$user->CreditModerator($self->{moderator}, $status, $autoedit);

			MusicBrainz::Server::Cache->delete("Moderation-open-id-range");
			MusicBrainz::Server::Cache->delete("Moderation-closed-id-range");
		}
		else
		{
			$self->AdjustModPending(+1);
		}

SUPPRESS_INSERT:

        unless ($no_transaction)
        {
            delete $Moderation::DBConnections{READWRITE};
            delete $Moderation::DBConnections{RAWDATA};

            $vertsql->Commit;
            $sql->Commit;
        }
	};

	if ($@)
	{
		my $err = $@;
        unless ($no_transaction)
        {
            delete $Moderation::DBConnections{READWRITE};
            delete $Moderation::DBConnections{RAWDATA};
            $vertsql->Rollback;
            $sql->Rollback;
        }
		croak $err;
	};
}

sub GetMaxModID
{
	my $self = shift;
	($self->iiMinMaxID(@_))[1];
}

sub OpenModsByType_as_hashref
{
	my $self = shift;
	my $sql = Sql->new($self->{DBH});

	my $rows = $sql->SelectListOfLists(
		"SELECT type, COUNT(*) FROM moderation_open
		WHERE status = ".&ModDefs::STATUS_OPEN." GROUP BY type",
	);

	+{
		map { $_->[0] => $_->[1] } @$rows
	};
}

sub OpenModCountByModerator
{
	my $self = shift;
	my $editor = shift;
	my $sql = Sql->new($self->{DBH});

	return $sql->SelectSingleValue(
		"SELECT COUNT(*) FROM moderation_open
		WHERE status = ".&ModDefs::STATUS_OPEN." and moderator = ?",
        $editor
	);
}

# This function returns the list of moderations to
# be shown on one moderation page.  It returns an array
# of references to Moderation objects.

sub moderation_list
{
	my ($this, $query, $voter, $index, $num) = @_;
	$query or return SEARCHRESULT_NOQUERY;

	my $sql = Sql->new($this->{DBH});

    $sql->AutoCommit;
	$sql->Do("SET SESSION STATEMENT_TIMEOUT = " . int(DEFAULT_SEARCH_TIMEOUT*1000));

	my $ok = eval {
		local $sql->{Quiet} = 1;
		$query .= " OFFSET " . ($index||0);
		$sql->Select($query);
		1;
	};
	my $err = $@;

    $sql->AutoCommit;
	$sql->Do("SET SESSION STATEMENT_TIMEOUT = DEFAULT");

	if (not $ok)
	{
		if ($sql->is_timeout($err))
		{
			warn "Moderation search timed out.  The query was: $query\n";
			return SEARCHRESULT_TIMEOUT;
		}

		die $err;
	}

	my @edits;

	while (@edits < $num)
	{
		my $r = $sql->NextRowHashRef
			or last;
		my $edit = $this->CreateModerationObject($r->{type});

		unless ($edit)
		{
			print STDERR "Could not create moderation object for type=$r->{type}\n";
			next;
		}

		$edit->id($r->{id});
		$edit->artist($r->{artist});
		$edit->moderator($r->{moderator});
		$edit->table($r->{tab});
		$edit->SetColumn($r->{col});
		$edit->type($r->{type});
		$edit->SetStatus($r->{status});
		$edit->row_id($r->{rowid});
		$edit->SetPrev($r->{prevvalue});
		$edit->SetNew($r->{newvalue});
		$edit->SetYesVotes($r->{yesvotes});
		$edit->SetNoVotes($r->{novotes});
		$edit->SetDepMod($r->{depmod});
		$edit->SetAutomod($r->{automod});
		$edit->SetOpenTime($r->{opentime});
		$edit->SetCloseTime($r->{closetime});
		$edit->SetExpireTime($r->{expiretime});
		$edit->language_id($r->{language});

		$edit->SetExpired($r->{expired});
		$edit->SetVote($r->{vote});

		push @edits, $edit;
	}

	my $total_rows = $sql->Rows;

	$sql->Finish;

	# Fetch artists, and cache by artistid.
	require MusicBrainz::Server::Artist;
	my %artist_cache;
	
	# Cache editors by name
	require MusicBrainz::Server::Editor;
	my $user = MusicBrainz::Server::Editor->new($this->{DBH});
	my %editor_cache;
		
	require MusicBrainz::Server::Vote;
	my $vote = MusicBrainz::Server::Vote->new($this->{DBH});

	for my $edit (@edits)
	{
		# Fetch editor into cache if not loaded before.
		my $uid = $edit->moderator;
		$editor_cache{$uid} = do {
			my $u = $user->newFromId($uid);
			$u ? $u->name : "?";
		} unless defined $editor_cache{$uid};
		$edit->moderator_name($editor_cache{$uid});

		# Fetch artist into cache if not loaded before.
		my $artistid = $edit->artist;
		if (not defined $artist_cache{$artistid})
		{
			my $artist = MusicBrainz::Server::Artist->new($this->{DBH});
			$artist->id($artistid);
			if ($artist->LoadFromId())
			{
				$artist_cache{$artistid} = $artist;
			} 
		}
		
		my $artist = $artist_cache{$artistid};
		$edit->artist_name($artist ? $artist->name : "?");
		$edit->artist_sort_name($artist ? $artist->sort_name : "?");
		$edit->artist_resolution($artist ? $artist->resolution : "?");

		# Find vote
		if ($edit->GetVote == ModDefs::VOTE_UNKNOWN and $voter)
		{
			my $thevote = $vote->GetLatestVoteFromUser($edit->id, $voter);
			$edit->SetVote($thevote);
		}
	}

	for (@edits) {
		$_->PostLoad;
		$_->PreDisplay;
	}

	return (SEARCHRESULT_SUCCESS, \@edits, $index+$total_rows);
}

################################################################################

sub CloseModeration
{
	my ($this, $status) = @_;
	use Carp qw( confess );
	confess "CloseModeration called where status is false"
		if not $status;
	confess "CloseModeration called where status is STATUS_OPEN"
		if $status == ModDefs::STATUS_OPEN;
	confess "CloseModeration called where status is STATUS_TOBEDELETED"
		if $status == ModDefs::STATUS_TOBEDELETED;

	# Decrement the mod count in the data row
	$this->AdjustModPending(-1);

 	# Set the status in the Moderation row
  	my $sql = Sql->new($this->{DBH});
   	$sql->Do(
		"UPDATE moderation_open SET status = ? WHERE id = ?",
		$status,
		$this->id,
	);

	MusicBrainz::Server::Cache->delete("Moderation-open-id-range");
	MusicBrainz::Server::Cache->delete("Moderation-closed-id-range");
}

sub RemoveModeration
{
   my ($this, $uid) = @_;
  
   if ($this->GetStatus() == &ModDefs::STATUS_OPEN)
   {
		# Set the status to be deleted.  The ModBot will clean it up
		# on its next pass.
		my $sql = Sql->new($this->{DBH});
		$sql->Do(
			"UPDATE moderation_open SET status = ?
			WHERE id = ? AND moderator = ? AND status = ?",
	   		&ModDefs::STATUS_TOBEDELETED,
			$this->id,
			$uid,
	   		&ModDefs::STATUS_OPEN,
		);
   }
}

# Links to the ModerationNote class

sub Notes
{
	my $self = shift;
	require MusicBrainz::Server::ModerationNote;
	my $notes = MusicBrainz::Server::ModerationNote->new($self->{DBH});
	$notes->newFromModerationId($self->id);
}

sub InsertNote
{
	my $self = shift;
	require MusicBrainz::Server::ModerationNote;
	my $notes = MusicBrainz::Server::ModerationNote->new($self->{DBH});
	$notes->Insert($self, @_);
}

# Links to the Vote class

sub Votes
{
	my $self = shift;
	require MusicBrainz::Server::Vote;
	my $votes = MusicBrainz::Server::Vote->new($self->{DBH});
	$votes->newFromModerationId($self->id);
}

sub VoteFromUser
{
	my ($self, $uid) = @_;
	require MusicBrainz::Server::Vote;
	my $votes = MusicBrainz::Server::Vote->new($self->{DBH});
	# The number of votes per mod is small, so we may as well just retrieve
	# all votes for the mod, then find the one we want.
	my @votes = $votes->newFromModerationId($self->id);
	# Pick the most recent vote from this user
	(my $thevote) = reverse grep { $_->GetUserId == $uid } @votes;
	$thevote;
}

sub FirstNoVote
{
	my ($self, $voter_uid) = @_;

	require MusicBrainz::Server::Editor;
	my $editor = MusicBrainz::Server::Editor->newFromId($self->{DBH}, $self->moderator);
	my $voter = MusicBrainz::Server::Editor->newFromId($self->{DBH}, $voter_uid);

	require UserPreference;
	my $send_mail = UserPreference::get_for_user('mail_on_first_no_vote', $editor);
	$send_mail or return;

	my $url = "http://" . &DBDefs::WEB_SERVER . "/show/edit/?editid=" . $self->id;

	my $body = <<EOF;
Editor '${\ $voter->name }' has voted against your edit #${\ $self->id }.
------------------------------------------------------------------------
If you would like to respond to this vote, please add your note at:
$url
Please do not respond to this e-mail.

This e-mail is only sent for the first vote against your edit, not for each
one. If you would prefer not to receive these e-mails, please adjust your
preferences accordingly at http://${\ DBDefs::WEB_SERVER() }/user/preferences.html
EOF

	require MusicBrainz::Server::Mail;
	my $mail = MusicBrainz::Server::Mail->new(
		# Sender: not required
		From		=> 'MusicBrainz <webserver@musicbrainz.org>',
		# To: $self (automatic)
		"Reply-To"	=> 'MusicBrainz Support <support@musicbrainz.org>',
		Subject		=> "Someone has voted against your edit",
		References	=> '<edit-'.$self->id.'@'.&DBDefs::WEB_SERVER.'>',
		Type		=> "text/plain",
		Encoding	=> "quoted-printable",
		Data		=> $body,
	);
    $mail->attr("content-type.charset" => "utf-8");

	$editor->SendFormattedEmail(entity => $mail);
}

################################################################################

sub TopModerators
{
	my ($self, %opts) = @_;

	my $nl = $opts{namelimit} || 11;
	$nl = 6 if $nl < 6;
	my $nl2 = $nl-3;

	$opts{rowlimit} ||= 5;
	$opts{interval} ||= "1 week";

	my $sql = Sql->new($self->{DBH});

	$sql->SelectListOfHashes(
		"SELECT	u.id, u.name,
				CASE WHEN LENGTH(name)<=$nl THEN name ELSE SUBSTR(name, 1, $nl2) || '...' END
				AS nametrunc,
				COUNT(*) AS num
		FROM	moderation_all m, moderator u
		WHERE	m.moderator = u.id
		AND		u.id != " . ModDefs::FREEDB_MODERATOR ."
		AND		u.id != " . ModDefs::MODBOT_MODERATOR ."
		AND		m.opentime > NOW() - INTERVAL ?
		GROUP BY u.id, u.name
		ORDER BY num DESC
		LIMIT ?",
		$opts{interval},
		$opts{rowlimit},
	);
}

sub TopAcceptedModeratorsAllTime
{
	my ($self, %opts) = @_;

	my $nl = $opts{namelimit} || 11;
	$nl = 6 if $nl < 6;
	my $nl2 = $nl-3;

	$opts{rowlimit} ||= 5;

	my $sql = Sql->new($self->{DBH});

	$sql->SelectListOfHashes(
		"SELECT	id, name,
				CASE WHEN LENGTH(name)<=$nl THEN name ELSE SUBSTR(name, 1, $nl2) || '...' END
				AS nametrunc,
				modsaccepted + automodsaccepted AS num
		FROM	moderator
		WHERE	id != " . ModDefs::FREEDB_MODERATOR ."
		AND		id != " . ModDefs::MODBOT_MODERATOR ."
		ORDER BY num DESC
		LIMIT ?",
		$opts{rowlimit},
	);
}

################################################################################
# Sub-class registration
################################################################################

{
	our %subs;

	sub RegisterHandler
	{
		my $subclass = shift;
		my $type = $subclass->Type;
		
		if (my $existing = $subs{$type})
		{
			$existing eq $subclass
				or die "$subclass and $existing both claim moderation type $type";
		}

		$subs{$type} = $subclass;
	}

	sub ClassFromType
	{
		my ($class, $type) = @_;
		$subs{$type};
	}

	sub RegisteredMods { \%subs }
}

################################################################################
# Methods which sub-classes should probably not override
################################################################################

sub Token
{
	my $self = shift;
	my $classname = ref($self) || $self;

	(my $token) = (reverse $classname) =~ /^(\w+)/;
	$token = reverse $token;

	# Cache it by turning it into a constant
	#eval "package $classname; use constant Token => '$token'";
	eval "sub ${classname}::Token() { '$token' }";
	die $@ if $@;

	$token;
}

sub Type
{
	my $self = shift;
	my $classname = ref($self) || $self;

	require ModDefs;
	my $token = $self->Token;
	my $type = ModDefs->$token;

	# Cache it by turning it into a constant
	#eval "package $classname; use constant Type => $type";
	eval "sub ${classname}::Type() { $type }";
	die $@ if $@;

	$type;
}

sub GetComponent
{
	my ($self, $mason) = @_;
	my $token = $self->Token;
	$mason->fetch_comp("/comp/moderation/$token")
		or die "Failed to find Mason component for $token";
}

# This function will get called from the html pages to output the
# contents of the moderation type field.
sub ShowModType
{
	my ($this, $mason, $showeditlinks) = splice(@_, 0, 3);
	
	#use MusicBrainz qw( encode_entities );
	
	# default exists is to check if the given name is set
	# in the values hash.
	($this->{"exists-album"}, $this->{"exists-track"}) =  ($this->{"albumname"}, $this->{"trackname"});

	# attempt to load track entity, and see if it still exists.
	# --- this flag was set in the individual PostLoad
	#     implementations of the edit types
	if ($this->{"checkexists-track"} && defined $this->{"trackid"})
	{
		require MusicBrainz::Server::Track;
		my $track = MusicBrainz::Server::Track->new($this->{DBH});
		$track->id($this->{"trackid"});
		if ($this->{"exists-track"} = $track->LoadFromId)
		{
			$this->{"trackid"} = $track->id;
			$this->{"trackname"} = $track->name;
			$this->{"trackseq"} = $track->sequence;
			
			# assume that the release needs to be loaded from
			# the album-track core relationship, if it not
			# has been set explicitly.
			$this->{"albumid"} = $track->release if ($this->{"checkexists-album"} && not defined $this->{"albumid"});
		}
	}
	
	# attempt to load release entity, and see if it still exists
	# --- this flag was set in the individual PostLoad
	#     implementations of the edit types	
	if ($this->{"checkexists-album"} && defined $this->{"albumid"})
	{
		require MusicBrainz::Server::Release;
		my $release = MusicBrainz::Server::Release->new($this->{DBH});
		$release->id($this->{"albumid"});
		if ($this->{"exists-album"} = $release->LoadFromId)
		{
			$this->{"albumid"} = $release->id;
			$this->{"albumname"} = $release->name;
			$this->{"trackcount"} = $release->track_count;
			$this->{"isnonalbum"} = $release->IsNonAlbumTracks;
		}	
	}
	
	# do not display release if we have a batch edit type
	$this->{"albumid"} = undef 
		if ($this->type == &ModDefs::MOD_REMOVE_RELEASES or
			$this->type == &ModDefs::MOD_MERGE_RELEASE or
			$this->type == &ModDefs::MOD_MERGE_RELEASE_MAC or
			$this->type == &ModDefs::MOD_EDIT_RELEASE_LANGUAGE or
			$this->type == &ModDefs::MOD_EDIT_RELEASE_ATTRS);
	
	$mason->out(qq!<table class="edittype">!);

	# output edittype as wikidoc link
	$mason->out(qq!<tr class="entity"><td class="lbl">Type:</td><td>!);
	my $docname = $this->Name."Edit";
	$docname =~ s/\s//g;
	$mason->comp("/comp/linkdoc", $docname, $this->Name);
	if ($this->GetAutomod)
	{
		$mason->out(qq! &nbsp; <small>(<a href="/doc/AutoEdit">Autoedit</a>)</small>!);
 	}
 	
	# if current/total number of tracks is available, show the info...
	# ...but do not show sequence number for non-album tracks
	my $seq = "";
	if (!$this->{"isnonalbum"})
	{
		$seq = ($this->{"trackseq"} 
			? " &nbsp; <small>(Track: " . $this->{"trackseq"} 
				  . ($this->{"trackcount"} 
					? "/".$this->{"trackcount"}
					: "")
				  . ")</small>"
			: "");	
	}
	$mason->out(qq!$seq</td></tr>!);
	

	# output the artist this edit is listed under.
	if (!$this->{'dont-display-artist'})
	{
		$mason->out(qq!<tr class="entity"><td class="lbl">Artist:</td>!);
		$mason->out(qq!<td>!);
		$mason->comp("/comp/linkartist", 
			id => $this->artist, 
			name => $this->artist_name, 
			sortname => $this->artist_sort_name, 
			resolution => $this->artist_resolution,
			strong => 0
		);
		$mason->out(qq!</td>!);
		if ($showeditlinks)
		{
			$mason->out(qq!<td class="editlinks">!);
			$mason->comp("/comp/linkedits", type => "artist", id => $this->artist, explain => 1);
			$mason->out(qq!</td>!);
		}
		$mason->out(qq!</tr>!);	
	}
	
	
	# output the release this edit is listed under.
	if (defined $this->{"albumid"})
	{
		my ($id, $name, $title) = ($this->{"albumid"}, $this->{"albumname"}, undef);
		if (not $this->{"exists-album"})
		{
			$name = "This release has been removed" if (not defined $name);
			$title = "This release has been removed, Id: $id";
			$id = -1;	
		}
		
		$mason->out(qq!<tr class="entity"><td class="lbl">Release:</td>!);	
		$mason->out(qq!<td>!);
		$mason->comp("/comp/linkrelease", id => $id, name => $name, title => $title, strong => 0);
		$mason->out(qq!</td>!);
		if ($showeditlinks)
		{
			$mason->out(qq!<td class="editlinks">!);
			$mason->comp("/comp/linkedits", type => "release", id => $id, explain => 1);
			$mason->out(qq!</td>!);
		}
		$mason->out(qq!</tr>!);	
	}

	# output the track this edit is listed under.
	if (defined $this->{"trackid"})
	{
		my ($id, $name, $title) = ($this->{"trackid"}, $this->{"trackname"}, undef);
		if (not $this->{"exists-track"})
		{
			$name = "This track has been removed" if (not defined $name);
			$title = "This track has been removed, Id: $id";
			$id = -1;
		}
		$mason->out(qq!<tr class="entity"><td class="lbl">Track:</td>!);	
		$mason->out(qq!<td>!);
		$mason->comp("/comp/linktrack", id => $id, name => $name, title => $title, strong => 0);
		$mason->out(qq!</td>!);
		if ($showeditlinks)
		{
			$mason->out(qq!<td class="editlinks">!);
			$mason->comp("/comp/linkedits", type => "track", id => $id, explain => 1);
			$mason->out(qq!</td>!);
		}
		$mason->out(qq!</tr>!);		
	}	
	
	# call delegate method that can be overriden by the edit types
	# to provide additional links to entities.
	$this->ShowModTypeDelegate($mason);
	
	# close the table.
	$mason->out(qq!</table>!);
}

# This method can be overridden by subclasses to display additional rows
# in the table rendered by ShowModType.
sub ShowModTypeDelegate
{
	my ($this, $mason) = (shift, shift);
	
	# do something, or not.
}

sub ShowPreviousValue
{
	my ($this, $mason) = splice(@_, 0, 2);
	my $c = $this->GetComponent($mason);
	$c->call_method("ShowPreviousValue", $this, @_);
}

sub ShowNewValue
{
	my ($this, $mason) = splice(@_, 0, 2);
	my $c = $this->GetComponent($mason);
	$c->call_method("ShowNewValue", $this, @_);
}

################################################################################
# Methods which must be implemented by sub-classes
################################################################################

# (class)
# sub Name { "Remove Disc ID" }

# (instance)
# A moderation is being inserted - perform additional actions here, such as
# actually inserting.  Throw an exception if the arguments are invalid.
# Arguments: %opts, (almost) as passed to Moderation->InsertModeration
# Called in void context
# sub PreInsert;

################################################################################
# Methods intended to be overridden by moderation sub-classes
################################################################################

# PostLoad is called after an object of this class has been instantiated
# and its fields have been set via ->SetPrev, ->SetNew etc.  The class should
# then prepare any internal fields it requires, e.g. parse 'prev' and 'new'
# into various internal fields.  An exception should be thrown if appropriate,
# e.g. if 'prev' or 'new' don't parse as required.  The return value is
# ignored (this method will usually be called in void context).  The default
# action is to do nothing.
# Arguments: none
# Called in void context
sub PostLoad { }

# PreDisplay should be implemented to load additional data that is necessary for
# displaying the moderation in the web interface, so mason scripts can be kept
# clean from data gathering statements.
# It could be used to load the track name that is not stored in moderation tables
# for moderations modifying the track table, for example.
# Arguments: none
# Called in void context
sub PreDisplay { }

# Can this moderation be automatically applied?  (Based on moderation type
# and data, not the moderator). There merely states if the edit can be
# automatically applied -- wether it will or will not be, depends on the data
# quality setting for the artist/release in question.
# Arguments: $isautoeditor (boolean)
# Called in boolean context; return true to automod this moderation
sub IsAutoEdit { 0 }

# Adjust the appropriate "modpending" flags.  $adjust is guaranteed to be
# either +1 (add one pending mod) or -1 (subtract one).
# Arguments: $adjust (guaranteed to be either +1 or -1)
# Called in void context
# TODO remove this implementation; leave each handler to implement it
# themselves.
sub AdjustModPending
{
	my ($this, $adjust) = @_;
	my $table = lc $this->table;

	if ($table ne 'trm')
	{
		my $sql = Sql->new($this->{DBH});
		$sql->Do(
			"UPDATE $table SET modpending = modpending + ? WHERE id = ?",
			$adjust,
			$this->row_id,
		);
	}
}

# Determine the current quality level that should be applied to this edit.
# The subclasses will need to determine if an edit is an artist edit or
# a release edit and then look up the quality for that entity and
# return it from this function. This causes the quality for an edit
# to be considered every time the ModBot examines it.
sub DetermineQuality { ModDefs::QUALITY_NORMAL };

# Determine if a change quality edit is going up (1) or down (0)
sub GetQualityChangeDirection { 1 }; # default to up, which is more strict

# Check the moderation to see if it can still be applied, e.g. that all the
# prerequisites and other dependencies are still OK.  If all is well, return
# "undef".  Otherwise, return one of the "bad" STATUS_* codes (e.g.
# STATUS_FAILEDPREREQ).  You might want to add a note using
# $self->InsertNote(MODBOT_MODERATOR, $message) too.  Either way the
# transaction will be committed if possible.
# Arguments: none
# Called in scalar context; returns &ModDefs::STATUS_* or undef.
sub CheckPrerequisites { undef }

# The moderation has been approved - either immediately (automod), or voted
# in.  Either throw an exception (in which case the transaction will be rolled
# back), or do whatever work is necessary and return &ModDefs::STATUS_* (in
# which case the transaction will probably be committed).
# Arguments: none
# Called in scalar context; returns &ModDefs::STATUS_*
sub ApprovedAction { &ModDefs::STATUS_APPLIED }

# The moderation is to be undone (voted down, failed a test, or was deleted)
# Arguments: none
# Called in void context
sub DeniedAction { () }

################################################################################
# Utility methods for moderation handlers
################################################################################

# If a mod handler wants to insert another moderation before itself, it just
# calls ->InsertModeration as an instance method, passing %opts as normal.  It
# doesn't need to specify the DBH, uid or privs options though.  The return
# value of ->InsertModeration can be ignored too, if you like.

# If a mod handler wants another moderation to be inserted after itself, it
# calls ->PushModeration, with the same arguments as for a nested call to
# ->InsertModeration (see above).  Nothing special is returned.
sub PushModeration
{
	my ($self, %opts) = @_;
	push @{ $self->{pushed_moderations} }, \%opts;
}

# If a mod handler wants to suppress insertion of itself (for example, maybe
# because it called ->InsertModeration or ->PushModeration to generate a
# replacement moderation), it calls ->SuppressInsert (no arguments, and no
# special return value).
sub SuppressInsert
{
	my $self = shift;
	$self->{suppress_insert} = 1;
}

sub ConvertNewToHash
{
	my ($this, $nw) = @_;
	my %kv;

	for (split /\n/, $nw)
	{
	   	my ($k, $v) = split /=/, $_, 2;
		return undef unless defined $v;
		$kv{$k} = $this->_decode_value($v);
	}

	\%kv;
}

sub ConvertHashToNew
{
	my ($this, $kv) = @_;

	my @undef_keys = grep { not defined $kv->{$_} } keys %$kv;
	carp "Uninitialized value(s) @undef_keys passed to ConvertHashToNew"
		if @undef_keys;

	join "\n", map {
		my $k = $_;
		$k . '=' . $this->_encode_value($kv->{$k});
	} sort keys %$kv;
}

use URI::Escape qw( uri_escape uri_unescape );

sub _encode_value
{
	return $_[1] unless $_[1] =~ /[\x00-\x1F\x7F]/;
	"\x1BURI;" . uri_escape($_[1], '\x00-\x1F\x7F%');
}

sub _decode_value
{
	my ($scheme, $data) = $_[1] =~ /\A\x1B(\w+);(.*)\z/s
		or return $_[1];
	return uri_unescape($data) if $scheme eq "URI";
	die "Unknown encoding scheme '$scheme'";
}

sub _normalise_strings
{
	my $this = shift;

	my @r = map {
		# Normalise to lower case
		my $t = lc decode("utf-8", $_);

		# Remove leading and trailing space
		$t =~ s/\A\s+//;
		$t =~ s/\s+\z//;

		# Compress whitespace
		$t =~ s/\s+/ /g;

		# So-called smart quotes; in reality, a backtick and an acute accent.
		# Also double-quotes and angled double quotes.
		$t =~ tr/\x{0060}\x{00B4}"\x{00AB}\x{00BB}/'/;

		# Unaccent what's left
		$t = decode("utf-8", unaccent(encode("utf-8", $t)));

		$t;
	} @_;

	wantarray ? @r : $r[-1];
}

1;
# vi: set ts=4 sw=4 :
