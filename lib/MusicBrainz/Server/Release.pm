package MusicBrainz::Server::Release;
use strict;
use warnings;

use MusicBrainz::Server::Translation qw( l ln );

use constant RELEASE_ATTR_ALBUM          => 1;
use constant RELEASE_ATTR_SINGLE         => 2;
use constant RELEASE_ATTR_EP             => 3;
use constant RELEASE_ATTR_COMPILATION    => 4;
use constant RELEASE_ATTR_SOUNDTRACK     => 5;
use constant RELEASE_ATTR_SPOKENWORD     => 6;
use constant RELEASE_ATTR_INTERVIEW      => 7;
use constant RELEASE_ATTR_AUDIOBOOK      => 8;
use constant RELEASE_ATTR_LIVE           => 9;
use constant RELEASE_ATTR_REMIX          => 10;
use constant RELEASE_ATTR_OTHER          => 11;

use constant RELEASE_ATTR_OFFICIAL       => 100;
use constant RELEASE_ATTR_PROMOTION      => 101;
use constant RELEASE_ATTR_BOOTLEG        => 102;
use constant RELEASE_ATTR_PSEUDO_RELEASE => 103;

use constant RELEASE_ATTR_SECTION_TYPE_START   => RELEASE_ATTR_ALBUM;
use constant RELEASE_ATTR_SECTION_TYPE_END     => RELEASE_ATTR_OTHER;
use constant RELEASE_ATTR_SECTION_STATUS_START => RELEASE_ATTR_OFFICIAL;
use constant RELEASE_ATTR_SECTION_STATUS_END   => RELEASE_ATTR_PSEUDO_RELEASE;

my %AlbumAttributeNames = (
    0 => [ 'Non-Album Track', 'Non-Album Tracks', l('(Special case)')],
    1 => [ 'Album', 'Albums', l('An album release primarily consists of previously unreleased material. This includes album re-issues, with or without bonus tracks.')],
    2 => [ 'Single', 'Singles', l('A single typically has one main song and possibly a handful of additional tracks or remixes of the main track. A single is usually named after its main song.')],
    3 => [ 'EP', 'EPs', l('An EP is an Extended Play release and often contains the letters EP in the title.')],
    4 => [ 'Compilation', 'Compilations', l('A compilation is a collection of previously released tracks by one or more artists.')],
    5 => [ 'Soundtrack', 'Soundtracks', l('A soundtrack is the musical score to a movie, TV series, stage show, computer game etc.')],
    6 => [ 'Spokenword', 'Spokenword', l('Non-music spoken word releases.')],
    7 => [ 'Interview', 'Interviews', l('An interview release contains an interview with the Artist.')],
    8 => [ 'Audiobook', 'Audiobooks', l('An audiobook is a book read by a narrator without music.')],
    9 => [ 'Live', 'Live Releases', l('A release that was recorded live.')],
    10 => [ 'Remix', 'Remixes', l('A release that was (re)mixed from previously released material.')],
    11 => [ 'Other', 'Other Releases', l('Any release that does not fit any of the categories above.')],

    100 => [ 'Official', 'Official', l('Any release officially sanctioned by the artist and/or their record company. (Most releases will fit into this category.)') ],
    101 => [ 'Promotion', 'Promotions', l('A giveaway release or a release intended to promote an upcoming official release. (e.g. prerelease albums or releases included with a magazine)')],
    102 => [ 'Bootleg', 'Bootlegs', l('An unofficial/underground release that was not sanctioned by the artist and/or the record company.')],
    103 => [ 'Pseudo-Release', 'PseudoReleases', l('A pseudo-release is a duplicate release for translation/transliteration purposes.')]
);

sub attribute_name           { $AlbumAttributeNames{$_[0]}->[0]; }
sub attribute_name_as_plural { $AlbumAttributeNames{$_[0]}->[1]; }

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2000 Robert Kaye

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
