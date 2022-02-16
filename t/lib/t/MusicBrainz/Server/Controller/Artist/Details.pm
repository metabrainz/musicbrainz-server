package t::MusicBrainz::Server::Controller::Artist::Details;
use Test::Routine;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

=head2 Test description

This test checks that the artist details page contains all the expected data.

=cut

test 'Check details tab has all the expected data' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c    = $test->c;

    MusicBrainz::Server::Test->prepare_test_database(
        $c,
        '+controller_artist',
    );

    $mech->get_ok(
        '/artist/745c079d-374e-4436-9448-da92dedef3ce/details',
        'Fetched artist details page',
    );
    html_ok($mech->content);
    $mech->content_contains(
        'https://musicbrainz.org/artist/745c079d-374e-4436-9448-da92dedef3ce',
        'The details tab contains the artist permalink',
    );
    $mech->content_contains(
        '>745c079d-374e-4436-9448-da92dedef3ce</',
        'The details tab contains the MBID in plain text',
    );
    $mech->content_contains(
        '>2009-07-09 00:00 UTC</',
        'The details tab contains the last updated date',
    );
    $mech->content_contains(
        '/ws/2/artist/745c079d-374e-4436-9448-da92dedef3ce?',
        'The details tab contains a WS link',
    );
};

1;
