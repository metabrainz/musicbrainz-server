package t::MusicBrainz::Server::Controller::Recording::Details;
use strict;
use warnings;

use Test::Routine;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

=head2 Test description

This test checks that the recording details page contains all the expected data.

=cut

test 'Details tab has all the expected data' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c    = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c);

    $mech->get_ok(
        '/recording/54b9d183-7dab-42ba-94a3-7388a66604b8/details',
        'Fetched recording details page',
    );
    html_ok($mech->content);
    $mech->text_contains(
        'Permanent link:https://musicbrainz.org/recording/54b9d183-7dab-42ba-94a3-7388a66604b8',
        'The details tab contains the recording permalink',
    );
    $mech->text_contains(
        'MBID:54b9d183-7dab-42ba-94a3-7388a66604b8',
        'The details tab contains the MBID in plain text',
    );
    $mech->text_contains(
        'Last updated:2020-02-20 19:00 UTC',
        'The details tab contains the last updated date',
    );
    $mech->text_contains(
        '/ws/2/recording/54b9d183-7dab-42ba-94a3-7388a66604b8?',
        'The details tab contains a WS link',
    );
};

1;
