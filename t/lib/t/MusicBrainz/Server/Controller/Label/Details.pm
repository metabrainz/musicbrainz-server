package t::MusicBrainz::Server::Controller::Label::Details;
use strict;
use warnings;

use Test::Routine;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

=head2 Test description

This test checks that the label details page contains all the expected data.

=cut

test 'Details tab has all the expected data' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c    = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c);

    $mech->get_ok(
        '/label/46f0f4cd-8aab-4b33-b698-f459faf64190/details',
        'Fetched label details page',
    );
    html_ok($mech->content);
    $mech->text_contains(
        'Permanent link:https://musicbrainz.org/label/46f0f4cd-8aab-4b33-b698-f459faf64190',
        'The details tab contains the label permalink',
    );
    $mech->text_contains(
        'MBID:46f0f4cd-8aab-4b33-b698-f459faf64190',
        'The details tab contains the MBID in plain text',
    );
    $mech->text_contains(
        'Last updated:2014-01-13 00:00 UTC',
        'The details tab contains the last updated date',
    );
    $mech->text_contains(
        '/ws/2/label/46f0f4cd-8aab-4b33-b698-f459faf64190?',
        'The details tab contains a WS link',
    );
};

1;
