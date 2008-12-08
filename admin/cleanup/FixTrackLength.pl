#!/usr/bin/perl -w
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
use MusicBrainz::Server::Release;
use MusicBrainz::Server::Track;
use MusicBrainz::Server::ReleaseCDTOC;
use Moderation;
use MusicBrainz;
use UserStuff;

use Getopt::Long;
my $debug = 0;
my $dry_run = 0;
my $verbose = 0;
my $help = 0;
GetOptions(
	"debug!"			=> \$debug,
	"dry-run|dryrun!"	=> \$dry_run,
	"verbose|v"			=> \$verbose,
	"help"				=> \$help,
) or exit 2;
$help = 1 if @ARGV;

die <<EOF if $help;
Usage: FixTrackLength.pl [OPTIONS]

Allowed options are:
        --[no]dry-run     don't actually make any changes (best used with
                          --verbose) (default is to make the changes)
    -v, --verbose         show the changes as they are made
        --[no]debug       show lots of debugging information
        --help            show this help

EOF

my $mb = MusicBrainz->new;
$mb->Login;
my $sql = Sql->new($mb->{DBH});
$| = 1;
my $privs = &UserStuff::AUTOMOD_FLAG;
my $moderator = &ModDefs::MODBOT_MODERATOR;

# Find albums with at least one track to fix
print localtime() . " : Finding candidate albums\n" if $verbose;
my $albums = $sql->SelectListOfHashes(
	"SELECT DISTINCT a.id, a.artist
	FROM album a, albumjoin j, track t, album_cdtoc
	WHERE a.id = j.album
	AND t.id = j.track
	AND album_cdtoc.album = a.id
	AND t.length <= 0",
);
printf localtime() . " : Found %d album%s\n",
	scalar(@$albums), (@$albums==1 ? "" : "s"),
	if $verbose;

my $tracks_fixed = 0;
my $tracks_set = 0;
my $albums_fixed = 0;

