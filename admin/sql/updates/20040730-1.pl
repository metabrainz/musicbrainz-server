#!/usr/bin/perl -w
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

# Abstract: Create initial datasets for cdtoc and album_cdtoc

use strict;

use FindBin;
use lib "$FindBin::Bin/../../../lib";

use DBDefs;
use MusicBrainz;
use Sql;
use MusicBrainz::Server::CDTOC;

$| = 1 if -t STDOUT;

my $mb = MusicBrainz->new; $mb->Login;
my $sql = Sql->new($mb->{dbh});

$sql->Begin;

my $tot = $sql->SelectSingleValue("SELECT COUNT(*) FROM discid");
my $n = 0;
my $errors = 0;
my %seentoc;

open(my $cdtoc, ">/tmp/20040730-cdtoc.dat") or die $!;
open(my $album_cdtoc, ">/tmp/20040730-album_cdtoc.dat") or die $!;

print "Scanning discids: ";
$sql->Select("SELECT * FROM discid");
while (my $row = $sql->NextRowHashRef)
{
	# DiscID-related mods will store discid.id, so to preserve those
	# relationships we must keep that data.  So album_cdtoc.id will be
	# populated from discid.id, and cdtoc.id will be assigned a new sequence
	# of numbers.
	my $id = ++$n;

    my %info = MusicBrainz::Server::CDTOC->ParseTOC($row->{toc})
        or die "Failed to parse TOC of discid #$row->{id} '$row->{toc}'";

	if (my $was = $seentoc{$info{toc}})
	{
		warn "Already seen toc '$info{toc}' with ID $was; seen again with ID $row->{id}\n";
		++$errors;
	}
	$seentoc{$info{toc}} = $row->{id};

	print $cdtoc $id
		. "\t" . $info{discid}
		. "\t" . $info{freedbid}
		. "\t" . $info{tracks}
		. "\t" . $info{leadoutoffset}
		. "\t" . "{".join(",", @{ $info{trackoffsets} })."}"
		. "\n";

	print $album_cdtoc $row->{id}
		. "\t" . $row->{album}
		. "\t" . $id
		. "\t" . $row->{modpending}
		. "\n";

    my $msg = "$n/$tot";
    print $msg; print "\cH" x length($msg);
}
print "\n";

$sql->Commit;

warn "Completed, but with errors!\n" if $errors;
exit($errors == 0 ? 0 : 1);

# eof 20040730-1.pl
