#!/home/httpd/musicbrainz/mb_server/cgi-bin/perl -w
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

package MusicBrainz::Server::Moderation::MOD_MOVE_ALBUM;

use ModDefs qw( :modstatus MODBOT_MODERATOR );
use base 'Moderation';

sub Name { "Move Album" }
(__PACKAGE__)->RegisterHandler;

# PLEASE NOTE that MOD_MOVE_ALBUM is almost exactly the same as MOD_MAC_TO_SAC

sub PreInsert
{
	my ($self, %opts) = @_;

	my $al = $opts{album} or die;
	my $ar = $opts{oldartist} or die;
	my $sortname = $opts{artistsortname} or die;
	my $name = $opts{artistname};
	my $artistid = $opts{artistid};

	my $new = $sortname;
	$new .= "\n$name" if defined $name and $name =~ /\S/;
	$new .= "\n$artistid";

	$self->SetTable("album");
	$self->SetColumn("artist");
	$self->SetArtist($al->GetArtist);
	$self->SetRowId($al->GetId);
	$self->SetPrev($ar->GetName);
	$self->SetNew($new);
}

sub PostLoad
{
	my $this = shift;

	# new.name might be undef (in which case, name==sortname)
  	@$this{qw( new.sortname new.name new.artistid)} = split /\n/, $this->GetNew;

    # If the name was blank and the new artist id ended up in its slot, swap the two values
	if ($this->{'new.name'} =~ /\d+/ && !defined $this->{'new.artistid'})
	{
		$this->{'new.artistid'} = $this->{'new.name'};
		$this->{'new.name'} = undef;
	}
}

sub ApprovedAction
{
	my $this = shift;
	my $sql = Sql->new($this->{DBH});

	# Check album is still where it used to be
	$sql->SelectSingleValue(
		"SELECT 1 FROM album WHERE id = ? AND artist = ?",
		$this->GetRowId,
		$this->GetArtist,
	) or do {
		$this->InsertNote(MODBOT_MODERATOR, "This album has already been deleted or moved");
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
	if (not defined $newid)
	{
		# No such artist, so create one
		require Artist;
		my $ar = Artist->new($this->{DBH});
		$ar->SetName($name);
		$ar->SetSortName($this->{'new.sortname'});
		$newid = $ar->Insert(no_alias => 1);
	}
    
	# Move each track on the album

	if ($sql->Select("SELECT track FROM albumjoin WHERE album = ?",
			$this->GetRowId))
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

	# Move the album itself

	$sql->Do(
		"UPDATE album SET artist = ? WHERE id = ?",
		$newid,
		$this->GetRowId,
	);

	STATUS_APPLIED;
}

1;
# eof MOD_MOVE_ALBUM.pm
