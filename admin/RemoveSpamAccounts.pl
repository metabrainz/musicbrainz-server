#!/usr/bin/env perl

use warnings;
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
use lib "$FindBin::Bin/../lib";

use Getopt::Long;
use Log::Dispatch;
use MusicBrainz::Server::Context;

my $c = MusicBrainz::Server::Context->create_script_context();
my $sql = Sql->new($c->dbh);
my $dbh = $c->dbh;

my $prefix = shift;
$prefix .= "%";

my $editors = $c->sql->select_list_of_hashes("SELECT id, name FROM editor WHERE name ILIKE ?", $prefix);
foreach my $ed (@{$editors}) { 
    print "removing account '" . $ed->{name} . "'\n";
   
    my $id = $ed->{id};
    eval {
        $c->model('Editor')->delete($id);
        $sql->begin;
        $sql->do("DELETE FROM edit_note WHERE editor = ?", $id);
        $sql->do("DELETE FROM editor WHERE id = ?", $id);
        $sql->commit;
    };
    if ($@) {
        warn "Remove editor $id died with $@\n";
    }
}
