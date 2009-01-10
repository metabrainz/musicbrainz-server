#!/usr/bin/perl -w
# vi: set ts=4 sw=4 :
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

use strict;

package MusicBrainz::Server::Moderation::MOD_MOVE_RELEASE;

use ModDefs qw( :modstatus MODBOT_MODERATOR );
use base 'Moderation';

sub Name { "Move Release" }
(__PACKAGE__)->RegisterHandler;

# PLEASE NOTE that MOD_MOVE_RELEASE is almost exactly the same as MOD_MAC_TO_SAC

sub PreInsert
{
	my ($self, %opts) = @_;

	my $release = $opts{album} or die;
	my $artist = $opts{oldartist} or die;
	my $sortname = $opts{artistsortname} or die;
	my $name = $opts{artistname};
	my $artistid = $opts{artistid};
	my $movetracks = $opts{movetracks} || 0;
	
	my $new = $sortname;
	$new .= "\n$name" if defined $name and $name =~ /\S/;
	$new .= "\n$artistid";
	$new .= "\n$movetracks";
	
	$self->table("album");
	$self->column("artist");
	$self->artist($release->artist);
	$self->row_id($release->id);
	$self->previous_data($artist->name);
	$self->new_data($new);
}

sub PostLoad
{
	my $this = shift;

	# new.name might be undef (in which case, name==sortname)
  	@$this{qw( new.sortname new.name new.artistid new.movetracks)} = split /\n/, $this->new_data;

    # If the name was blank and the new artist id ended up in its slot, swap the two values
	if ($this->{'new.name'} =~ /^\d+$/ && !defined $this->{'new.artistid'})
	{
		$this->{'new.movetracks'} = $this->{'new.artistid'};
		$this->{'new.artistid'} = $this->{'new.name'};
		$this->{'new.name'} = undef;
	}
	
	# verify if release still exists in Moderation.ShowModType method.
	($this->{"albumid"}, $this->{"checkexists-album"}) = ($this->row_id, 1);			
}

sub DetermineQuality
{
	my $self = shift;

    my $level = &ModDefs::QUALITY_UNKNOWN_MAPPED;

	my $rel = MusicBrainz::Server::Release->new($self->GetDBH);
	$rel->id($self->{rowid});
	if ($rel->LoadFromId())
	{
		$level = $rel->quality > $level ? $rel->quality : $level;
    }

	my $ar = MusicBrainz::Server::Artist->new($self->GetDBH);
	$ar->id($rel->artist);
	if ($ar->LoadFromId())
	{
        $level = $ar->quality > $level ? $ar->quality : $level;
    }

	$ar = MusicBrainz::Server::Artist->new($self->GetDBH);
	$ar->id($self->{'new.artistid'});
	if ($ar->LoadFromId())
	{
        $level = $ar->quality > $level ? $ar->quality : $level;
    }

    return $level;
}

