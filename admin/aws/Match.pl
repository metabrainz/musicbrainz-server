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
use Getopt::Long;
use String::Unicode::Similarity;
use Time::HiRes qw( usleep gettimeofday tv_interval );
use URI::Escape;
use LWP::UserAgent;
use XML::Parser;
use MusicBrainz;
use Artist;
use Album;
use SearchEngine;
use Text::Unaccent;

use constant MAX_PAGES_PER_ARTIST => 100;

use constant MODE_FIND       => 1;
use constant MODE_UPDATE     => 2;
use constant MODE_DAILY      => 3;

sub IsValidImage
{
    my ($url) = @_;

    my $ua = LWP::UserAgent->new;
    $ua->timeout(10);

    my $response = $ua->get($url);
    if ($response->is_success)
    {
        if ($response->content =~ /JFIF/ ||
            $response->content =~ /GIF87a/ ||
            $response->content =~ /GIF89a/)
        {
            return 0 if (length($response->content) < 1024);
            return 1;
        }
#        $url =~ s-^(.*)/(.+?)$-$2-;
#        open FUSS, ">$url" or die;
#        print FUSS $response->content;
#        close FUSS;
    } 

    return 0;
}

sub HandleStart
{
    my ($expat, $element, @attrs) = @_;

    $expat->{__mbnode} .= "/$element";

    if ($expat->{__mbnode} eq '/ProductInfo/Details/Artists')
    {
        $expat->{__mbdata}->{artistCount} = 0;
        return;
    }
    if ($expat->{__mbnode} eq '/ProductInfo/Details/Artists/Artist')
    {
        $expat->{__mbdata}->{artistCount}++;
        return;
    }
}

sub HandleEnd
{
    my ($expat) = @_;

    if ($expat->{__mbnode} eq '/ProductInfo/Details')
    {
        if ($expat->{__mbdata}->{artistCount} == 1 &&
            similarity($expat->{__mbdata}->{artist}, $expat->{__mbartist}) > .5)
        {
            if (!IsValidImage("http://images.amazon.com" . $expat->{__mbdata}->{url}))
            { 
                $expat->{__mbdata}->{url} = '';
            }

            if (!exists $expat->{__mbalbums}->{$expat->{__mbdata}->{album}} || 
                (defined $expat->{__mbalbums}->{$expat->{__mbdata}->{url}} &&
                $expat->{__mbalbums}->{$expat->{__mbdata}->{url}} eq ''))
            {
                $expat->{__mbalbums}->{$expat->{__mbdata}->{album}} = 
                {
                     asin    => $expat->{__mbdata}->{asin},
                     album   => $expat->{__mbdata}->{album},
                     url     => $expat->{__mbdata}->{url},
                     matched => 0
                };
            }
        }
#       else
#       {
#           printf("Skipping album %s by %s (%d artists)\n", 
#                   $expat->{__mbdata}->{album},
#                   $expat->{__mbdata}->{artist},
#                   $expat->{__mbdata}->{artistCount});
#       }

        $expat->{__mbdata}->{asin} = '';
        $expat->{__mbdata}->{album} = '';
        $expat->{__mbdata}->{url} = '';
        $expat->{__mbdata}->{artist} = '';
        $expat->{__mbdata}->{artistCount} = 0;
        $expat->{__mbdata}->{pages} = 0;
    }

    $expat->{__mbnode} =~ s-/\w+$--;
}

sub HandleChar
{
    my ($expat, $char) = @_;

    if ($expat->{__mbnode} eq '/ProductInfo/TotalPages')
    {
        $expat->{__mbdata}->{pages} = $char;
        return;
    }

    if ($expat->{__mbnode} eq '/ProductInfo/Details/Asin')
    {
        $expat->{__mbdata}->{asin} = $char;
        return;
    }

    if ($expat->{__mbnode} eq '/ProductInfo/Details/ProductName')
    {
        $expat->{__mbdata}->{album} .= $char;
        return;
    }

    if ($expat->{__mbnode} eq '/ProductInfo/Details/ImageUrlMedium')
    {
        $char =~ s/^http:\/\/images.amazon.com//;
        $expat->{__mbdata}->{url} .= $char;
        return;
    }

    if ($expat->{__mbnode} eq '/ProductInfo/Details/Artists/Artist')
    {
        $expat->{__mbdata}->{artist} .= $char;
        return;
    }
}

sub ParseXML
{
    my ($artist, $album_asins, $album_urls, $xml) = @_;
    my ($expat, %data);

    $expat = new XML::Parser(Handlers => {Start => \&HandleStart,
                                          End   => \&HandleEnd,
                                          Char  => \&HandleChar});
    $data{artistCount} = 0;
    $expat->{__mbnode} = '';
    $expat->{__mbdata} = \%data;
    $expat->{__mbalbums} = $album_asins;
    $expat->{__mburls} = $album_urls;
    $expat->{__mbartist} = $artist;
    eval
    {
        $expat->parse($xml);
    };
    if ($@)
    {
        return (0, $@);
    }
    return ($data{pages}, "");
}

