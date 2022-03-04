package t::MusicBrainz::Server::Controller::ReleaseGroup::Details;
use strict;
use warnings;

use Test::Routine;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

=head2 Test description

This test checks that the release group details page contains all the
expected data.

=cut

test 'Details tab has all the expected data' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c    = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c);

    $mech->get_ok(
        '/release-group/234c079d-374e-4436-9448-da92dedef3ce/details',
        'Fetched release group details page',
    );
    html_ok($mech->content);
    $mech->text_contains(
        'Permanent link:https://musicbrainz.org/release-group/234c079d-374e-4436-9448-da92dedef3ce',
        'The details tab contains the release group permalink',
    );
    $mech->text_contains(
        'MBID:234c079d-374e-4436-9448-da92dedef3ce',
        'The details tab contains the MBID in plain text',
    );
    $mech->text_contains(
        'Last updated:2003-03-03 00:00 UTC',
        'The details tab contains the last updated date',
    );
    $mech->text_contains(
        '/ws/2/release-group/234c079d-374e-4436-9448-da92dedef3ce?',
        'The details tab contains a WS link',
    );
};

1;
