#!/home/httpd/musicbrainz/mb_server/cgi-bin/perl -w
#____________________________________________________________________________
#
#   MusicBrainz -- The community music metadata project.
#
#   Copyright (C) 1998 Robert Kaye
#   Copyright (C) 2001 Luke Harless
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
use lib "$FindBin::Bin/../../cgi-bin";

use DBI;
use DBDefs;
use MusicBrainz;
use String::Similarity;
require "$FindBin::Bin/Main.pl";

# This function gets invoked when the usage statement is printed out.
sub Arguments
{
    # Return the argument list that the Cleanup function should
    # expect after the dbh, fix and quiet aguments.
    # Eample:   <album id> [album id] ...
    return "";
}

# This function gets invoked to carry out a cleanup task. 
# Args: $dbh   - the database handle to do database work
#       $fix   - if this is non-zero, make changes to the DB. IF THIS IS
#                ZERO, THEN DO NO MAKE CHANGES TO THE DB!
#       $quiet - if non-zero then execute quietly (produce no output)
#       ...    - the arguments that the user passed on the command line
sub Cleanup
{
    my ($dbh, $fix, $quiet, $arg1, $arg2) = @_;

    # Here is a basic select loop for you to work with.
    $sth = $dbh->prepare(qq\select track.artist, name, length 
                              from track
                             where length > 0 and track.artist > 2
                          order by track.artist, name, length\);
    if ($sth->execute() && $sth->rows())
    {
        my @row;
        my %last;
        my $merged = 0;
        my $match_count = 0;

        $last{artist} = -1;
        $last{len} = -1000000;
        while(@row = $sth->fetchrow_array())
        {
            if ($last{artist} == $row[0])
            {
                if (abs($last{len} - $row[2]) < 5000 &&
                    similarity($last{name}, $row[1]) >= .9)
                {
                    print "$last{artist}: $last{len} - $last{name}\n"
                        if ($match_count == 0);
                        
                    print "$row[0]: $row[2] - $row[1]\n";
                    $merged++;
                    $match_count++;
                }
                else
                {
                    print "\n" if ($match_count > 0);
                    $match_count = 0;
                }
            }

            $last{artist} = $row[0];
            $last{name} = $row[1];
            $last{len} = $row[2];
        }
    }
    $sth->finish;

    # Perhaps carry out some actions, if $fix is non-zero
    print "$merged tracks merged.\n" if (!$quiet);
}

# Call main with the number of arguments that you are expecting
Main(0);
