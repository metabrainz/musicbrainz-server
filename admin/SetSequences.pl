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

use FindBin;
use lib "$FindBin::Bin/../cgi-bin";

use DBI;
use DBDefs;
use MusicBrainz;
use Sql;

sub SetSequence
{
    my ($sql, $table) = @_;
    my ($max, $seq);

    $seq = $table . "_id_seq";
    $mb{DBH} = $sql;

    ($max) = $sql->GetSingleColumn($table, "max(id)", []);
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

$mb = MusicBrainz->new;
$mb->Login;
$sql = Sql->new($mb->{DBH});

print "Connected to database.\n";

SetSequence($sql, "artist");
SetSequence($sql, "artistalias");
SetSequence($sql, "album");
SetSequence($sql, "track");
SetSequence($sql, "albumjoin");
SetSequence($sql, "discid");
SetSequence($sql, "toc");
SetSequence($sql, "trm");
SetSequence($sql, "trmjoin");
SetSequence($sql, "moderator");
SetSequence($sql, "moderation");
SetSequence($sql, "moderationnote");
SetSequence($sql, "votes");
SetSequence($sql, "stats");
SetSequence($sql, "clientversion");

# Disconnect
$mb->Logout;
