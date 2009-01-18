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

package MusicBrainz::Server::Moderation::MOD_MAC_TO_SAC;

use ModDefs qw( :modstatus MODBOT_MODERATOR VARTIST_ID );
use base 'Moderation';
use Carp;

sub Name { "Convert Release to Single Artist" }
(__PACKAGE__)->RegisterHandler;

# PLEASE NOTE that MOD_MOVE_RELEASE is almost exactly the same as MOD_MAC_TO_SAC

sub PreInsert
{
	my ($self, %opts) = @_;

	my $al = $opts{album} or die;
	my $sortname = $opts{artistsortname} or die;
	my $name = $opts{artistname};
    my $artistid = $opts{artistid};
    my $movetracks = $opts{movetracks};

	my $new = $sortname;
	$new .= "\n$name" if defined $name and $name =~ /\S/;
    $new .= "\n$artistid";
    $new .= "\n$movetracks";

	$self->table("album");
	$self->column("artist");
	$self->artist($al->artist);
	$self->row_id($al->id);
	$self->new_data($new);
}

sub PostLoad
{
	my $self = shift;

	# new.name might be undef (in which case, name==sortname)
  	@$self{qw( new.sortname new.name new.artistid new.movetracks)} = split /\n/, $self->new_data;

    # If the name was blank and the new artist id ended up in its slot, swap the two values
    if ($self->{'new.name'} =~ /\A\d+\z/ && !defined $self->{'new.artistid'})
    {
        $self->{'new.movetracks'} = $self->{'new.artistid'};
        $self->{'new.artistid'} = $self->{'new.name'};
        $self->{'new.name'} = undef;
    }

	# attempt to load the release entitiy from the value
	# stored in this edit type. (@see Moderation::ShowModType)
	($self->{"albumid"}, $self->{"checkexists-album"}) = ($self->row_id, 1);  
}

sub DetermineQuality
{
	my $self = shift;

	my $level = &ModDefs::QUALITY_UNKNOWN_MAPPED;

	my $rel = MusicBrainz::Server::Release->new($self->dbh);
	$rel->id($self->{rowid});
	if ($rel->LoadFromId())
	{
		$level = $rel->quality > $level ? $rel->quality : $level;
    }

    # Check the artist its going to
	my $ar = MusicBrainz::Server::Artist->new($self->dbh);
	$ar->id($self->{'new.artistid'});
	if ($ar->LoadFromId())
	{
        $level = $ar->quality > $level ? $ar->quality : $level;
    }

    return $level;
}

sub PreDisplay
{
    my $self = shift;

    my $artist = new MusicBrainz::Server::Artist($self->{dbh});
    $artist->name($self->{'new.name'});
    $artist->sort_name($self->{'new.sortvalue'});
    $artist->id($self->{'new.artistid'});

    if (defined $self->{'new.artistid'} && $self->{'new.artistid'} > 0)
    {
        $artist->LoadFromId;
    }

    $self->new_data($artist);
}

sub CheckPrerequisites
{
	my $self = shift;

	my $rowid = $self->row_id;

	# Load the album by ID
	require MusicBrainz::Server::Release;
	my $al = MusicBrainz::Server::Release->new($self->dbh);
	$al->id($rowid);
	unless ($al->LoadFromId)
	{
		$self->InsertNote(MODBOT_MODERATOR, "This release has been deleted");
		return STATUS_FAILEDDEP;
	}

	# album needs to have more than one track artist
	# if it is not VA to allow a SA-conversion
	if ($al->artist != VARTIST_ID and 
		not $al->has_multiple_track_artists)
	{
		$self->InsertNote(MODBOT_MODERATOR, "This release has already been converted to a single artist");
		return STATUS_FAILEDPREREQ;
	}

	undef;
}

sub ApprovedAction
{
	my $this = shift;
	my $sql = Sql->new($this->dbh);

	my $status = $this->CheckPrerequisites;
	return $status if $status;

    my $newid;
    my $name = $this->{'new.name'};
    my $movetracks = $this->{'new.movetracks'};
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

	if (not defined $newid)
	{
		# No such artist, so create one
		require MusicBrainz::Server::Artist;
		my $ar = MusicBrainz::Server::Artist->new($this->dbh);
		$ar->name($name);
		$ar->sort_name($this->{'new.sortname'});
		$newid = $ar->Insert(no_alias => 1);
		$newid or croak "Failed to create artist $name / $this->{'new.sortname'}";
	}

	# Move each track on the album
    if ($movetracks)
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
                ) or die "Failed to update track #$row[0] in MOD_MAC_TO_SAC";
            }

        }
        $sql->Finish;
    }

	# Move the album itself
	$sql->Do(
		"UPDATE album SET artist = ? WHERE id = ?",
		$newid,
		$this->row_id,
	) or die "Failed to update artist in MOD_MAC_TO_SAC";

	STATUS_APPLIED;
}

1;
# eof MOD_MAC_TO_SAC.pm
