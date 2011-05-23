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

package DuplicateArtists;
use base qw( MusicBrainz::Server::ReportScript );

use MusicBrainz::Server::Validation;
use Encode qw( decode );

sub addartist
{
    my ($artists, $row, $id, $name, $modpending) = @_;

    my $n = MusicBrainz::Server::Validation::unaccent($name);
    $n = uc decode("utf-8", $n);
    $n =~ s/[\p{Punctuation}]//g;
    $n =~ s/\bAND\b/&/g;

    my @words = sort $n =~ /(\w+)/g;
    my $key = "@words";

    $artists->{$key}{$id} ||= $row;
}

sub GatherData
{
    my $self = shift;
    my %artists;

    $self->Log("Querying database");
    my $sql = $self->SqlObj;

    $sql->Select("
        SELECT 
                id, 
                name, 
                sortname, 
                modpending 
        FROM 
                artist");

    while (my @row = $sql->NextRow)
    {
        addartist(\%artists, \@row, $row[0], $row[1], $row[3]);
        addartist(\%artists, \@row, $row[0], $row[2], $row[3]);
    }

    $sql->Finish;

    $sql->Select("
        SELECT 
                l.ref, 
                l.name, 
                '[alias for ' || r.name || ']', 
                l.modpending
        FROM 
                artistalias l, 
                artist r
        WHERE 
                r.id = l.ref");

    while (my @row = $sql->NextRow)
    {
        addartist(\%artists, \@row, $row[0], $row[1], $row[2]);
    }

    $sql->Finish;

    $self->Log("Saving results");
    my $report = $self->PagedReport;

    while (my ($k, $v) = each %artists)
    {
        next unless keys(%$v) >= 2;

        my $dupelist;
        for (values %$v)
        {
                my $na = $sql->SelectSingleValue("
                        SELECT 
                                COUNT(*) 
                        FROM 
                                album
                        WHERE 
                                artist = ?", $_->[0]);
                my $nt = $sql->SelectSingleValue("
                        SELECT 
                                COUNT(*) 
                        FROM 
                                track 
                        WHERE 
                                artist = ?", $_->[0]);

                push @$dupelist, {
                        artist_id => $_->[0],
                        artist_name => $_->[1],
                        artist_sortname => $_->[2],
                        num_albums => $na,
                        num_tracks => $nt,
                };
        }

        $report->Print($dupelist);
    }
}

__PACKAGE__->new->RunReport;

# eof DuplicateArtists.pl
