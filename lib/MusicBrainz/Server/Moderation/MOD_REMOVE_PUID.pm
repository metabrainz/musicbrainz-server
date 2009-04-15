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

package MusicBrainz::Server::Moderation::MOD_REMOVE_PUID;

use ModDefs;
use base 'Moderation';

use MusicBrainz::Server::PUID;

sub Name { "Remove PUID" }
(__PACKAGE__)->RegisterHandler;

sub PreInsert
{
	my ($self, %opts) = @_;

	my $track = $opts{'track'} or die;
	my $puid = $opts{'puid'} or die;
	my $puidjoinid = $opts{'puidjoinid'} or die;

	$self->table("puidjoin");
	$self->column("id");
	$self->row_id($puidjoinid);
	$self->artist($track->artist->id);
	$self->previous_data($puid->puid);

	# Save the PUID's clientversion in case we need to re-add it
	my $clientversion = $puid->client_version;

	my %new = (
		TrackId => $track->id,
		ClientVersion => $clientversion,
	);

	$self->new_data($self->ConvertHashToNew(\%new));

	# This is one of those mods where we give the user instant gratification,
	# then undo the mod later if it's rejected.
	$puid->remove_instance($self->row_id);
}

sub PostLoad
{
	my $self = shift;
	$self->{'new_unpacked'} = $self->ConvertNewToHash($self->new_data)
		or die;
		
	my $new = $self->{'new_unpacked'};
	($self->{"albumid"}, $self->{"checkexists-album"}) = (undef, 1);
	($self->{"trackid"}, $self->{"checkexists-track"}) = ($new->{'TrackId'}, 1);	
}

sub DetermineQuality
{
    my $self = shift;

    # Attempt to find the right release this track is attached to.
    my $tr = MusicBrainz::Server::Track->new($self->dbh);
    $tr->id($self->{"trackid"});
    if ($tr->LoadFromId())
    {
        my $rel = MusicBrainz::Server::Release->new($self->dbh);
        $rel->id($tr->release());
        if ($rel->LoadFromId())
        {
            return $rel->quality;        
        }
    }

    # if that fails, go by the artist
    my $ar = $tr->artist;
    if ($ar->LoadFromId())
    {
        return $ar->quality;        
    }

    return &ModDefs::QUALITY_NORMAL;
}

sub AdjustModPending { () }

sub ApprovedAction
{
	&ModDefs::STATUS_APPLIED;
}

sub DeniedAction
{
	my $self = shift;
	my $new = $self->{'new_unpacked'};

	my $trackid = $new->{'TrackId'}
		or return;

	require MusicBrainz::Server::Track;
	my $track = MusicBrainz::Server::Track->new($self->dbh);
	$track->id($trackid);
	unless ($track->LoadFromId)
	{
		$self->InsertNote(
			&ModDefs::MODBOT_MODERATOR,
			"This track has been deleted",
		);
		return;
	}

	my $t = MusicBrainz::Server::PUID->new($self->dbh);
	my $id = $t->insert($self->previous_data, $trackid, $new->{'ClientVersion'});

	# The above Insert can fail, usually if the row in the "puid" table
	# needed to be re-inserted but we neglected to save the clientversion
	# before it was deleted (i.e. mods inserted before this bug was
	# fixed).
	if (not $id)
	{
		$self->InsertNote(
			&ModDefs::MODBOT_MODERATOR,
			"Unable to re-insert PUID",
		);
	}
}

1;
# eof MOD_REMOVE_PUID.pm
