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

use strict;

use FindBin;
use lib "$FindBin::Bin/../cgi-bin";

use DBDefs;
use MusicBrainz;
use Sql;
use MusicBrainz::Server::CDStub;
use MusicBrainz::Server::CDTOC;

my $c = MusicBrainz::Server::Context->new;
my $rwsql = Sql->new($c->dbh);
my $sql = Sql->new($mb->raw_dbh);

my $rc = MusicBrainz::Server::CDStub->new($c->raw_dbh);
my $cdtoc = MusicBrainz::Server::CDTOC->new($c->dbh);

my $line;
my $data = ();
my ($k, $v);
my ($count, $error, $invalidtoc, $have);

while($line = <>)
{
    $line =~ s/^\s*?(.*?)\s*$/$1/;
    if (!$line)
    {
        my %tocdata = MusicBrainz::Server::CDTOC::ParseTOC(undef, $data->{toc});
        if (%tocdata)
        {
            $data->{source} = MusicBrainz::Server::CDStub::CDSTUB_SOURCE_CDBABY;
                $data->{discid} = $tocdata{discid};

                if (!$rc->Lookup($data->{discid}) && !scalar(@{$cdtoc->newFromDiscID($data->{discid})}))
                {
                        my $err = $rc->Insert($data);
                        if ($err)
                        {
                                #print "Error inserting cd ".$data->{comment}.": $err\n";
                                $error++;
                        }
                    else
                    {
                                #print "Inserted $data->{title} by $data->{artist}\n";
                                $count++;
                                print "Inserted $count cds.\n" if ($count % 1000 == 0);
                    }
                }
                else
                {
                        $have++;
                }
        }
        else
        {
                #print "Invalid toc for cd ".($data->{cdbaby} || '').": " . ($data->{toc} || '') . "\n";
                $invalidtoc++;
        }

        $data = ();
        next;
    }

    ($k, $v) = split /=/, $line, 2;
    $data->{artist} = $v if ($k eq 'artist');
    $data->{title} = $v if ($k eq 'album');
    $data->{toc} = $v if ($k eq 'toc');
    $data->{barcode} = $v if ($k eq 'barcode');
    $data->{comment} = $v if ($k eq 'comment');
    $data->{tracks}->[$1]->{title} = $v if ($k =~ /^track(\d+)/);
}
print "Imported $count CDs. Already had $have CDs. Encountered $invalidtoc invalid tocs and $error insert errors."
