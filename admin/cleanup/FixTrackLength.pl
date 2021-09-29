#!/usr/bin/env perl

use warnings;

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../../lib";

use aliased 'MusicBrainz::Server::Entity::Track';

use DBDefs;
use List::AllUtils qw ( any );
use MusicBrainz::Server::Context;
use MusicBrainz::Server::Constants qw(
    $EDITOR_MODBOT
    $EDIT_SET_TRACK_LENGTHS
    $EDIT_MEDIUM_EDIT
);
use MusicBrainz::Server::Constants qw( $AUTO_EDITOR_FLAG );
use MusicBrainz::Server::Track qw( format_track_length );

use Getopt::Long;
my $debug = 0;
my $dry_run = 0;
my $verbose = 0;
my $help = 0;
GetOptions(
    'debug!'                    => \$debug,
    'dry-run|dryrun!'   => \$dry_run,
    'verbose|v'                 => \$verbose,
    'help'                              => \$help,
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

my $c = MusicBrainz::Server::Context->create_script_context;

# Find mediums with at least one track to fix
print localtime() . " : Finding candidate mediums\n" if $verbose;
my @medium_ids = @{ $c->sql->select_single_column_array(
    'SELECT DISTINCT m.id
       FROM medium m
       JOIN medium_cdtoc mcd ON mcd.medium = m.id
  LEFT JOIN medium_format mf ON mf.id = m.format
       JOIN track t ON t.medium = m.id
      WHERE t.length IS NULL OR t.length = 0 AND m.track_count > 0
        AND (mf.has_discids = TRUE OR mf.has_discids IS NULL)'
) };
printf localtime() . " : Found %d medium%s\n",
    scalar(@medium_ids), (@medium_ids == 1 ? '' : 's')
    if $verbose;

my $tracks_fixed = 0;
my $tracks_set = 0;
my $mediums_fixed = 0;

my %medium_by_id = %{ $c->model('Medium')->get_by_ids(@medium_ids) };
my @mediums = values %medium_by_id;
$c->model('Track')->load_for_mediums(@mediums);
$c->model('ArtistCredit')->load(map { $_->all_tracks } @mediums);

my $modbot = $c->model('Editor')->get_by_id($EDITOR_MODBOT);

for my $medium (@mediums)
{
    printf "%s : Fixing medium #%d\n", scalar(localtime), $medium->id
        if $verbose;

    my @cdtocs = grep { $_->edits_pending == 0 } $c->model('MediumCDTOC')->find_by_medium($medium->id);
    $c->model('CDTOC')->load(@cdtocs);

    @cdtocs = map { $_->cdtoc }
        grep { $medium_by_id{$_->medium_id}->cdtoc_track_count == $_->cdtoc->track_count }
            @cdtocs;
    my @tracks = $medium->all_tracks;

    if ($debug) {
        print "TOCs:\n";
        for my $cdtoc (@cdtocs) {
            print '  ' . $cdtoc->toc . "\n";
            printf "    (%s)\n", format_track_length($_->{length_time})
                for @{ $cdtoc->track_details };
        }

        print "Tracks:\n";
        printf "  #%02d : %10d %-8s  %12d\n",
            $_->position, $_->length || 0,
            $_->length ? format_track_length($_->length) : '',
            $_->id
                for @tracks;
    }

    # Easy case: there is one disc ID, we have exactly the correct set of
    # tracks, and all the tracks have no length.
    if (@cdtocs == 1) {
        my $cdtoc = $cdtocs[0];

        my $cdtoc_track_count = $cdtoc->track_count;
        my $want_tracks = join q(,), 1 .. $cdtoc_track_count;
        my $have_tracks = join q(,), sort { $a<=>$b } map { $_->position }
            @tracks;

        if ($want_tracks eq $have_tracks) {
            # Check that each track either has no length, or its length seems
            # to match that given in the TOC

            my @want = map { $_->{length_time} } @{ $cdtoc->track_details };
            my @got = map { $_->length } @tracks;
            my $bad = 0;

            for (1 .. $cdtoc_track_count) {
                my $got_l = $got[$_-1];
                my $want_l = $want[$_-1];

                next unless $got_l;
                my $diff = abs($got_l - $want_l);
                next if $diff < 5000;

                ++$bad;
            }

            if ($bad == 0) {
                # All track lengths are wrong, so we change them with a
                # SetTrackLengths edit
                printf "Set track durations from CDTOC #%d for medium #%d\n",
                    $cdtoc->id, $medium->id
                        if $verbose;

                unless ($dry_run) {
                    Sql::run_in_transaction(sub {
                        my $edit = $c->model('Edit')->create(
                            editor => $modbot,
                            privileges => $AUTO_EDITOR_FLAG,
                            edit_type => $EDIT_SET_TRACK_LENGTHS,
                            medium_id => $medium->id,
                            cdtoc_id => $cdtoc->id
                        );

                        $c->model('EditNote')->add_note(
                            $edit->id,
                            {
                                editor_id => $EDITOR_MODBOT,
                                text => 'FixTrackLength script'
                            }
                        );
                    }, $c->sql);
                }

                ++$mediums_fixed;
                next;
            }
        }
    }

    # Probably the next case to handle is any combination of:
    # - multiple TOCs, but where they are all "close enough"
    # - tracks already have length, but all those tracks match the TOC "well enough"
    my %c; ++$c{ $_->track_count } for @cdtocs;

    if (keys(%c) == 1) {
        # All CDTOCs have matching track counts
        my @parsed_tocs = map [
            map { $_->{length_time} } @{ $_->track_details }
        ], @cdtocs;
        my $num_tracks = $cdtocs[0]->track_count;

        # Calculate the average track lengths
        my @average_toc;
        for my $n (0 .. $num_tracks-1) {
            my @l = map { $_->[$n] } @parsed_tocs;
            my $avg = 0;
            $avg += $_ for @l;
            $avg /= @l;
            push @average_toc, $avg;
        }

        # See how far off each TOC is from the average
        my @skew;
        for my $p (@parsed_tocs) {
            my $sqdiff = 0;
            for my $n (0 .. $num_tracks-1) {
                my $diff = $p->[$n] - $average_toc[$n];
                $sqdiff += $diff*$diff;
            }
            $sqdiff /= $num_tracks;
            $sqdiff = sqrt($sqdiff) / 1000;

            print "Skew for @$p = $sqdiff\n" if $debug;
            push @skew, $sqdiff;
        }

        unless (any { $_ > 5 } @skew) {
            # Good, the TOC track lengths agree (clearly, if there's only one
            # TOC).
            # For each track which has length already, let's see how
            # closely it matches the average TOC.
            my $sqdiff = 0;
            for my $t (@tracks) {
                my $l = $t->length || 0;
                $l > 0 or next;
                my $diff = $l - $average_toc[$t->position - 1];
                $sqdiff += $diff*$diff;
            }
            $sqdiff /= $num_tracks;
            $sqdiff = sqrt($sqdiff) / 1000;

            print "Skew for existing tracks = $sqdiff\n" if $debug;

            if ($sqdiff < 5) {
                unless (@tracks) {
                    # FIXME This is a bug, and a hacky fix!
                    # I have no idea why, but load_for_mediums above sometimes
                    # doesn't actually load all tracklists...
                    warn 'A medium has lost its tracklist: ' . $medium->id;
                    $c->model('Track')->load_for_mediums($medium);
                    @tracks = $medium->all_tracks;
                    $c->model('ArtistCredit')->load(@tracks);
                }

                my @new_tracklist = map {
                    Track->new(
                        id => $_->id,
                        length => ($_->position > 0 && !$_->is_data_track ? int($average_toc[$_->position - 1]) : $_->length),
                        number => $_->number,
                        name => $_->name,
                        artist_credit => $_->artist_credit,
                        recording_id => $_->recording_id,
                        position => $_->position,
                        is_data_track => $_->is_data_track
                    )
                } @tracks;

                unless ($dry_run) {
                    Sql::run_in_transaction(sub {
                        my $edit = $c->model('Edit')->create(
                            edit_type => $EDIT_MEDIUM_EDIT,
                            editor => $modbot,
                            privileges => $AUTO_EDITOR_FLAG,
                            to_edit => $medium,
                            tracklist => \@new_tracklist
                        );

                        $c->model('EditNote')->add_note(
                            $edit->id,
                            {
                                editor_id => $EDITOR_MODBOT,
                                text => 'FixTrackLength script'
                            }
                        );
                    }, $c->sql);

                }

                ++$mediums_fixed;
                next;
            }
        }
    }

    printf "Don't know what to do about medium #%d\n", $medium->id;
    print " - multiple TOCs\n" if @cdtocs > 1 and keys(%c) == 1;
    print " - multiple conflicting TOCs\n" if @cdtocs > 1 and keys(%c)>1;
    print " - no TOCs with correct track count\n" if @cdtocs == 0;

    if (keys(%c) == 1) {
        my $ideal_track_count = $cdtocs[0]->track_count;
        my $want_tracks = join q(,), 1 .. $ideal_track_count;
        my $have_tracks = join q(,), sort { $a<=>$b } map { $_->position }
            @tracks;
        print " - got tracks $have_tracks\n" if $want_tracks ne $have_tracks;
    }

    my $withlength = grep { $_->length && $_->length > 0 } @tracks;
    print " - $withlength tracks have length\n" if $withlength;
}

print localtime() . " : Fixed $tracks_fixed tracks on $mediums_fixed mediums\n";
print localtime() . " : ($tracks_set had no previous length)\n";

=head1 COPYRIGHT AND LICENSE

Copyright (C) 1998 Robert Kaye

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