sub PreDisplay
{
	my $this = shift;

	# flag indicates: new artist already in DB
	$this->{'new.exists'} = (defined $this->{'new.artistid'} && $this->{'new.artistid'} > 0);

	# fix unset movetracks flag
	$this->{'new.movetracks'} = 1 
		unless (defined $this->{'new.movetracks'});
		
	my $newartist;		
	# load album name
	require MusicBrainz::Server::Release;
	my $release = MusicBrainz::Server::Release->new($this->GetDBH);
	$release->id($this->row_id);
	if ($release->LoadFromId)
	{
		$this->{'albumname'} = $release->name;

		# make sure new artist really doesn't exist; old mods only had 
		# the artist sortname (or name?) in 'prevvalue'
		if (!$this->{'new.exists'})
		{
			require MusicBrainz::Server::Artist;
			$newartist = MusicBrainz::Server::Artist->new($this->GetDBH);
			$newartist->id($release->artist);
				
			# FIXME is the name = new.sortname comparison necessary?
			if ($newartist->LoadFromId 
				&& ($newartist->name eq $this->{'new.sortname'}
					|| $newartist->sort_name eq $this->{'new.sortname'}))
			{
				# assume we got the right artist, and reset name and sortname
				# to the correct values
				$this->{'new.name'} = $newartist->name;
				$this->{'new.sortname'} = $newartist->sort_name;
				$this->{'new.exists'} = 1;
			}
		}
	}

	# load artist resolutions if new and old artist have the same name
	my $pat = $this->previous_data;
	if ($this->{'new.name'} =~ /^\Q$pat\E$/i)
	{
		my $oar = MusicBrainz::Server::Artist->new($this->GetDBH);
		# the old one ...
		$oar->id($this->artist);
		$oar->LoadFromId
			and $this->{'old.res'} = $oar->resolution;

		# ... and the new resolution if artist is in the DB
		# TODO what if new artist with res is created with this mod?
		#      (see also MOD_CHANGE_TRACK_ARTIST)
		require MusicBrainz::Server::Artist;
		if ($this->{'new.exists'})
		{
			if (!defined $newartist) {
				$newartist = MusicBrainz::Server::Artist->new($this->GetDBH);
				$newartist->id($this->{'new.artistid'});
				$newartist->LoadFromId;
			}
			my $res = $newartist->resolution;
			$this->{'new.res'} = ($res eq '' ? undef : $res);
		}
	}
}

sub CheckPrerequisites
{
	my $self = shift;

	if (my $id = $self->{'new.artistid'})
	{
		require MusicBrainz::Server::Artist;
		my $artist = MusicBrainz::Server::Artist->new($self->GetDBH);
		$artist->id($id);
		unless ($artist->LoadFromId)
		{
			$self->InsertNote(MODBOT_MODERATOR, "This artist has been deleted");
			return STATUS_FAILEDPREREQ;
		}
	}

	return undef;
}

sub ApprovedAction
{
	my $this = shift;
	my $sql = Sql->new($this->GetDBH);

	# Check album is still where it used to be
	$sql->SelectSingleValue(
		"SELECT 1 FROM album WHERE id = ? AND artist = ?",
		$this->row_id,
		$this->artist,
	) or do {
		$this->InsertNote(MODBOT_MODERATOR, "This release has already been deleted or moved");
		return STATUS_FAILEDPREREQ;
	};

	my $newid;
	my $name = $this->{'new.name'};
	if (defined $this->{'new.artistid'}) 
	{
        $newid = $this->{'new.artistid'};
	}
	else
	{
		# Find the ID of the named artist
		$name = $this->{'new.sortname'}
			unless defined $name;

	    # This is for old (open) moderations before the AR release move album fix goes int.
        # The idea is to prefer artists with lower ids, since they were added first (when
        # artist names were still unique.
		my $ids = $sql->SelectSingleColumnArray(
			"SELECT id FROM artist WHERE name = ? order by artist.id",
			$name,
		);
		$newid = $ids->[0];
    }
	if (not defined($newid) or $newid == -1) # huh?
	{
		# No such artist, so create one
		require MusicBrainz::Server::Artist;
		my $artist = MusicBrainz::Server::Artist->new($this->GetDBH);
		$artist->name($name);
		$artist->sort_name($this->{'new.sortname'});
		$newid = $artist->Insert(no_alias => 1);
	}

  	# Move each track on the album, if the user 
	# choose to do so.
	if ($this->{'new.movetracks'}) 
	{
		if ($sql->Select("SELECT track FROM albumjoin WHERE album = ?",
				$this->row_id))
		{
			while (my @row = $sql->NextRow)
			{
				$sql->Do(
					"UPDATE track SET artist = ? WHERE id = ?",
					$newid,
					$row[0],
				);
			}
		}
		$sql->Finish;
	}

	# Move the album itself

	$sql->Do(
		"UPDATE album SET artist = ? WHERE id = ?",
		$newid,
		$this->row_id,
	);

	STATUS_APPLIED;
}

1;
# eof MOD_MOVE_RELEASE.pm
