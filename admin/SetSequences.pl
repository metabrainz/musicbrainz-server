#!/home/httpd/musicbrainz/mb_server/cgi-bin/perl -w
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

use strict;

use FindBin;
use lib "$FindBin::Bin/../cgi-bin";

use DBDefs;
use MusicBrainz;
use Sql;

sub SetSequence
{
    my ($sql, $table, $max) = @_;

    my $seq = $table . "_id_seq";

    if (not defined $max)
    {
		$max = (iiMinMaxID($table))[1];
    }

    $max++;

    eval
    {
        $sql->Begin;
        $sql->SelectSingleValue("SELECT SETVAL(?, ?)", $seq, $max);
        $sql->Commit;
    
        printf "%12d  %s\n", $max, $seq;
    };
    if ($@)
    {
        $sql->Rollback;
    }

}

my $mb = MusicBrainz->new;
$mb->Login(db => "READWRITE");
my $sql = Sql->new($mb->{DBH});

SetSequence($sql, "album");
SetSequence($sql, "albumjoin");
# album_amazon_asin - not a serial column
SetSequence($sql, "album_cdtoc");
# albummeta - not a serial column
# albumwords - no unique integer column
SetSequence($sql, "annotation");
SetSequence($sql, "artist");
SetSequence($sql, "artist_relation");
SetSequence($sql, "artistalias");
# artistwords - no unique column
SetSequence($sql, "automod_election");
SetSequence($sql, "automod_election_vote");
SetSequence($sql, "cdtoc");
SetSequence($sql, "clientversion");
SetSequence($sql, "country");
SetSequence($sql, "currentstat");
SetSequence($sql, "historicalstat");
# moderation_closed - see below
# moderation_note_closed - see below
# moderation_note_open - see below
# moderation_open - see below
SetSequence($sql, "moderator");
SetSequence($sql, "moderator_preference");
SetSequence($sql, "moderator_subscribe_artist");
SetSequence($sql, "release");
SetSequence($sql, "replication_control");
SetSequence($sql, "stats");
SetSequence($sql, "track");
# trackwords - no unique column
SetSequence($sql, "trm");
SetSequence($sql, "trmjoin");
SetSequence($sql, "trmjoin_stat");
SetSequence($sql, "trm_stat");
# vote_closed - see below
# vote_open - see below
SetSequence($sql, "wordlist");

# For the three pairs of open/closed tables (moderation, moderation_note
# and vote), it is possible that the largest ID is actually in the closed
# table, not the open one.  So we need to find the largest ID across both
# tables, then set the "open" sequence based on that.  (There is no "closed"
# sequence).

$_ = "moderation";
SetSequence($sql, "${_}_open", (iiMinMaxID("${_}_open", "${_}_closed"))[1]);
$_ = "moderation_note";
SetSequence($sql, "${_}_open", (iiMinMaxID("${_}_open", "${_}_closed"))[1]);
$_ = "vote";
SetSequence($sql, "${_}_open", (iiMinMaxID("${_}_open", "${_}_closed"))[1]);

exit;

sub iiMinMaxID
{
	my @tables = @_;

	# Postgres is poor at optimising SELECT MIN(id) FROM table
	# (or MAX).  It uses a table scan, instead of an index scan.
	# However for the following queries it gets it right:

	my ($min, $max) = (undef, undef);
	for my $table (@tables)
	{
		my $thismin = $sql->SelectSingleValue(
			"SELECT id FROM $table ORDER BY id ASC LIMIT 1",
		);
		$min = $thismin
			if defined($thismin)
			and (not defined($min) or $thismin < $min);

		my $thismax = $sql->SelectSingleValue(
			"SELECT id FROM $table ORDER BY id DESC LIMIT 1",
		);
		$max = $thismax
			if defined($thismax)
			and (not defined($max) or $thismax > $max);
	}

	return ($min, $max);
}

# eof SetSequences.pl
