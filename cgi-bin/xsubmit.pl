#!/usr/bin/perl -w
#____________________________________________________________________________
#
#   CD Index - The Internet CD Index
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
use XML::Parser;
use DBI; 
use XMLParse;

my ($line, $xml);
my ($ret, $n1);

print("Content-type: text/plain\n\n");

while(defined($line = <>))
{
    $xml .= $line;
}

$n1 = new XML::Parser(Handlers => {
                                    Init     => \&XMLParse::ParseInit,
                                    Final    => \&XMLParse::ParseFinal,
                                    Start    => \&XMLParse::ParseStart,
                                    End      => \&XMLParse::ParseEnd,
                                    Char     => \&XMLParse::ParseChar
                                  });

eval
{
    $ret = $n1->parsestring($xml);
};
if ($@)
{
     $@ =~ tr/\n\r/  /;
     print "501 Parse error\n$@\n";
}
else
{
     if ($ret eq '')
     {
        print "100 XML Record accepted\n";
     }
     else
     {
        print "502 Database Error\n$ret\n";
     }
}
