#!/usr/bin/perl -w
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

use strict;

use FindBin;
use lib "$FindBin::Bin/../cgi-bin";

use DBI;
use DBDefs;
use MusicBrainz;
use Sql;

sub SetSequence
{
    my ($sql, $table) = @_;

    my $seq = $table . "_id_seq";

    my $max = $sql->SelectSingleValue("SELECT MAX(id) FROM $table");
    if (not defined $max)
    {
        print "Table $table is empty, not altering sequence $seq\n";
        return;
    }
    $max++;

    eval
    {
        $sql->Begin;
        $sql->SelectSingleValue("SELECT SETVAL(?, ?)", $seq, $max);
        $sql->Commit;
    
        print "Set sequence $seq to $max.\n";
    };
    if ($@)
    {
        $sql->Rollback;
    }

}

my $mb = MusicBrainz->new;
$mb->Login;
my $sql = Sql->new($mb->{DBH});

print "Connected to database.\n";

SetSequence($sql, "album");
SetSequence($sql, "albumjoin");
# albummeta - not a serial column
# albumwords - no unique integer column
SetSequence($sql, "artist");
SetSequence($sql, "artist_relation");
SetSequence($sql, "artistalias");
# artistwords - no unique column
SetSequence($sql, "clientversion");
SetSequence($sql, "country");
# currentstat - no unique integer column
SetSequence($sql, "discid");
# historicalstat - no unique integer column
# moderation_closed - not a serial column
# moderation_note_closed - not a serial column
SetSequence($sql, "moderation_note_open");
SetSequence($sql, "moderation_open");
SetSequence($sql, "moderator");
SetSequence($sql, "moderator_preference");
SetSequence($sql, "moderator_subscribe_artist");
SetSequence($sql, "release");
SetSequence($sql, "stats");
SetSequence($sql, "toc");
SetSequence($sql, "track");
# trackwords - no unique column
SetSequence($sql, "trm");
SetSequence($sql, "trmjoin");
# vote_closed - not a serial column
SetSequence($sql, "vote_open");
SetSequence($sql, "wordlist");

# eof SetSequences.pl
