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

package MusicBrainz::Server::Moderation::MOD_REMOVE_RELEASES;

use ModDefs;
use base 'Moderation';

sub Name { "Remove Releases" }
(__PACKAGE__)->RegisterHandler;

sub PreInsert
{
	my ($self, %opts) = @_;

	my $albums = $opts{'albums'} or die;

	unless (@$albums)
	{
		require Carp;
		Carp::cluck("MOD_REMOVE_RELEASES called with empty releases list");
		$self->SuppressInsert;
		return;
	}
	
	my %new;
	my %artists;
	
	for my $seq (0 .. $#$albums)
	{
		my $al = $albums->[$seq];
		$new{"AlbumId$seq"} = $al->id;
		$new{"AlbumName$seq"} = $al->name;
		++$artists{$al->artist};
	}

	$self->artist(
		keys(%artists) > 1
			? &ModDefs::VARTIST_ID
			: $albums->[0]->artist
	);
	$self->table("album");
	$self->column("id");
	$self->row_id($albums->[0]->id); # misleading
	$self->new_data($self->ConvertHashToNew(\%new));
}

sub PostLoad
{
	my $self = shift;

	my $new = $self->{'new_unpacked'} = $self->ConvertNewToHash($self->new_data)
		or die;

	my @albums;

	for (my $i=0; ; ++$i)
	{
		my $id = $new->{"AlbumId$i"}
			or last;
		my $name = $new->{"AlbumName$i"};
		defined($name) or last;

		push @albums, { id => $id, name => $name };
	}

	$self->{'new_albums'} = \@albums;
}

sub DetermineQuality
{
	my $self = shift;

    # Take the quality level from the first release or set to normal for multiple releases
    my $quality_level = &ModDefs::QUALITY_NORMAL;
    my $new_albums = $self->{new_albums};
    if (scalar(@$new_albums) == 1)
    {
        my $rel = MusicBrainz::Server::Release->new($self->GetDBH);
        $rel->id($new_albums->[0]->{id});
        if ($rel->LoadFromId())
        {
            $quality_level = $rel->quality;        
        }
    }
    return $quality_level;
}

sub AdjustModPending
{
	my ($self, $adjust) = @_;
	require MusicBrainz::Server::Release;
	my $al = MusicBrainz::Server::Release->new($self->GetDBH);

	for my $t (@{ $self->{'new_albums'} })
	{
		$al->id($t->{'id'});
		$al->UpdateModPending($adjust);
	}
}

sub ApprovedAction
{
	my $self = shift;
	require MusicBrainz::Server::Release;
 	my $al = MusicBrainz::Server::Release->new($self->GetDBH);

	for my $t (@{ $self->{'new_albums'} })
	{
		$al->id($t->{'id'});
		$al->Remove;
	}

	&ModDefs::STATUS_APPLIED;
}

1;
# eof MOD_REMOVE_RELEASES.pm
