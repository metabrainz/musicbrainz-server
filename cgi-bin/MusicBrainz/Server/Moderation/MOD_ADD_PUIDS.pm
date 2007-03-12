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

package MusicBrainz::Server::Moderation::MOD_ADD_PUIDS;

use ModDefs;
use base 'Moderation';

sub Name { "Add PUIDs" }
(__PACKAGE__)->RegisterHandler;

sub PreInsert
{
	my ($self, %opts) = @_;

	my $client = $opts{'client'} or die;
	my $links = $opts{'links'} or die;

	$self->SetTable('PUID');
	$self->SetColumn('puid');

	my $new = "ClientVersion=$client\n";

	my $i = 0;
	for (@{ $links })
	{
		my $puid = $_->{puid} or die;
		my $trackid = $_->{trackid} or die;
		$new .= "PUID$i=$puid\n"
			. "TrackId$i=$trackid\n";
		++$i;
	}

	$self->SetNew($new);
}

sub PostLoad
{
	my $self = shift;

	my $new = $self->{'new_unpacked'} = $self->ConvertNewToHash($self->GetNew)
		or die;

	my @list;

	for (my $i=0; ; ++$i)
	{
		my $puid = $new->{"PUID$i"} or last;
		my $trackid = $new->{"TrackId$i"} or last;
		push @list, { puid => $puid, trackid => $trackid };
	}

	$self->{'new_list'} = \@list;
}

sub DetermineQuality
{
    my $self = shift;

	my $new = $self->{'new_unpacked'} = $self->ConvertNewToHash($self->GetNew)
		or die;

    # Attempt to find the right release this track is attached to.
    my $tr = Track->new($self->{DBH});
    $tr->SetId($new->{"TrackId"});
    if ($tr->LoadFromId())
    {
        my $rel = Album->new($self->{DBH});
        $rel->SetId($tr->GetAlbum());
        if ($rel->LoadFromId())
        {
            return $rel->GetQuality();        
        }
    }

    # if that fails, go by the artist
    my $ar = Artist->new($self->{DBH});
    $ar->SetId($tr->GetArtist());
    if ($ar->LoadFromId())
    {
        return $ar->GetQuality();        
    }

    print STDERR __PACKAGE__ . ": quality not determined for $self->{id}\n";
    return &ModDefs::QUALITY_NORMAL;
}

sub ApprovedAction
{
	my $self = shift;

	require PUID;
	my $PUID = PUID->new($self->{DBH});
	my $clientVersion = $self->{'new_unpacked'}{'ClientVersion'};

	for (@{ $self->{'new_list'} })
	{
		$PUID->Insert(
			$_->{'puid'},
			$_->{'trackid'},
			$clientVersion,
		);
	}

	&ModDefs::STATUS_APPLIED;
}

1;
# eof MOD_ADD_PUIDS.pm
