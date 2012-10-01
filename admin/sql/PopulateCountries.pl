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

# Abstract: populate the "countries" table from the ISO 3166 countries list

use FindBin;
use lib "$FindBin::Bin/../../lib";

use DBDefs;
use MusicBrainz::Server::Context;
use Sql;

my $mb = MusicBrainz::Server::Context->new;
my $sql = Sql->new($mb->conn);

use strict;

my $fh;
if (@ARGV)
{
    $fh = *ARGV;
} else {
    my $url = 'http://ftp.ics.uci.edu/pub/ietf/http/related/iso3166.txt';
    open($fh, "wget --quiet -O- $url |")
        or die $!;
}

$sql->begin;
my $n = 0;

while (<$fh>)
{
    /^(.*?)\s+([A-Z][A-Z])\s+([A-Z][A-Z][A-Z])\s+(\d\d\d)(?:\s|$)/
        or next;
    my ($name, $isocode) = ($1, $2);

    $name = lc $name;
    $name =~ s/\b(\w)/uc $1/eg;
    $name =~ s/\bD'/d'/g;
    $name =~ s/'S\b/'s/g;
    $name =~ s/\bAnd\b/and/g;
    $name =~ s/\bOf\b/of/g;

    $sql->select_single_value(
        "SELECT id FROM country WHERE name = ? AND isocode = ?",
        $name, $isocode,
    ) and next;

    $sql->do(
        "INSERT INTO country (name, isocode) VALUES (?, ?)",
        $name, $isocode,
    );
    ++$n;
}

$sql->commit;

print "Loaded $n countries\n";

# eof PopulateCountries.pl
