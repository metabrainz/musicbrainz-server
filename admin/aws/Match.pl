#!/home/httpd/musicbrainz/mb_server/cgi-bin/perl -w
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

use FindBin;
use lib "$FindBin::Bin/../../cgi-bin";

use strict;
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
use Image::Info qw( image_info );

use constant MAX_PAGES_PER_ARTIST => 100;

use constant MODE_FIND       => 1;
use constant MODE_UPDATE     => 2;
use constant MODE_DAILY      => 3;
use constant MODE_SINGLE     => 4;

my $verbose = -t;
my $summary = -t;

# What dataset to process
my $mode = MODE_FIND;
# How much of that set to process
my $percent = undef;
my $limit = undef;

# Summary fields
my $start_time = time;
my $artists_processed = 0;
my $queries_sent = 0;

sub IsValidImage
{
    my ($url) = @_;

    my $ua = LWP::UserAgent->new;
    $ua->timeout(10);

    my $response = $ua->get($url);
    if ($response->is_success)
    {
    	my $content = $response->content;
    	my $info = image_info(\$content);
    	if ($info->{file_ext} =~ /jpg|gif|png/)
    	{
            return 0 if ($info->{width} <= 1 || $info->{height} <= 1);
            return 1;
        }
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
        else
        {
            printf("Skipping album %s by %s (%d artists)\n", 
                    $expat->{__mbdata}->{album},
                    $expat->{__mbdata}->{artist},
                    $expat->{__mbdata}->{artistCount})
				if 0;
        }

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

	# TODO handle ErrorMsg in the response: /ProductInfo/ErrorMsg/(text)

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

    print localtime() . " : Matching $artist ($artistid): "
		if $verbose;
	++$artists_processed;

    my ($ar, @albums, $aalbum, $search);

    $search = SearchEngine->new($dbh);
    $ar = Artist->new($dbh);
    $ar->SetId($artistid);

    @albums = $ar->GetAlbums(1);

	# If invoked via --single we need to check that the artist has at least
	# one album
	if (not @albums)
	{
		print "artist has no albums - skipping\n"
			if $verbose;
		return (0, "");
	}

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
        print "." if $verbose and -t STDOUT;

		print DEBUG "GET $url\n";
        my $response = $ua->get($url);
		++$queries_sent;
		print DEBUG $response->as_string, "\n";

        if ($response->is_success)
        {
            ($pages, $error) = ParseXML($artist, \%album_asins, \%album_urls, $response->content);
            if ($error)
            {
                return (0, $error);
            }
        } else {
			warn "Failed to retrieve $url\n";
			print STDERR $response->as_string;
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

	# Erase the dots we printed just now
	print "\b" x $pages if $verbose and -t STDOUT;

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

	# print "MB albums not matched:\n";
    $count = 0;
    foreach $album (@albums)
    {
        if (!exists $matched{$album})
        {
			# printf "  %s (%d)\n", $album->GetName(), $album->GetId();
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
        print "Zero albums returned\n"
			if $verbose;
    }
    else
    {
        printf "MB: %d of %d (%.2f%%)",
			$count, scalar(@albums), $count * 100 / scalar(@albums),
			if $verbose;
    }
 
	# print "Amazon albums not matched:\n";
    $count = 0;
    foreach $album (keys %album_asins)
    {
        if ($album_asins{$album}->{matched})
        {
           $count++ 
        }
        else
        {
			# printf "  %s %s\n", $album_asins{$album}->{asin}, $album;
        }
    }
    if (scalar(keys %album_asins) != 0)
    {
        printf " AM: %d of %d (%.2f%%)\n",
            $count, scalar(keys %album_asins), $count * 100 / scalar(keys %album_asins),
			if $verbose;
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
				printf "DB UPDATE: album=%d asin=%s url=%s\n",
					$album->GetId,
					$matched{$album}->[2],
					$matched{$album}->[3],
					if 0;

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
        print localtime() . " : Returning error: $@\n",
			if $verbose;
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
    my ($dbh, $mode, $percent, $limit) = @_;

	my $sth;

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
                                            where aaa.asin = '' and aaa.album = al.id and al.artist = ar.id 
                                            group by ar.id, ar.name 
                                        union 
                                            select ar.id, ar.name, count(ar.id) as with_asin, 0 as without_asin 
                                              from artist ar, album al, album_amazon_asin aaa 
                                             where aaa.asin != '' and aaa.album = al.id and al.artist = ar.id 
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

    $sth->execute();

    if ($sth->rows)
    {
        my @row;

		my $max = undef;
		$max = $limit if defined $limit;
		$max = $sth->rows * $percent / 100 if defined $percent;
		printf "%s : Will stop after %d artist%s\n",
			scalar(localtime), $max, ($max==1 ? "" : "s"),
			if defined $max;

        while(@row = $sth->fetchrow_array())
        {
            next if ($row[0] == &ModDefs::VARTIST_ID);
            next if ($mode == MODE_UPDATE && $row[2] > 0);

			my ($ret, $error);
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
                print localtime() . " : Error: $error\n"
					if $verbose;
            }
            if (defined $max)
            {
                --$max;
                last if $max <= 0;
            }
        }
    }
    $sth->finish;
}

sub ProcessSingleArtists
{
	my ($dbh, $artists) = @_;

	warn "Warning: no artists specified\n" if not @$artists;

	for my $artist (@$artists)
	{
		my $ar = Artist->new($dbh);

		if ($artist =~ /^(\d+)$/)
		{
			$ar->SetId($1);
			$ar->LoadFromId
				or warn("No artist #$1 found\n"), next;
		} else {
			$ar->LoadFromName($artist)
				or warn("No artist '$artist' found\n"), next;
		}

		my ($ret, $error) = MatchArtist($dbh, $ar->GetName, $ar->GetId);
		print "ret=$ret error=$error\n";
	}
}

sub Usage
{
   die <<EOF;
Usage: Match.pl [options]

Match MusicBrainz albums with Amazon albums and store ASINS and cover art URLs
in the database.

Options are:
      --[no]verbose    [Don't] describe each artist processed (default: true
                       if at a terminal)
      --[no]summary    [Don't] show a summary on exit (default: true if at a
                       terminal)
      --debugfd=N      Log extra debugging info to file description N
  -h, --help           This help page

Select which artists to process:
  -f, --find           Match artists who have at least one "unknown" album
  -u, --update         Match only artists who have no Amazon matches at all
  -d, --daily          Match 1/30th of the artists that have the oldest asin
                       pairings
  -s, --single         Match only the artist(s) given by "--artist"
      --artist=ARTIST  Specify artist IDs or names for --single to process

Select how many of those artists to process:
      --percentage=N   Match this percentage of applicable artists
      --limit=N        Stop after processing this many artists

Default is to process the whole selected dataset, or 3.3% if in "--daily" mode.

EOF
}

my $debugfd;
my @artist;

GetOptions(
	"verbose!"		=> \$verbose,
	"summary!"		=> \$summary,
	"find|f"		=> sub { $mode = MODE_FIND },
	"update|u"		=> sub { $mode = MODE_UPDATE },
	"daily|d"		=> sub { $mode = MODE_DAILY },
	"single|s"		=> sub { $mode = MODE_SINGLE },
	"artist=s"		=> \@artist,
	"debugfd=i"		=> \$debugfd,
	"percentage=f"	=> sub {
		die "--percentage out of range (must be >0, <=100)\n"
			if $_[1] <= 0 or $_[1] > 100;
		$percent = $_[1];
		$limit = undef;
	},
	"limit=i"		=> sub {
		$percent = undef;
		$limit = $_[1];
	},
	"help|h"		=> \&Usage,
) or exit 2;
Usage() if @ARGV;

$percent = 3.3 if $mode == MODE_DAILY
	and not defined $percent and not defined $limit;

warn "Warning: --artist ignored in this mode\n"
	if @artist and $mode != MODE_SINGLE;

# To debug requests and responses: e.g. --debug=3 3>debug.log
open(DEBUG, ">/dev/fd/$debugfd") if $debugfd;
open(DEBUG, ">/dev/null") unless $debugfd;

$| = 1;
my $mb = MusicBrainz->new;
$mb->Login;

print localtime() . " : Amazon match script starting\n";
eval 'END { print localtime() . " : Amazon match script ended\n" }';

# For debugging: specify "--single --artist='Foo Fighters' --artist=510 ..."

if ($mode == MODE_SINGLE)
{
	ProcessSingleArtists($mb->{DBH}, \@artist);
} else {
	MatchAlbums($mb->{DBH}, $mode, $percent, $limit); 
}

if ($summary)
{
	my $end_time = time;
	printf "%s : Artists processed: %d; queries sent: %d; time taken: %d sec\n",
		scalar(localtime),
		$artists_processed,
		$queries_sent,
		$end_time - $start_time,
		;
}

# eof Match.pl
