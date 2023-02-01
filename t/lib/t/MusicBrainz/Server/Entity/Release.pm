package t::MusicBrainz::Server::Entity::Release;
use utf8;
use strict;
use warnings;

use Test::Routine;
use Test::Moose;
use Test::More;

use aliased 'MusicBrainz::Server::Entity::Release';
use aliased 'MusicBrainz::Server::Entity::ReleasePackaging';
use aliased 'MusicBrainz::Server::Entity::ReleaseStatus';
use aliased 'MusicBrainz::Server::Entity::Medium';
use aliased 'MusicBrainz::Server::Entity::MediumFormat';

=head1 DESCRIPTION

This test checks whether release data is stored and calculated correctly.

=cut

test 'Empty release has expected calculated data' => sub {
    my $release = Release->new();
    does_ok($release, 'MusicBrainz::Server::Entity::Role::Quality');

    is(
        $release->status_name,
        undef,
        'Undefined release status name is calculated when no status explicitly set',
    );
    is(
        $release->packaging_name,
        undef,
        'Undefined release packaging name is calculated when no packaging explicitly set',
    );

    ok(
        @{$release->labels} == 0,
        'The count of labels for an empty release is 0',
    );
    ok(
        @{$release->mediums} == 0,
        'The count of mediums for an empty release is 0',
    );

    is(
        $release->combined_format_name,
        '',
        'The combined release format is empty when there are no mediums yet',
    );
    is(
        $release->combined_track_count,
        '',
        'The combined track count is empty when there are no mediums yet',
    );
};

test 'Release status data is stored and calculated properly' => sub {
    my $release = Release->new();
    $release->status(ReleaseStatus->new(id => 1, name => 'Official'));
    is(
        $release->status_name,
        'Official',
        'Expected release status name is returned after setting a status',
    );
    is($release->status->id, 1, 'The status id is stored as expected');
    is(
        $release->status->name,
        'Official',
        'The status name is stored as expected',
    );
};

test 'Release packaging data is stored and calculated properly' => sub {
    my $release = Release->new();
    $release->packaging(ReleasePackaging->new(id => 1, name => 'Jewel Case'));
    is(
        $release->packaging_name,
        'Jewel Case',
        'Expected release packaging name is returned after setting a packaging',
    );
    is($release->packaging->id, 1, 'The packaging id is stored as expected');
    is(
        $release->packaging->name,
        'Jewel Case',
        'The packaging name is stored as expected',
    );
};

test 'Medium data is stored and calculated properly' => sub {
    my $release = Release->new();

    note('We add one medium, a 10 track CD');
    my $medium1 = Medium->new(track_count => 10, position => 1);
    $medium1->format(MediumFormat->new(id => 1, name => 'CD'));
    $release->add_medium($medium1);
    is(
        $release->combined_format_name,
        'CD',
        'The combined release format is CD',
    );
    is(
        $release->combined_track_count,
        '10',
        'The combined release track count is 10',
    );

    note('We add a second medium, a 22 track DVD');
    my $medium2 = Medium->new(track_count => 22, position => 2);
    $medium2->format(MediumFormat->new(id => 2, name => 'DVD'));
    $release->add_medium($medium2);
    is(
        $release->combined_format_name,
        'CD + DVD',
        'The combined release format is CD + DVD',
    );
    is(
        $release->combined_track_count,
        '10 + 22',
        'The combined release track count is 10 + 22',
    );

    note('We add a third medium, another 10 track CD');
    my $medium3 = Medium->new(track_count => 10, position => 3);
    $medium3->format(MediumFormat->new(id => 1, name => 'CD'));
    $release->add_medium($medium3);
    is(
        $release->combined_format_name,
        '2×CD + DVD',
        'The combined release format is 2×CD + DVD',
    );
    is(
        $release->combined_track_count,
        '10 + 22 + 10',
        'The combined release track count is 10 + 22 + 10',
    );
};

test 'Can store release pending edits' => sub {
    my $release = Release->new();
    $release->edits_pending(2);
    is(
        $release->edits_pending,
        2,
        'The number of pending edits is stored as expected',
    );
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
