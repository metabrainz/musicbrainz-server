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

use strict;
use XML::Parser;
use DBDefs;
use DBI;

my $dbh;

require "../cgi-bin/parse_sup.pl";

if (scalar(@ARGV) < 1)
{
    print("usage: cdi_parse.pl <xml doc>\n");
    exit(0);
}

$dbh = DBI->connect(DBDefs->DSN,DBDefs->DB_USER,DBDefs->DB_PASSWD);
if (!$dbh)
{
    print "Sorry, the database is currently ";
    print "not available. Please try again in a few minutes.\n";
    print "(Error: ".$DBI::errstr.")\n";
}
else
{  
    my ($n1, $line, $xml);

    SetDbh($dbh);

    $n1 = new XML::Parser(Handlers => {
                                        Init     => \&ParseInit,
                                        Final    => \&ParseFinal,
                                        Start    => \&ParseStart,
                                        End      => \&ParseEnd,
                                        Char     => \&ParseChar
                                      });

    open(FILE, $ARGV[0])
        or die "Cannot open $ARGV[0]";

    while(defined($line = <FILE>))
    {
       $xml .= $line;

       if ($line =~ /<\/CDInfo>/)
       {
           #print "$xml\n-------------------------------------------\n";
           eval
           {
               $n1->parsestring($xml); 
           };
           if ($@)
           {
               print "Parse unsuccessful: $@\n";
           }
           $xml = '<?xml version="1.0" encoding="ISO-8859-1"?>' . "\n";
       }
    }

    close(FILE);
    $dbh->disconnect;
}

