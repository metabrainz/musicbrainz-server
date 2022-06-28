package t::MusicBrainz::Server::Controller::Artist::Releases;
use Test::Routine;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

=head2 Test description

This test checks whether the artist releases page properly displays
releases for the artist.

=cut

test 'Artist releases page contains the expected data' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c    = $test->c;

    MusicBrainz::Server::Test->prepare_test_database(
      $c,
      '+controller_artist',
    );

    $mech->get_ok(
      '/artist/745c079d-374e-4436-9448-da92dedef3ce/releases',
        'Fetched artist releases page',
    );
    html_ok($mech->content);
    $mech->title_like(
        qr/Test Artist/,
        'The page title contains Test Artist',
    );
    $mech->title_like(
        qr/releases/i,
        'The page title indicates this is a releases listing',
    );
    $mech->content_contains('Test Release', 'The release name is listed');
    $mech->content_contains('2009-05-08', 'The release date is listed');
    $mech->content_contains(
        '/release/f34c079d-374e-4436-9448-da92dedef3ce',
        'A link to the release is present',
    );
};

1;