sub CompareName
{
    my ($search, $A, $B) = @_;
    my ($tokb, $toka);

    $tokb = join '', @{($search->Tokenize($B))[1]};
    $toka = join '', @{($search->Tokenize($A))[1]};

    return similarity($tokb, $toka);
}

sub CompareAlbumName
{
    my ($search, $amazon, $mb, $chopit) = @_;
    my ($chopmb, $chopam);

    if ($chopit)
    {
        $mb =~ s/\s*\(.+?\)\s*$//;
        $amazon =~ s/\s*\[.+?\]\s*$//;
        $amazon =~ s/\s*\(.+?\)\s*$//;
    }

    return CompareName($search, $amazon, $mb);
}

sub MatchArtist
{
    my ($dbh, $artist, $artistid) = @_;
    my ($pages, %album_asins, %album_urls, $album, $xml);
    my ($error, $i, %matched, $count);

    print "Matching $artist ($artistid): ";

#print "\n";
    $count = 0;
    for($pages = 1, $i = 0; $i < $pages; $i++)
    {
        last if ($i >= MAX_PAGES_PER_ARTIST);

        my $url = qq|http://xml.amazon.com/onca/xml3?t=| . &DBDefs::AWS_ASSOCIATE_ID('amazon.com') .
                  qq|&dev-t=| . &DBDefs::AWS_DEVELOPER_ID . 
                  qq|&ArtistSearch=| . uri_escape(unac_string('UTF-8', $artist)) .
                  qq|&mode=music&type=lite&page=| . ($i+1) . 
                  qq|&f=xml|;    

        my $ua = LWP::UserAgent->new;
        $ua->timeout(10);

        my $t0 = [gettimeofday];
        print ".";
        my $response = $ua->get($url);
        if ($response->is_success)
        {
#           open FUSS,">xml-$i.xml" or die;
#           print FUSS $response->content;
#           close FUSS;

            ($pages, $error) = ParseXML($artist, \%album_asins, \%album_urls, $response->content);
            if ($error)
            {
                return (0, $error);
            }
        }

        my $t1 = [gettimeofday];
        my $dur = (1.0 -  tv_interval($t0, $t1)) * 1000000;
        usleep($dur) unless $dur < 0;

        if (!defined $pages || $pages < 1)
        {
            $pages = 1;
            last;
        }
    }
    for($i = 0; $i < $pages; $i++)
    {
        print "\b";
    }

    my ($ar, @albums, $aalbum, $search);

    $search = SearchEngine->new($dbh);
    $ar = Artist->new($dbh);
    $ar->SetId($artistid);

    @albums = $ar->GetAlbums(1);
    for(my $chop = 0; $chop < 2; $chop++)
    {
        foreach $album (@albums)
        {
            my ($best, $sim, $bestalbum, $tokam, $tokmb);

            # If this album had already been matched, skip it
            next if (exists $matched{$album});
            
            $best = 0;
            $bestalbum = 0;
            foreach $aalbum (keys %album_asins)
            {
                $sim = CompareAlbumName($search, $aalbum, $album->GetName(), $chop);
                if ($sim >= $best)
                {
                    $best = $sim;
                    $bestalbum = $aalbum;
                }
            }
            if ($best > .8)
            {
                $matched{$album} = [ $bestalbum, $best, $album_asins{$bestalbum}->{asin},
                                     $album_asins{$bestalbum}->{url} ];
                $album_asins{$bestalbum}->{matched}++; 
            }
        }

#       print "Pass $chop: " . scalar(keys %matched) . " matches:\n";
#       foreach $album (@albums)
#       {
#           if (exists $matched{$album})
#           {
#               printf "   OK: %3d%% %s (%d) -- %s (%s) %s\n", 
#                   $matched{$album}->[1] * 100, 
#                   $album->GetName(), $album->GetId(), 
#                   $matched{$album}->[0], $matched{$album}->[2],
#                   ($matched{$album}->[3] eq '') ? "no image" : "";
#           }
#       }
#       print "\n";
    }

#   print "MB albums not matched:\n";
    $count = 0;
    foreach $album (@albums)
    {
        if (!exists $matched{$album})
        {
#            printf "  %s (%d)\n", $album->GetName(), $album->GetId();
            # Add an empty record to note that we've looked at this album and found nothing.
            $matched{$album} = [ '', 0, '', '' ];
        }
        else
        {
            $count++ 
        }
    }
    if (scalar(keys %album_asins) == 0)
    {
        print "Zero albums returned\n";
    }
    else
    {
        printf "MB: %d of %d (%.2f%%)  ", $count, scalar(@albums), $count * 100 / scalar(@albums);
    }
 
#    print "Amazon albums not matched:\n";
    $count = 0;
    foreach $album (keys %album_asins)
    {
        if ($album_asins{$album}->{matched})
        {
           $count++ 
        }
        else
        {
#           printf "  %s %s\n", $album_asins{$album}->{asin}, $album;
        }
    }
    if (scalar(keys %album_asins) != 0)
    {
        printf "AM: %d of %d (%.2f%%)\n", 
            $count, scalar(keys %album_asins), $count * 100 / scalar(keys %album_asins);
    }

    my ($sql);
   
    $sql = Sql->new($dbh);

    $sql->Begin();
    eval 
    {
        foreach $album (@albums)
        {
            if (exists $matched{$album})
            {
                 $sql->Do("UPDATE album_amazon_asin SET asin = ?, coverarturl = ?, lastupdate = now() WHERE album = ?", 
                         $matched{$album}->[2], $matched{$album}->[3], $album->GetId())
                 or
                 $sql->Do("INSERT INTO album_amazon_asin (asin, coverarturl, album) values (?, ?, ?)", 
                         $matched{$album}->[2], $matched{$album}->[3], $album->GetId())
            }
        }
    };
    if ($@)
    { 
        print "$@\n";
        $sql->Rollback();
        return (0, $@);
    }
    else
    {
        $sql->Commit();
    }

    return ($count, "");
}

