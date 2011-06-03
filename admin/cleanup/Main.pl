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

use 5.008;
use strict;

use FindBin;
use lib "$FindBin::Bin/../../lib";

use DBDefs;
use MusicBrainz;
use strict;

sub Usage
{
    my $script = $0;
    $script =~ s/^.*\///;
    print "usage: $script [options] ";
    print Arguments();
    print "\nOptions:\n";
    print " -q   run quietly\n";
    print " -f   Fix. Apply the changes. Without the -f no changes will\n";
    print "      be made to the database.\n";
}

sub Main
{
    my ($argsneeded) = @_;
    my ($arg, $mb, $host);
    my ($quiet, $fix);

    $argsneeded = 1 if (!defined $argsneeded);
    $quiet = 0;
    $fix = 0;

    if (scalar(@ARGV) < $argsneeded)
    {
        Usage();
        exit(0);
    }
    while(defined($arg = shift @ARGV))
    {
        if ($arg eq '-q')
        { 
            $quiet = 1;
        }
        elsif ($arg eq '-f')
        { 
            $fix = 1;
        }
        else
        {
            unshift @ARGV, $arg;
            last;
        }
    }

    $mb = MusicBrainz->new;
    $mb->Login;

    Cleanup($mb->{dbh}, $fix, $quiet, @ARGV);

    # Disconnect
    $mb->Logout;
}

1;