for my $album (@$albums)
{
	my $id = $album->{id};
    print localtime() . " : Fixing album #$id\n" if $verbose;

	no warnings 'exiting';
	eval {

		my $tocs = MusicBrainz::Server::ReleaseCDTOC->newFromRelease($mb->{DBH}, $id);
		$_ = $_->GetCDTOC for @$tocs;

		if ($debug)
		{
			print "TOCs:\n";
			for my $t (@$tocs)
			{
				print "  " . $t->GetTOC . "\n";

				my @l = TrackLengthsFromTOC($t);
				@l = map { MusicBrainz::Server::Track::FormatTrackLength($_) } @l;
				print "    (@l)\n";
			}
		}

		my $tracks = $sql->SelectListOfHashes(
			"SELECT t.id, t.length, j.sequence, t.artist
			FROM track t, albumjoin j
			WHERE t.id = j.track
			AND j.album = ?
			ORDER BY j.sequence",
			$id,
		);

		if ($debug)
		{
			print "Tracks:\n";
			printf "  #%02d : %10d %-8s  %12d\n",
				$_->{sequence},
				$_->{length},
				(($_->{length} > 0) ? MusicBrainz::Server::Track::FormatTrackLength($_->{length}) : ""),
				$_->{id},
				for @$tracks;
		}

		# Easy case: there is one disc ID, we have exactly the correct set of
		# tracks, and all the tracks have no length.
		if (@$tocs == 1)
		{
			my $release = MusicBrainz::Server::Release->new($mb->{DBH});
			$release->SetId($id);
			$release->SetArtist($album->{artist});

			my $ideal_tracks = $tocs->[0]->GetTrackCount;
			my $want_tracks = join ",", 1 .. $ideal_tracks;
			my $have_tracks = join ",", sort { $a<=>$b } map { $_->{sequence} } @$tracks;

			if ($want_tracks eq $have_tracks)
			{
				# Check that each track either has no length, or its length seems
				# to match that given in the TOC

				my @want = TrackLengthsFromTOC($tocs->[0]);
				my @got = map { $_->{length} } @$tracks;
				my $bad = 0;

				for (1 .. $ideal_tracks)
				{
					my $got_l = $got[$_-1];
					my $want_l = $want[$_-1];

					next if $got_l <= 0;
					my $diff = abs($got_l - $want_l);
					next if $diff < 5000;

					++$bad;
				}

				if ($bad == 0)
				{
					# For each track with no length, set the length as indicated
					# by the TOC
					
					print "Set track durations from CDTOC #". $tocs->[0]->GetId ." for release #". $release->GetId . "\n"
						if $verbose;

					my @mods = Moderation->InsertModeration(
						DBH => $mb->{DBH},
						uid => $moderator,
						privs => $privs,
						type => &ModDefs::MOD_SET_RELEASE_DURATIONS,
						release =>  $release,
						cdtoc => $tocs->[0],
					) unless $dry_run;

					$mods[0]->InsertNote($moderator, "FixTrackLength script") if $mods[0];

					++$albums_fixed;
					next;
				}
			}
		}

		# Probably the next case to handle is any combination of:
		# - multiple TOCs, but where they are all "close enough"
		# - tracks already have length, but all those tracks match the TOC "well enough"
		my %c; ++$c{ $_->GetTrackCount } for @$tocs;

		if (keys(%c) == 1)
		{
			# OK, one or more TOCs where the track counts match at least.
			# How do the track lengths compare?

			my @parsed_tocs = map { [TrackLengthsFromTOC($_)] } @$tocs;
			my $num_tracks = (keys %c)[0];

			# Calculate the average track lengths
			my @average_toc;
			for my $n (0 .. $num_tracks-1)
			{
				my @l = map { $_->[$n] } @parsed_tocs;
				my $avg = 0;
				$avg += $_ for @l;
				$avg /= @l;
				push @average_toc, $avg;
			}

			# See how far off each TOC is from the average
			my @skew;
			for my $p (@parsed_tocs)
			{
				my $sqdiff = 0;
				for my $n (0 .. $num_tracks-1)
				{
					my $diff = $p->[$n] - $average_toc[$n];
					$sqdiff += $diff*$diff;
				}
				$sqdiff /= $num_tracks;
				$sqdiff = sqrt($sqdiff) / 1000;

				print "Skew for @$p = $sqdiff\n" if $debug;
				push @skew, $sqdiff;
			}

			if (not grep { $_ > 5 } @skew)
			{
				# Good, the TOC track lengths agree (clearly, if there's only one
				# TOC).
				# For each track which has length already, let's see how
				# closely it matches the average TOC.
				my $sqdiff = 0;
				for my $t (@$tracks)
				{
					my $l = $t->{length};
					$l > 0 or next;
					my $diff = $l - $average_toc[$t->{sequence}-1];
					$sqdiff += $diff*$diff;
				}
				$sqdiff /= $num_tracks;
				$sqdiff = sqrt($sqdiff) / 1000;

				print "Skew for existing tracks = $sqdiff\n" if $debug;

				if ($sqdiff < 5)
				{
					for my $t (@$tracks)
					{
						# TODO? next if $t->{length} > 0;
						my $new_length = int($average_toc[$t->{sequence}-1]);
						my $track = MusicBrainz::Server::Track->new($mb->{DBH});
						$track->SetId($t->{id});
						$track->SetArtist($t->{artist});
						$track->SetLength($t->{length});

						print "Edit track time #". $track->GetId ." with length = $new_length\n"
							if $verbose;

						my @mods = Moderation->InsertModeration(
							DBH => $mb->{DBH},
							uid => $moderator,
							privs => $privs,
							type => &ModDefs::MOD_EDIT_TRACKTIME,
							track =>  $track,
							newlength => $new_length,
						) unless $dry_run;

						$mods[0]->InsertNote($moderator, "FixTrackLength script") if $mods[0];
						
						++$tracks_fixed;
						++$tracks_set unless $t->{length} > 0;
					}

					++$albums_fixed;
					next;
				}
			}
		}

		print "Don't know what to do about album #$id\n";

		print " - multiple TOCs\n" if @$tocs > 1 and keys(%c)==1;
		print " - multiple conflicting TOCs\n" if @$tocs > 1 and keys(%c)>1;

		if (keys(%c)==1)
		{
			my $ideal_tracks = $tocs->[0]->GetTrackCount;
			my $want_tracks = join ",", 1 .. $ideal_tracks;
			my $have_tracks = join ",", sort { $a<=>$b } map { $_->{sequence} } @$tracks;
			print " - got tracks $have_tracks\n" if $want_tracks ne $have_tracks;
		}

		my $withlength = grep { $_->{length}>0 } @$tracks;
		print " - $withlength tracks have length\n" if $withlength;

	};

	if (my $err = $@)
	{
		warn $err;
		eval { $sql->Rollback };
	}
}

print localtime() . " : Fixed $tracks_fixed tracks on $albums_fixed albums\n";
print localtime() . " : ($tracks_set had no previous length)\n";

sub TrackLengthsFromTOC
{
	my $toc = shift;
	map { $_/75*1000 } @{ $toc->GetTrackLengths };
}

# eof FixTrackLength.pl