sub MatchAlbums
{
    my ($dbh, $mode) = @_;
    my ($ret, $error, $sth, $max);

    if ($mode == MODE_FIND)
    {
        $sth = $dbh->prepare(qq|select distinct ar.id, ar.name 
                                       from artist ar, album al 
                                  left join album_amazon_asin aaa on aaa.album = al.id 
                                 where aaa.album IS NULL and al.artist = ar.id 
                                 order by ar.id|);
    }
    elsif ($mode == MODE_UPDATE)
    {
        $sth = $dbh->prepare(qq|select ac.id, ac.name, sum(ac.with_asin) as withasin, sum(ac.without_asin) as withoutasin 
                                  from (
                                           select ar.id, ar.name, 0 as with_asin, count(ar.id) as without_asin 
                                             from artist ar, album al, album_amazon_asin aaa 
                                            where aaa.asin = '          ' and aaa.album = al.id and al.artist = ar.id 
                                            group by ar.id, ar.name 
                                        union 
                                            select ar.id, ar.name, count(ar.id) as with_asin, 0 as without_asin 
                                              from artist ar, album al, album_amazon_asin aaa 
                                             where aaa.asin != '          ' and aaa.album = al.id and al.artist = ar.id 
                                             group by ar.id, ar.name
                                       ) as ac 
                                 group by ac.id, ac.name order by ac.id|);
    }
    elsif ($mode == MODE_DAILY)
    {
        $sth = $dbh->prepare(qq|select distinct ar.id, ar.name, aaa.lastupdate 
                                       from artist ar, album al, album_amazon_asin aaa  
                                 where aaa.album = al.id and al.artist = ar.id 
                                 order by aaa.lastupdate asc, ar.id|);
    }
    else
    {
        die "Invalid Mode.\n";
    }

#   $sth = $dbh->prepare(qq|select artist.id, artist.name from artist where id = 2908|);
#   $sth = $dbh->prepare(qq|select 200, 'Sinead OConnor'|);
    $sth->execute();

    if ($sth->rows)
    {
        my @row;

        if ($mode == MODE_DAILY)
        {
            $max = $sth->rows / 30;
        }

        while(@row = $sth->fetchrow_array())
        {
            next if ($row[0] == &ModDefs::VARTIST_ID);
            next if ($mode == MODE_UPDATE && $row[2] > 0);

            for(;;)
            {
                ($ret, $error) = MatchArtist($dbh, $row[1], $row[0]);
                if ($ret == 0 && $error eq '')
                {
                    next if ($row[1] =~ s/\sand\s/ & /i);
                }
                last;
            }
            if ($error)
            {
                print "Error: $error\n";
            }
            if ($mode == MODE_DAILY)
            {
                $max--;
                last if ($max < 0);
            }
        }
    }
    $sth->finish;
}

sub Usage
{
   die <<EOF;
Usage: Match.pl [options]

Match MusicBrainz albums with Amazon albums and store ASINS and cover art URLs in the datanase.

Options are:
  -u --update         Match only artists who have no Amazon matches at all.
  -d --daily          Match 1/30th of the artists that have the oldest asin pairings
  -h --help           This help page

EOF
}

my ($arg, $mb, $fUpdateUnmatched, $fUpdateDaily);
my $mode = MODE_FIND;

GetOptions(
        "update|u"      => \$fUpdateUnmatched,
        "daily|d"       => \$fUpdateDaily,
        "help|h"        => \&Usage,
        ) or exit 2;

$mode = MODE_UPDATE if ($fUpdateUnmatched);
$mode = MODE_DAILY if ($fUpdateDaily);

$| = 1;
$mb = MusicBrainz->new;
$mb->Login;


MatchAlbums($mb->{DBH}, $mode); 

# Disconnect
$mb->Logout;
