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
use lib "$FindBin::Bin/../../cgi-bin";

use strict;
use DBI;
use DBDefs;
use Album;
use MusicBrainz;

my $mb = MusicBrainz->new;
$mb->Login;
my $dbh = $mb->{DBH};

# select all albums
my $sth = $dbh->prepare('SELECT DISTINCT(Album.Id) FROM Album, AlbumJoin, Track, TOC WHERE album.id = albumjoin.album and albumjoin.track = track.id and track.length <= 0 and Album.Id = TOC.Album');
$sth->execute();

# for each album 
while ( my $row = $sth->fetchrow_hashref )
{

    print "Fixing length for all tracks in Album Id '".$row->{'id'}."'...";
    
    my $alb = Album->new($dbh);
    $alb->SetId($row->{'id'});
    if(!$alb->LoadFromId()) {
        printf("Can't loadfrom id.\n");
        exit(0);
    }    
    
    my @tracks = $alb->LoadTracks();
    
    # select the first TOC
    my $sth2 = $dbh->prepare("SELECT * FROM TOC WHERE Album = '$row->{'id'}'");
    $sth2->execute();
    my ($toc, $lastnum);
    for(;;)
    {
        $toc = $sth2->fetchrow_hashref;
        if (!defined $toc)
        {
           last;
        }
        $lastnum = $toc->{'tracks'};
        last if ($toc->{'tracks'} == scalar(@tracks));
    }

    if (!defined $toc)
    {
        print "No valid id found.\n";
        print "$lastnum == " . scalar(@tracks) . "\n";
        $sth2->finish();
        next;
    }
    $sth2->finish();

    # Compute and update the length of each track
    my $ii;
    my @lengths;
    for($ii = 1; $ii < $toc->{'tracks'}; $ii++) {
        $lengths[$ii] = int((($toc->{'track'.($ii+1)} - $toc->{'track'.$ii})*1000)/75);
        #print "length[$ii]: $lengths[$ii]\n";
    }
    $lengths[$ii] =  int((($toc->{'leadout'} - $toc->{'track'.$ii})*1000)/75);
    #print "length[$ii]: $lengths[$ii]\n\n";

    foreach(@tracks) {
        if(defined($lengths[$_->GetSequence()])) {
            my $q = "UPDATE Track SET Length = '".$lengths[$_->GetSequence()]."' WHERE Id = '".$_->GetId()."'\n";
            my $sth3 = $dbh->prepare($q);
            $sth3->execute();
            $sth3->finish();
        }
    }

    print "ok\n";
}

$sth->finish();
$mb->Logout;
