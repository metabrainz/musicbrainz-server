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
                                                                               
use lib "../cgi-bin";
use strict;
use Socket;


sub SendXML
{
    my $remote = shift;
    my $port = shift;
    my $xml = shift;
    my ($iaddr, $paddr, $proto);
    my $line;

    $iaddr = inet_aton($remote);
    $paddr = sockaddr_in($port, $iaddr);
    $proto = getprotobyname('tcp');

    if (!socket(SOCK, PF_INET, SOCK_STREAM, $proto))
    {
       die("Cannot open socket");
    }
    if (!connect(SOCK, $paddr))
    {
       die("Cannot connect to $remote:$port");
    }

    send SOCK, "POST /cgi-bin/cdi/xsubmit.pl HTTP/1.0\n", 0;
    send SOCK, "Connection: Keep-Alive\n", 0;
    send SOCK, "Host: $remote\n", 0;
    send SOCK, "Accept: */*\n", 0;
    send SOCK, "Content-type: text/plain\n", 0;
    send SOCK, "Content-length: " . (length($xml)+1) . "\n\r\n", 0;
    send SOCK, "$xml\n\n", 0;

    $line = <SOCK>;
    if (!defined $line)
    {
        print "The server closed the connection prematurely.\n";
    }

    my ($ver, $ret, $text) = split / /, $line, 3;
   
    if ($ret == 200)
    {
        while(defined($line = <SOCK>))
        {
            if ($line eq "\r\n")
            {
                last;
            }
        }
        while(defined($line = <SOCK>))
        {
            print $line;
        }
    }
    else
    { 
        print "The web server did not accept your request: $ret $text\n";
    }

    close(SOCK);
}

my ($line, $xml);
 
if (scalar(@ARGV) < 2)
{
    print("usage: xsend.pl <server> <xml doc file>\n");
    exit(0);
}

open(FILE, $ARGV[1])
    or die "Cannot open $ARGV[1]";

while(defined($line = <FILE>))
{
   $xml .= $line;
}
close(FILE);

SendXML($ARGV[0], 80, $xml);

