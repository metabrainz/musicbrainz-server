package t::MusicBrainz::Server::Controller::Artist::Works;
use Test::Routine;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

=head2 Test description

This test checks whether the artist releases page properly displays
works for the artist.

=cut

test all => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c    = $test->c;

    MusicBrainz::Server::Test->prepare_test_database(
      $c,
      '+controller_artist',
    );

    $mech->get_ok(
      '/artist/745c079d-374e-4436-9448-da92dedef3ce/works',
      'Fetched the artists works page');
    html_ok($mech->content);
    $mech->title_like(
        qr/Test Artist/,
        'The page title contains Test Artist',
    );
    $mech->title_like(
        qr/works/i,
        'The page title indicates this is a works listing',
    );
    $mech->content_contains('Test Work', 'The work name is listed');
    $mech->content_contains(
        '/work/745c079d-374e-4436-9448-da92dedef3ce',
        'A link to the work is present',
    );
};

1;
