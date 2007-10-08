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

package MusicBrainz::Server::Moderation::MOD_MERGE_ALBUM;

# NOTE!  This module also handles MOD_MERGE_ALBUM_MAC

use ModDefs qw( :modstatus MODBOT_MODERATOR MOD_MERGE_ALBUM_MAC );
use base 'Moderation';

sub Name { "Merge Releases" }
(__PACKAGE__)->RegisterHandler;

sub PreInsert
{
	my ($self, %opts) = @_;

	my $albums = $opts{'albums'} or die;
	my $into = $opts{'into'} or die;

	my @albums = ($into, @$albums);
	
	# Sanity check: all the albums must be unique
	my %seen;

	for (@albums)
	{
		die "Release #" . ($_->GetId) . " passed twice to " . $self->Token
			if $seen{$_->GetId}++;
	}

	my %new = (
		map {
			(
				"AlbumId$_"		=> $albums[$_]->GetId,
				"AlbumName$_"	=> $albums[$_]->GetName,
			)
		} 0 .. $#albums
	);

	$new{"merge_attributes"} = 1 if $opts{"merge_attributes"};
	$new{"merge_langscript"} = 1 if $opts{"merge_langscript"};

	$self->SetArtist($into->GetArtist);
	$self->SetTable("album");
	$self->SetColumn("id");
	$self->SetRowId($into->GetId);
	$self->SetNew($self->ConvertHashToNew(\%new));
}

sub PostLoad
{
	my $self = shift;

	my $new = $self->{'new_unpacked'} = $self->ConvertNewToHash($self->GetNew)
		or die;

	my $into = $self->{'new_into'} = {
		id => $new->{"AlbumId0"},
		name => $new->{"AlbumName0"},
	};

	$into->{"id"} or die;

	my @albums;

	for (my $i=1; ; ++$i)
	{
		my $id = $new->{"AlbumId$i"}
			or last;
		my $name = $new->{"AlbumName$i"};
		defined($name) or last;

		push @albums, { id => $id, name => $name };
	}

	$self->{'new_albums'} = \@albums;
	$self->{'merge_attributes'} = $new->{'merge_attributes'};
	$self->{'merge_langscript'} = $new->{'merge_langscript'};
	@albums or die;
}

sub DetermineQuality
{
	my $self = shift;

	my $new = $self->{'new_unpacked'} = $self->ConvertNewToHash($self->GetNew)
		or die;

    my $quality = &ModDefs::QUALITY_UNKNOWN_MAPPED;
    my $artistid = -1;
    for(my $i = 0;;$i++)
    {
        my $rel = Album->new($self->{DBH});
        last if (!exists $new->{"AlbumId$i"});
        $rel->SetId($new->{"AlbumId$i"});
        if ($rel->LoadFromId())
        {
            $artistid = $rel->GetArtist() if ($artistid < 0);
            $quality = $rel->GetQuality() > $quality ? $rel->GetQuality() : $quality;
        }
    }

    if ($artistid > 0)
    {
        # Check the artist its going to
        my $ar = Artist->new($self->{DBH});
        $ar->SetId($artistid);
        if ($ar->LoadFromId())
        {
            $quality = $ar->GetQuality() > $quality ? $ar->GetQuality() : $quality;
        }
    }

    if ($quality < 0)
    {
        print STDERR __PACKAGE__ . ": quality not determined for $self->{id}\n";
        $quality = &ModDefs::QUALITY_NORMAL;
    }
    return $quality;
}

sub AdjustModPending
{
	my ($self, $adjust) = @_;
	require Album;
	my $al = Album->new($self->{DBH});

	# Prior to the ModerationClasses2 branch, the "mod pending" change would
	# only be applied to the album listed in $self->GetRowId, i.e. the target
	# of the merge (here referred to as the "into" album).
	# Now though we apply the modpending change to all affected albums.

	for my $album ($self->{'new_into'}, @{ $self->{'new_albums'} })
	{
		$al->SetId($album->{'id'});
		$al->UpdateModPending($adjust);
	}
}

sub ApprovedAction
{
 	my $self = shift;

	require Album;
	my $al = Album->new($self->{DBH});
	$al->SetId($self->{'new_into'}{'id'});

	unless ($al->LoadFromId)
	{
		$self->InsertNote(MODBOT_MODERATOR, "This release has been deleted");
		return STATUS_FAILEDPREREQ;
	}

    $al->SetVerticalDatabaseConnection($self->GetVerticalDatabaseConnection);
	$al->MergeAlbums({
		mac => ($self->GetType == MOD_MERGE_ALBUM_MAC),
		albumids => [ map { $_->{'id'} } @{ $self->{'new_albums'} } ],
		merge_attributes => $self->{'merge_attributes'},
		merge_langscript => $self->{'merge_langscript'}
	});
					
	STATUS_APPLIED;
}

1;
# eof MOD_MERGE_ALBUM.pm
