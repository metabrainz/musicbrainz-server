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

package MusicBrainz::Server::Moderation::MOD_MAC_TO_SAC;

use ModDefs qw( :modstatus MODBOT_MODERATOR VARTIST_ID );
use base 'Moderation';

sub Name { "Convert Album to Single Artist" }
(__PACKAGE__)->RegisterHandler;

# PLEASE NOTE that MOD_MOVE_ALBUM is almost exactly the same as MOD_MAC_TO_SAC

sub PreInsert
{
	my ($self, %opts) = @_;

	my $al = $opts{album} or die;
	my $sortname = $opts{artistsortname} or die;
	my $name = $opts{artistname};

	my $new = $sortname;
	$new .= "\n$name" if defined $name and $name =~ /\S/;

	$self->SetTable("album");
	$self->SetColumn("artist");
	$self->SetArtist($al->GetArtist);
	$self->SetRowId($al->GetId);
	$self->SetNew($new);
}

sub PostLoad
{
	my $this = shift;

	# new.name might be undef (in which case, name==sortname)
  	@$this{qw( new.sortname new.name )} = split /\n/, $this->GetNew;
}

sub CheckPrerequisites
{
	my $self = shift;

	my $rowid = $self->GetRowId;

	# Load the album by ID
	my $al = Album->new($self->{DBH});
	$al->SetId($rowid);
	unless ($al->LoadFromId)
	{
		$self->InsertNote(MODBOT_MODERATOR, "This album has been deleted");
		return STATUS_FAILEDDEP;
	}

	# Check that its artist has not changed
	if ($al->GetArtist != VARTIST_ID)
	{
		$self->InsertNote(MODBOT_MODERATOR, "This album has already been converted to a single artist");
		return STATUS_FAILEDPREREQ;
	}

	undef;
}

sub ApprovedAction
{
	my $this = shift;
	my $sql = Sql->new($this->{DBH});

	my $status = $this->CheckPrerequisites;
	return $status if $status;

	# Find the ID of the named artist
	my $name = $this->{'new.name'};
	$name = $this->{'new.sortname'}
		unless defined $name;

	my $newid = $sql->SelectSingleValue(
		"SELECT id FROM artist WHERE name = ?",
		$name,
	);

	if (not defined $newid)
	{
		# No such artist, so create one
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
			) or die "Failed to update track #$row[0] in MOD_MAC_TO_SAC";
		}

		$sql->Finish;
	}

	# Move the album itself

	$sql->Do(
		"UPDATE album SET artist = ? WHERE id = ?",
		$newid,
		$this->GetRowId,
	) or die "Failed to update artist in MOD_MAC_TO_SAC";

	STATUS_APPLIED;
}

1;
# eof MOD_MAC_TO_SAC.pm
