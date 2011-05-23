#!/usr/bin/env perl

use warnings;
# vi: set ts=4 sw=4 :
#____________________________________________________________________________
#
#   MusicBrainz -- the open internet music database
#
#   Copyright (C) 1998 Robert Kaye
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

use FindBin;
use lib "$FindBin::Bin/../../lib";

use strict;
use warnings;

package TracksNamedWithSequence;
use base qw( MusicBrainz::Server::ReportScript );

use MusicBrainz::Server::Validation;
use Encode qw( decode );
use MusicBrainz::Server::Release;
use MusicBrainz::Server::Artist;

sub GatherData
{
    my $self = shift;

    $self->Log("Querying database");
    my $sql = $self->SqlObj;

    my $data = $sql->SelectListOfLists("
        SELECT 
                a.artist, 
                j.album, 
                t.id, 
                j.sequence, 
                t.name
        FROM 
                track t, albumjoin j, album a
        WHERE 
                j.track = t.id
                AND  a.id = j.album
                AND t.name ~ '^[0-9]'
                AND t.name ~ ('^0*' || j.sequence || '[^0-9]')
        ORDER BY 
                a.artist, j.album, j.sequence
    ");

    # Index the tracks by album-artist, album:

    my $artists = {};

    for (@$data)
    {
        push @{ $artists->{ $_->[0] }{ALBUMS}{ $_->[1] }{TRACKS} }, $_;
    }

    my $al = MusicBrainz::Server::Release->new($self->{dbh});
    my $ar = MusicBrainz::Server::Artist->new($self->{dbh});

    for my $artistid (keys %$artists)
    {
        my $albums = $artists->{$artistid}{ALBUMS};

        # Remove albums with two or fewer tracks like this
        for my $albumid (keys %$albums)
        {
                delete $albums->{$albumid}, next
                        if @{ $albums->{$albumid}{TRACKS} } <= 2;

                $al->SetId($albumid);
                $al->LoadFromId;

                $albums->{$albumid}{ID} = $albumid;
                $albums->{$albumid}{NAME} = $al->GetName;
                $albums->{$albumid}{_sort_} = MusicBrainz::Server::Validation::NormaliseSortText($al->GetName);
        }

        # Remove the artists if we've removed all their albums
        delete $artists->{$artistid}, next
                unless keys %$albums;

        $ar->SetId($artistid);
        $ar->LoadFromId;

        $artists->{$artistid}{ID} = $artistid;
        $artists->{$artistid}{NAME} = $ar->GetName;
        $artists->{$artistid}{_sort_} = MusicBrainz::Server::Validation::NormaliseSortText($ar->GetSortName);
    }

    $self->Log("Saving results");
    my $report = $self->PagedReport;

    for my $artist (sort { $a->{_sort_} cmp $b->{_sort_} } values %$artists)
    {
        $report->Print($artist);
    }
}

__PACKAGE__->new->RunReport;

# eof TracksNamedWithSequence.pl
